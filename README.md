# Dotfiles

## Installing
 - Run cmd/init0.sh
 - Run cmd/init1.sh
 - Run cmd/init2.sh
 - Reload/Restart your terminal (to one with updated PATH and mise env activated) if needed

## Configs for
 - Fedora

## Testing
 - cmd/vm/vm.sh runs everything in a disposable QEMU VM (btrfs-on-LUKS + emulated TPM2):
   - `cmd/vm/vm.sh build` — one-time golden image (~15 min + ISO download)
   - `cmd/vm/vm.sh test` — pristine run of all playbooks, TPM enroll + reboot auto-unlock proof, idempotence pass
   - `cmd/vm/vm.sh test --quick` — skips TPM/reboot/idempotence for faster iteration
   - `cmd/vm/vm.sh up | ssh | down | reset` — debug lifecycle
 - Host needs: qemu-system-x86_64, qemu-img, swtpm, mkisofs, socat, curl, rsync, ssh/ssh-keygen, sha256sum, flock (no libvirt/vagrant)
 - cmd/test.sh stays the on-target check (ansible-lint + check mode) for the real machine
 - Do use ansible-lint after editing anything
