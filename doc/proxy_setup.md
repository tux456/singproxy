



# Configure /etc/ssh/sshd_config

Port 12345
PasswordAuthentication no
ChallengeResponseAuthentication no
UsePAM yes
X11Forwarding no
PrintMotd no
AcceptEnv LANG LC_*
GatewayPorts yes
StreamLocalBindMask 0111
StreamLocalBindUnlink yes
HostbasedAuthentication yes
Match User *,!ubuntu,!admin_user
  ForceCommand /bin/false


# Add public "client" server keys in shosts.equiv
````
for i in server1.com server2.com $(dig +short $i);done >/etc/ssh/shosts.equiv

for i in $(cat /etc/ssh/shosts.equiv) ;do ssh-keyscan $i;done>/etc/ssh/ssh_known_hosts 
````



# Configure NGNIX
```
apt install nginx
ln -s /etc/nginx/sites-available/ccproxy /etc/nginx/sites-enabled/ccproxy
rm /etc/nginx/sites-enabled/default
mkdir /etc/ssl/nginx

setfacl -d -m g:www-data:rwx /home
```




# /etc/nginx/sites-available/ccproxy
```
server {
    listen 443;
    client_max_body_size 20g;

    types_hash_max_size 2048;
    # server_tokens off;

    server_name ~^(?<user>.+)-(?<subdomain>.+)\.myproxy\.genap\.ca$;

    ssl_certificate /etc/ssl/nginx/cert.pem;
    ssl_certificate_key /etc/ssl/nginx/key.pem;
    ssl on;
    ssl_session_cache  builtin:1000  shared:SSL:10m;
    ssl_protocols  TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers HIGH:!aNULL:!eNULL:!EXPORT:!CAMELLIA:!DES:!MD5:!PSK:!RC4;
    ssl_prefer_server_ciphers on;


   location / {
        proxy_pass http://unix:/home/$user/$subdomain.sock;
        proxy_set_header   X-Forwarded-Host $host;
        proxy_set_header Host $host;
        proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;

        proxy_set_header X-Forwarded-For $remote_addr;

        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 90;

    }

}
```



# Configure SSL cert with ACME DNS  https://github.com/Neilpang/acme.sh

```
curl https://get.acme.sh | sh

curl -s -X POST http://myacme_service.com:8080/register

export ACMEDNS_UPDATE_URL="http://myacme_service.com:8080/update"
export ACMEDNS_USERNAME=""
export ACMEDNS_PASSWORD=""
export ACMEDNS_SUBDOMAIN=""
````

Need to add a CNAME "_acme-challenge.myproxy.genap.ca" pointing to "$ACMEDNS_DOMAIN.myacme_service.com"


Generate the cert ...

```
/root/.acme.sh/acme.sh --issue --dns dns_acmedns -d myproxy.genap.ca -d *.myproxy.genap.ca --key-file /etc/ssl/nginx/key.pem --fullchain-file /etc/ssl/nginx/cert.pem --reloadcmd "service nginx force-reload" --accountemail myemail@domain.com
```



# LDAP & PAM

You configure proxy with same authentication system as client with LDAP or other ...

```
cat >>/etc/pam.d/common-session <<fin666
session    required    pam_mkhomedir.so skel=/etc/skel/ umask=0027
fin666
```


