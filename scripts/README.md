In ChromeOS Debian containers, the OpenSSL gem may not be able to find certs. This will affect the ability to auth against the Google APIs.

To test this you can run

```
bundle doctor --ssl
```
If you see the errors below, you'll need to specify the locations.
>
> Below affect only Ruby net/http connections:  
> SSL_CERT_FILE: is missing /path/to/cert.pem  
>
> SSL_CERT_DIR:  is missing /path/to/ssl/certs

To determine the location of the ssl certs, you can run
```
openssl version -a
```

In my containers, the path returned in `OPENSSLDIR` is `/usr/lib/ssl`

Running 
```
SSL_CERT_DIR=/usr/lib/ssl SSL_CERT_FILE=/usr/lib/ssl/cert.pem bundle doctor --ssl
```
Will now return okay. 
