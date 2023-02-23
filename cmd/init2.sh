#!/usr/bin/env zsh

ansible-playbook -i hosts environment.yml --ask-become-pass
