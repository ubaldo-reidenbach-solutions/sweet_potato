#!/bin/env bash
openssl genrsa -out rocketchat.rsa 8192
openssl req -key rocketchat.rsa -new -out rocketchat.csr
openssl x509 -signkey rocketchat.rsa -in rocketchat.csr -req -days 365 -out rocketchat.pem
