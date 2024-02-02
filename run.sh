#!/bin/bash

sudo qemu-system-x86_64 -bios /usr/share/ovmf/OVMF.fd -m 830196K $1
