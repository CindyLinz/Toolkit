#!/usr/bin/bash

domain=$1
port=${2-443}

openssl s_client -connect $domain:$port -servername $domain 2>/dev/null | openssl x509 -noout -dates
