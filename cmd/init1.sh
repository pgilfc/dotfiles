#!/usr/bin/env bash

ansible-playbook -i hosts playbook_os.yml --ask-become-pass
