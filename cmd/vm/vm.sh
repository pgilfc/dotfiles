#!/usr/bin/env bash
# shellcheck disable=SC2034  # globals exported for use by later tasks
set -euo pipefail

# --- configuration -----------------------------------------------------------
FEDORA_RELEASE="${FEDORA_RELEASE:-44}"
ISO_DIR_URL="https://dl.fedoraproject.org/pub/fedora/linux/releases/${FEDORA_RELEASE}/Everything/x86_64/iso"

# throwaway credentials for a NAT-isolated disposable VM — never reuse anywhere
VM_USER="tester"
VM_PASSWORD="dotfiles"
LUKS_PASSPHRASE="dotfiles"

VM_MEMORY_MIB=4096
VM_CPUS=4
VM_DISK=40G
SSH_PORT="${VM_SSH_PORT:-2222}"
INSTALL_TIMEOUT=3600 # netinst pulls packages from mirrors; generous on purpose
BOOT_TIMEOUT=300

REPO_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles-vm/f${FEDORA_RELEASE}"
ISO="$CACHE_DIR/netinst.iso"
CHECKSUM_FILE="$CACHE_DIR/CHECKSUM"
KS_FILE="$CACHE_DIR/ks.cfg"
OEMDRV="$CACHE_DIR/oemdrv.iso"
BASE="$CACHE_DIR/base.qcow2"
OVERLAY="$CACHE_DIR/overlay.qcow2"
OVMF_VARS_BASE="$CACHE_DIR/ovmf_vars_base.fd"
OVMF_VARS_RUN="$CACHE_DIR/ovmf_vars_run.fd"
SSH_KEY="$CACHE_DIR/ssh_key"
TPM_DIR="$CACHE_DIR/tpm"
SWTPM_SOCK="$CACHE_DIR/swtpm.sock"
SWTPM_PID="$CACHE_DIR/swtpm.pid"
SERIAL_SOCK="$CACHE_DIR/serial.sock"
MONITOR_SOCK="$CACHE_DIR/monitor.sock"
QEMU_PID="$CACHE_DIR/qemu.pid"
LOCK="$CACHE_DIR/lock"

# --- helpers -----------------------------------------------------------------
die() { echo "vm.sh: $*" >&2; exit 1; }
log() { echo "[vm] $*" >&2; }

find_ovmf() {
  local c
  for c in \
    /usr/share/OVMF/OVMF_CODE_4M.fd \
    /usr/share/OVMF/OVMF_CODE.fd \
    /usr/share/edk2/ovmf/OVMF_CODE.fd \
    /usr/share/edk2/x64/OVMF_CODE.4m.fd; do
    if [[ -f $c ]]; then printf '%s\n' "$c"; return 0; fi
  done
  die "no OVMF UEFI firmware found (install ovmf / edk2-ovmf)"
}

# the VARS template ships next to CODE with the same naming scheme
ovmf_vars_template() { printf '%s\n' "${1/OVMF_CODE/OVMF_VARS}"; }

