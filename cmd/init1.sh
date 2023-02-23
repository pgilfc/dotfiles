#!/usr/bin/env bash

ansible-playbook -i hosts dependencies.yml --ask-become-pass
