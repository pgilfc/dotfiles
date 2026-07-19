#!/usr/bin/env bash

ansible-playbook -i hosts playbook_workstation.yml --ask-become-pass