preflight() {
  local missing=() c
  for c in qemu-system-x86_64 qemu-img swtpm mkisofs socat curl sha256sum ssh ssh-keygen rsync flock; do
    command -v "$c" >/dev/null || missing+=("$c")
  done
  ((${#missing[@]} == 0)) || die "missing tools: ${missing[*]}"
  [[ -r /dev/kvm && -w /dev/kvm ]] || die "/dev/kvm not accessible (kvm modules loaded? user in kvm group?)"
  find_ovmf >/dev/null
  local vars_tmpl
  vars_tmpl=$(ovmf_vars_template "$(find_ovmf)")
  [[ -f $vars_tmpl ]] || die "OVMF VARS template not found: $vars_tmpl"
  mkdir -p "$CACHE_DIR"
  if [[ ! -f $BASE ]]; then
    local free_kib
    free_kib=$(df --output=avail -k "$CACHE_DIR" | tail -1)
    (( free_kib >= 20971520 )) || die "need ~20 GiB free in $CACHE_DIR (golden image + overlay incl. 8 GiB swapfile)"
  fi
}

acquire_lock() {
  mkdir -p "$CACHE_DIR"
  exec 9>"$LOCK"
  flock -n 9 || die "another vm.sh invocation is running (lock: $LOCK)"
}

# --- kickstart ----------------------------------------------------------------
ensure_ssh_key() {
  [[ -f $SSH_KEY ]] || ssh-keygen -q -t ed25519 -N '' -C dotfiles-vm -f "$SSH_KEY"
}

render_ks() {
  ensure_ssh_key
  local pubkey
  pubkey=$(<"${SSH_KEY}.pub")
  sed -e "s|@LUKS_PASSPHRASE@|$LUKS_PASSPHRASE|g" \
      -e "s|@VM_USER@|$VM_USER|g" \
      -e "s|@VM_PASSWORD@|$VM_PASSWORD|g" \
      -e "s|@SSH_PUBKEY@|$pubkey|g" \
      "$REPO_ROOT/cmd/vm/ks.cfg.tmpl" > "$KS_FILE"
  if grep -q '@[A-Z_]\+@' "$KS_FILE"; then
    die "unrendered placeholder left in $KS_FILE"
  fi
}

make_oemdrv() {
  local dir="$CACHE_DIR/oemdrv"
  rm -rf "$dir"
  mkdir -p "$dir"
  cp "$KS_FILE" "$dir/ks.cfg"
  # -R/-J keep the lowercase name: plain ISO9660 level 1 stores it as KS.CFG;1,
  # which Anaconda's ks.cfg lookup misses -> silently interactive install
  mkisofs -quiet -R -J -V OEMDRV -o "$OEMDRV" "$dir" # Anaconda auto-loads ks.cfg from a volume labeled OEMDRV
}

# --- iso ------------------------------------------------------------------ ---
verify_iso() {
  local iso_name=$1 expected actual
  expected=$(awk -v f="$iso_name" '$1 == "SHA256" && $2 == "(" f ")" {print $NF}' "$CHECKSUM_FILE")
  [[ -n $expected ]] || die "no SHA256 entry for $iso_name in $CHECKSUM_FILE"
  log "verifying ISO checksum"
  actual=$(sha256sum "$ISO" | awk '{print $1}')
  [[ $actual == "$expected" ]] || die "ISO checksum mismatch (expected $expected, got $actual) — delete $ISO and retry"
}

fetch_iso() {
  local listing iso_name sum_name
  listing=$(curl -fsSL "$ISO_DIR_URL/") || die "cannot list $ISO_DIR_URL (network? release exists?)"
  iso_name=$(grep -oE 'Fedora-Everything-netinst-x86_64-[0-9]+-[0-9.]+\.iso' <<<"$listing" | sort -u | head -1)
  sum_name=$(grep -oE 'Fedora-Everything-[0-9]+-[0-9.]+-x86_64-CHECKSUM' <<<"$listing" | sort -u | head -1)
  [[ -n $iso_name && -n $sum_name ]] || die "could not discover ISO/CHECKSUM names in $ISO_DIR_URL"
  curl -fsSL -o "$CHECKSUM_FILE" "$ISO_DIR_URL/$sum_name"
  if [[ ! -f $ISO ]]; then
    log "downloading $iso_name (~800 MiB, resumable)"
    curl -fL -C - --progress-bar -o "$ISO.part" "$ISO_DIR_URL/$iso_name"
    mv "$ISO.part" "$ISO"
  fi
  verify_iso "$iso_name"
}

# --- serial ---------------------------------------------------------------- --
# serial_expect TIMEOUT PATTERN [RESPONSE] [FAIL_PATTERN]
# Watch the VM serial console until PATTERN appears (send RESPONSE + newline if
# given; return 0), FAIL_PATTERN appears first (return 2), or TIMEOUT seconds
# pass / the connection drops (return 1). qemu only delivers serial output
# while a client is connected, so call this promptly after starting/rebooting.
serial_expect() {
  local timeout=$1 pattern=$2 response=${3-} fail_pattern=${4-}
  local deadline=$((SECONDS + timeout)) buf='' c rc=1
  local ser_pid ser_out ser_in
  coproc SERIAL { socat - "UNIX-CONNECT:$SERIAL_SOCK"; }
  # capture pid + fds immediately: bash unsets SERIAL/SERIAL_PID the moment it
  # reaps a dead coproc, and under set -u a later expansion of them aborts the
  # whole script (silently, if the expansion sits inside a 2>/dev/null group)
  ser_pid=$SERIAL_PID ser_out=${SERIAL[0]} ser_in=${SERIAL[1]}
  while (( SECONDS < deadline )); do
    if IFS= read -r -t 1 -N 1 c 2>/dev/null <&"$ser_out"; then
      buf+=$c
      if [[ $buf == *"$pattern"* ]]; then
        if [[ -n $response ]]; then
          # shellcheck disable=SC2261  # $ser_in is a numeric fd: >& duplicates it, no stderr clash
          printf '%s\n' "$response" >&"$ser_in" 2>/dev/null || true
          sleep 1 # let the guest consume it before we hang up
        fi
        rc=0
        break
      elif [[ -n $fail_pattern && $buf == *"$fail_pattern"* ]]; then
        rc=2
        break
      fi
      if (( ${#buf} > 65536 )); then buf=${buf: -4096}; fi
    elif ! kill -0 "$ser_pid" 2>/dev/null; then
      break # socat exited: socket closed under us
    fi
  done
  { kill "$ser_pid" && wait "$ser_pid"; } 2>/dev/null || true
  return "$rc"
}

# --- vm lifecycle --------------------------------------------------------- ---
# 9>&- on every daemon spawn: without it the daemon inherits acquire_lock's
# fd 9, the flock outlives the wrapper, and down/reset die on a phantom lock
start_swtpm() {
  mkdir -p "$TPM_DIR"
  swtpm socket --tpm2 --tpmstate "dir=$TPM_DIR" \
    --ctrl "type=unixio,path=$SWTPM_SOCK" \
    --pid "file=$SWTPM_PID" --terminate --daemon 9>&-
}

qemu_args() { # $1 = OVMF VARS file for this boot; result in global QEMU_ARGS
  local vars_file=$1 ovmf_code
  ovmf_code=$(find_ovmf)
  # shellcheck disable=SC2054  # multi-line array is valid bash; false positive on newline separators
  QEMU_ARGS=(
    -name dotfiles-vm
    -machine q35,accel=kvm
    -cpu host -m "$VM_MEMORY_MIB" -smp "$VM_CPUS"
    -drive "if=pflash,format=raw,readonly=on,file=$ovmf_code"
    -drive "if=pflash,format=raw,file=$vars_file"
    -chardev "socket,id=chrtpm,path=$SWTPM_SOCK"
    -tpmdev emulator,id=tpm0,chardev=chrtpm
    -device tpm-crb,tpmdev=tpm0
    -netdev "user,id=net0,hostfwd=tcp:127.0.0.1:${SSH_PORT}-:22"
    -device virtio-net-pci,netdev=net0
    -chardev "socket,id=ser0,path=$SERIAL_SOCK,server=on,wait=off"
    -serial chardev:ser0
    -monitor "unix:$MONITOR_SOCK,server=on,wait=off"
    -pidfile "$QEMU_PID"
    -display "${VM_DISPLAY:-none}"
    -daemonize
  )
}

vm_running() {
  [[ -f $QEMU_PID ]] && kill -0 "$(cat "$QEMU_PID")" 2>/dev/null
}

# robust against racing/stale pidfiles: a bare $(cat) failure under set -e
# would abort mid-cleanup before the trailing rm -f runs
stop_vm() {
  local pid i
  if vm_running; then
    pid=$(cat "$QEMU_PID" 2>/dev/null) || pid=''
    if [[ -n $pid ]]; then
      kill "$pid" 2>/dev/null || true
      for i in {1..20}; do
        vm_running || break
        sleep 0.5
      done
      if vm_running; then kill -9 "$pid" 2>/dev/null || true; fi
    fi
  fi
  if [[ -f $SWTPM_PID ]]; then
    kill "$(cat "$SWTPM_PID")" 2>/dev/null || true
  fi
  rm -f "$QEMU_PID" "$SWTPM_PID" "$SWTPM_SOCK" "$SERIAL_SOCK" "$MONITOR_SOCK"
}

# ssh options must precede the destination — everything after it is the
# remote command, so callers pass only the command through "$@"
vssh() {
  ssh -p "$SSH_PORT" -i "$SSH_KEY" \
    -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR \
    -o ConnectTimeout=5 \
    "$VM_USER@127.0.0.1" "$@"
}

wait_ssh() {
  local deadline=$((SECONDS + 180))
  until vssh true 2>/dev/null; do
    (( SECONDS < deadline )) || die "SSH not reachable on 127.0.0.1:$SSH_PORT within 180s"
    sleep 3
  done
}

answer_luks() {
  local rc=0
  serial_expect "$BOOT_TIMEOUT" "Please enter passphrase" "$LUKS_PASSPHRASE" "login:" || rc=$?
  case $rc in
    0) log "LUKS passphrase sent" ;;
    2) log "no passphrase prompt — image boots unlocked (TPM-enrolled)" ;;
    *) die "boot produced neither LUKS prompt nor login within ${BOOT_TIMEOUT}s" ;;
  esac
}

sync_repo() {
  rsync -a --delete --exclude .git --exclude .ansible \
    -e "ssh -p $SSH_PORT -i $SSH_KEY -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR" \
    "$REPO_ROOT/" "$VM_USER@127.0.0.1:dotfiles/"
}

cmd_up() {
  preflight
  [[ -f $BASE ]] || die "no golden image — run: cmd/vm/vm.sh build"
  if vm_running; then
    log "VM already running"
  else
    stop_vm # reap any stale swtpm/sockets
    [[ -f $OVMF_VARS_BASE ]] || die "golden NVRAM missing — re-run: cmd/vm/vm.sh build"
    [[ -f $OVERLAY ]] || qemu-img create -f qcow2 -b "$BASE" -F qcow2 "$OVERLAY" >/dev/null
    [[ -f $OVMF_VARS_RUN ]] || cp "$OVMF_VARS_BASE" "$OVMF_VARS_RUN"
    start_swtpm
    qemu_args "$OVMF_VARS_RUN"
    qemu-system-x86_64 "${QEMU_ARGS[@]}" -drive "if=virtio,format=qcow2,file=$OVERLAY" 9>&-
    answer_luks
  fi
  wait_ssh
  log "VM up — connect with: cmd/vm/vm.sh ssh"
}

cmd_down() {
  stop_vm
  log "VM stopped (overlay kept)"
}

cmd_reset() {
  stop_vm
  rm -f "$OVERLAY" "$OVMF_VARS_RUN"
  rm -rf "$TPM_DIR"
  log "reset — next up boots the pristine golden image"
}

cmd_ssh() {
  vssh "$@"
}

cmd_build() {
  preflight
  fetch_iso
  render_ks
  make_oemdrv
  stop_vm
  rm -f "$BASE" "$OVERLAY" "$OVMF_VARS_BASE" "$OVMF_VARS_RUN"
  rm -rf "$TPM_DIR"
  qemu-img create -f qcow2 "$BASE" "$VM_DISK" >/dev/null
  cp "$(ovmf_vars_template "$(find_ovmf)")" "$OVMF_VARS_BASE"
  start_swtpm
  qemu_args "$OVMF_VARS_BASE"
  qemu-system-x86_64 "${QEMU_ARGS[@]}" \
    -drive "if=virtio,format=qcow2,file=$BASE" \
    -cdrom "$ISO" \
    -drive "file=$OEMDRV,media=cdrom,readonly=on" 9>&-
  log "unattended install running (watch with VM_DISPLAY=gtk next time if curious)"
  log "waiting up to $((INSTALL_TIMEOUT / 60)) min for Anaconda to power off"
  local waited=0
  while vm_running; do
    sleep 10
    (( waited += 10 ))
    (( waited <= INSTALL_TIMEOUT )) || { stop_vm; die "install did not finish within $((INSTALL_TIMEOUT / 60)) min — retry with VM_DISPLAY=gtk to watch"; }
  done
  stop_vm # reap swtpm
  [[ -s $BASE ]] || die "install ended but $BASE is missing/empty"
  log "golden image built: $BASE ($(du -h "$BASE" | cut -f1))"
}

verify_tpm_unlock() {
  log "rebooting to verify TPM auto-unlock"
  vssh "sudo systemctl reboot" || true # connection drops mid-command
  local rc=0
  serial_expect "$BOOT_TIMEOUT" "login:" "" "Please enter passphrase" || rc=$?
  case $rc in
    0) log "TPM auto-unlock VERIFIED — booted to login with no passphrase prompt" ;;
    2) die "TPM enrollment FAILED — passphrase prompt appeared after enrollment" ;;
    *) die "no login prompt within ${BOOT_TIMEOUT}s after post-enrollment reboot" ;;
  esac
  wait_ssh
}

