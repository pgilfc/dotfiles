#!/usr/bin/env bash

ansible-lint && \
ansible-playbook -i hosts playbook_os.yml --ask-become-pass --check && \
ansible-playbook -i hosts playbook_dependencies.yml --ask-become-pass --check && \
ansible-playbook -i hosts playbook_environment.yml --ask-become-pass --check