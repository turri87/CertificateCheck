#!/bin/bash

if [[ "$#" -ne 1 ]]; then
        echo "Usage: ./`basename $0` <host_file>"
    echo
    exit 1
fi


if [[ ! -e output.txt ]]; then
    touch output.txt
fi

currentDate=$(date)
echo "Results - $currentDate" > output.txt
echo "---------------------------------------------------" >> output.txt


for ip in $(cat "$1"); do

        echo "[+] Checking host $ip"
        echo "[*] Host: $ip" >> output.txt
		
        if [[ $(fping $ip) != *"alive"* ]]; then
                echo "[!] Host not alive" >> output.txt
                echo "---------------------------------------------------" >> output.txt
                echo "---------------------------------------------------" >> output.txt
                continue
        fi

        certificate=$(echo "\n" | openssl s_client -servername $ip -showcerts -connect $ip:443 2>/dev/null)

        if [[ -z "$certificate" ]]; then
                echo "[!] Certificate can't be checked" >> output.txt
                echo "---------------------------------------------------" >> output.txt
                echo "---------------------------------------------------" >> output.txt
                continue
        fi

        publicKey=$(echo "$certificate" | grep "Server public key" | cut -d " " -f 5)
        signature=$(echo "$certificate" | grep "Peer signing digest" | cut -d " " -f 4)
        expirationDate=$(echo "$certificate" | openssl x509 -noout -dates 2>/dev/null | grep "notAfter" | cut -d "=" -f 2)
        hasExpired=$(echo "$certificate" | openssl x509 -checkend 0 -noout)

        if [[ $publicKey -lt 2048 ]]; then
                echo "[-] Small Public Key: $publicKey" >> output.txt
        fi

        if [[ $signature == *"SHA1"* ]] || [[ $signature == *"MD"* ]]; then
                echo "[-] Weak Signature: $signature" >> output.txt
        fi

        if [[ $hasExpired != *"not"* ]]; then
                echo "[-] Certificate expired: $expirationDate" >> output.txt
        fi

        echo "---------------------------------------------------" >> output.txt
        echo "---------------------------------------------------" >> output.txt
done