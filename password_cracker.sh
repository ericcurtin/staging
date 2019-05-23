#!/bin/bash

# git clone git@github.com:glv2/bruteforce-salted-openssl.git
# ./configure 
# make

rm -rf file.enc
printf "%s" "password" > file.txt
openssl enc -aes128 -salt -in file.txt -out file.enc -pass pass:password
time ./bruteforce-salted-openssl -t 18 -l 6 -m 8 -c aes128 -d sha256 file.enc

rm -rf file.enc
printf "%s" "password" > file.txt
openssl enc -aes256 -salt -in file.txt -out file.enc -pass pass:password
time ./bruteforce-salted-openssl -t 18 -l 6 -m 8 -c aes256 -d sha256 file.enc

rm -rf file.enc
printf "%s" "password" > file.txt
openssl enc -aes512 -salt -in file.txt -out file.enc -pass pass:password
time ./bruteforce-salted-openssl -t 18 -l 6 -m 8 -c aes512 -d sha256 file.enc
