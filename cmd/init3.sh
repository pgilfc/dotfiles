#!/usr/bin/env zsh

ansible-playbook -i hosts playbook_environment.yml --ask-become-pass
