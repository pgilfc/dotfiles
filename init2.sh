#!/usr/bin/env zsh

ansible-playbook -i hosts init2.yml --ask-become-pass
