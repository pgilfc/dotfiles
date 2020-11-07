#!/usr/bin/env bash

if ! command -v ansible &> /dev/null
then
	sudo apt update
	sudo apt install software-properties-common
	sudo apt install ansible
fi

sudo ansible-playbook -i hosts dotfiles.yml --ask-become-pass
