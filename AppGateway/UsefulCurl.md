# Useful Curl Commands

**Note: There are some commands that work better with the Linux version of curl. If you are running on Windows, I would suggest leveraging the Windows Subsystem for Linux**

# Check Certificate on web page
```bash
Curl -Lkv  https://<URL>
```
# Check web site with other host name
Use this command to test out an web server and pass along a different host name.
```bash
curl -H "Host: <hostname>" -Lkv https://<IPAddress>/<restofURL>
```
# Check cert with known cert chain
```bash
Curl --cacert certfile.cert http://<URL>
```
# Check a web page with a bad cert
```bash
Curl -insecure -L https://<URL>
```
# Test web site using SNI
Use this command to test out a web server that is using SNI to test out the different host names to test. Swap out:
* FQNtoTest = The fully qualified domain name you wish to test against.
* IptoResolveTo = The IP address to the web server that you want to test
```bash
curl -L --resolve <FQDNtoTest>:443:<IPtoResolveTo> https://<FQDNtoTest>/app3/index.htm
```

