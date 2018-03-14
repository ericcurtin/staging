#!/bin/bash

export proxy=$1
export http_proxy=http://$proxy
export https_proxy=https://$proxy
export ftp_proxy=ftp://$proxy

