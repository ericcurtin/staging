#!/bin/bash

set -e

sudo nmap --host-timeout 1s -sS -p 22 192.168.1.0/24 | grep report

