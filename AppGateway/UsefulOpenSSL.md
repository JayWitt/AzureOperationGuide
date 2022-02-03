# Useful OpenSSL Commands

**Note: There are some commands that work better with the Linux version of openssl. If you are running on Windows, I would suggest leveraging the Windows Subsystem for Linux**

# Export private key
Example from [here](https://wiki.cac.washington.edu/display/infra/Extracting+Certificate+and+Private+Key+Files+from+a+.pfx+File).
```bash
openssl pkcs12 -in certname.pfx -nocerts -out key.pem -nodes
```
# Export certificate from pfx file
Example from [here](https://wiki.cac.washington.edu/display/infra/Extracting+Certificate+and+Private+Key+Files+from+a+.pfx+File).
```bash
openssl pkcs12 -in certname.pfx -nokeys -out cert.pem
```
# Remove passphrase from private key
Exampe from [here](https://wiki.cac.washington.edu/display/infra/Extracting+Certificate+and+Private+Key+Files+from+a+.pfx+File).
```bash
openssl rsa -in key.pem -out server.key
```
# View certificates from web page
```bash
openssl s_client -showcerts -connect <FQDN>:443
```
# View details of a certificate files
```bash
openssl x509 -in <certfilename> -noout -text
```
# View certificate issuer
```bash
openssl x509 -in server.cer -noout -issuer
```
# Check Certificate Chain
```bash
openssl crl2pkcs7 -nocrl -certfile <CERfile> | openssl pkcs7 -print_certs -noout
```
# Merge Public and Private key
Example from [here](https://stackoverflow.com/questions/808669/convert-a-cert-pem-certificate-to-a-pfx-certificate).
```bash
openssl pkcs12 -inkey bob_key.pem -in bob_cert.cert -export -out bob_pfx.pfx
```
# Check web address with a different host name
```bash
openssl s_client -connect <serverToConnectTo>:443 -servername <hostnameToPresentInHeaders> -showcerts
```
# Check certs against full cert chain
Example from [here](https://security.stackexchange.com/questions/142159/how-to-get-openssl-to-use-a-cert-without-specifying-it-via-cafile).
```bash
openssl s_client -quiet -connect <FQDN>:443 -CApath /dev/null
```
