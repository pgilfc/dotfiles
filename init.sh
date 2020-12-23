#!/usr/bin/env bash

ansible-playbook -i hosts dotfiles.yml --ask-become-pass
