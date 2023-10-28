#!/usr/bin/env bash

ansible-lint && \
ansible-playbook -i hosts dependencies.yml --ask-become-pass --check && \
ansible-playbook -i hosts environment.yml --ask-become-pass --check