idempotence_pass() {
  log "idempotence pass — second run of every playbook must report changed=0"
  local pb out
  for pb in playbook_os.yml playbook_workstation.yml; do
    out=$(vssh "cd dotfiles && ansible-playbook -i hosts $pb" 2>&1) \
      || { printf '%s\n' "$out" >&2; die "$pb failed on second run"; }
    if grep -E 'changed=[1-9]' <<<"$out"; then
      printf '%s\n' "$out" | tail -20 >&2
      die "$pb is not idempotent (recap above)"
    fi
    log "$pb idempotent"
  done
}

cmd_test() {
  local quick=0
  if [[ ${1-} == --quick ]]; then quick=1; shift; fi
  (( $# == 0 )) || die "unknown argument for test: $*"
  preflight
  [[ -f $BASE ]] || die "no golden image — run: cmd/vm/vm.sh build"
  cmd_reset
  cmd_up
  sync_repo
  log "init0.sh — install ansible + galaxy collections"
  vssh "cd dotfiles && ./cmd/init0.sh"
  log "ansible-lint (inside VM)"
  vssh "sudo dnf install -y ansible-lint && cd dotfiles && ansible-lint"
  if (( quick )); then
    log "playbook_os.yml (quick: TPM enrollment off)"
    vssh "cd dotfiles && ansible-playbook -i hosts playbook_os.yml"
  else
    log "playbook_os.yml with TPM enrollment"
    vssh "cd dotfiles && ansible-playbook -i hosts playbook_os.yml -e os_enroll_tpm=true -e os_luks_passkey=$LUKS_PASSPHRASE"
  fi
  log "playbook_workstation.yml"
  # git identity injected so the git role's prompts stay quiet; the idempotence
  # pass re-runs without -e and the already-set config keeps the prompts skipped
  vssh "cd dotfiles && ansible-playbook -i hosts playbook_workstation.yml -e git_user_name=tester -e git_user_email=tester@example.com"
  if (( ! quick )); then
    verify_tpm_unlock
    idempotence_pass
  fi
  if (( quick )); then log "TEST PASSED (quick)"; else log "TEST PASSED"; fi
}

# --- subcommands --------------------------------------------------------------
usage() {
  cat >&2 <<'EOF'
usage: cmd/vm/vm.sh <subcommand>

  build         build the golden image (one-time per Fedora release, ~15 min)
  up            boot a copy-on-write overlay of the golden image
  ssh [cmd]     shell (or run a command) in the VM
  test [--quick] pristine run of all playbooks; full mode adds TPM enroll +
                reboot auto-unlock proof + idempotence pass
  reset         delete overlay + TPM state -> pristine on next up
  down          stop the VM, keep the overlay
  render-ks     render the kickstart into the cache (debug aid)
  fetch-iso     download + verify the netinst ISO (debug aid)

env: FEDORA_RELEASE (default 44), VM_SSH_PORT (default 2222),
     VM_DISPLAY=gtk to watch the console (default headless)
EOF
}

main() {
  local cmd=${1-}
  shift || true
  case $cmd in
    build) acquire_lock; cmd_build ;;
    test) acquire_lock; cmd_test "$@" ;;
    up) acquire_lock; cmd_up ;;
    ssh) cmd_ssh "$@" ;;
    down) acquire_lock; cmd_down ;;
    reset) acquire_lock; cmd_reset ;;
    render-ks) acquire_lock; preflight; render_ks; make_oemdrv; log "rendered $KS_FILE and $OEMDRV" ;;
    fetch-iso) acquire_lock; preflight; fetch_iso; log "ISO ready: $ISO" ;;
    preflight) preflight; log "preflight OK" ;;
    *) usage; exit 2 ;;
  esac
}

if [[ ${BASH_SOURCE[0]} == "$0" ]]; then main "$@"; fi
