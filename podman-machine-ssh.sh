#!/bin/bash

podman machine start > /dev/null 2>&1
exec podman machine ssh

