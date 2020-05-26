# CertificateCheck

This script takes a file with IPs as a input and it performs the following checks on their SSL certificates:

*If the Public Key is lower than 2048 bits
*If the certificate uses weak algorithms as MD* or SHA1
*If the certificate has expired

Usage: ./CertificateCheck.sh <host_file>
