#!/usr/bin/env bash

if ! command -v ansible &> /dev/null
then
	sudo dnf upgrade
	sudo dnf install ansible
fi

ansible-galaxy collection install community.general