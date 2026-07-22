#!/usr/bin/env bash

ansible-playbook -i hosts playbook_os.yml --ask-become-pass
# could also be
# ansible-playbook -i hosts playbook_os.yml --ask-become-pass -e os_enroll_tpm=true
# to enroll TPM on the OS level
