#!/usr/bin/env bash

ansible-playbook -i hosts playbook_dependencies.yml --ask-become-pass
