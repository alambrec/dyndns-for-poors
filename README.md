dyndns-for-poors
========================================

A script to make a DIY DynDNS with a standard GoDaddy domain (compatible on every Linux/GNU System).

What it is
----------
`dyndns-for-poors` is a script to make your own DynDNS with a regular domain at GoDaddy.

For example, if you have `dyndns-example.com` domain at GoDaddy and you have a dynamic ip adress to host any service, the only solution is to have a DynDNS service.

But, with this script, you can use a regular domain at GoDaddy to associate it with your dynamic ip address. It uses the JSON GoDaddy API to update your A-Record on your DNS at every time that you have a new IP address.

Required package
----------
This script is a shell script based on `/bin/sh`.
It uses following command tools :
```
curl
dig
ping
```

It depends on several packages :
```
yum install curl bind-utils
```

How to
----------
1. Download this script on your system
2. Replace SHELL variables `API_KEY`, `API_SECRET` and `DOMAIN` in this script to match them with yours values
3. Place this script like `/root/script/godaddy_dyndns.sh`
4. Change owner and permissions script : 
```
chown root:root
chmod 700 godaddy_dyndns.sh
```
5. Launch the script to test it
```
./godaddy_dyndns.sh
```
(Optionaly) 
Set a new rule in cron to launch this script every minute for example

6. Edit `crontab` conf file to add new rule 
```
nano /etc/crontab
```
and add this line at the end of file
```
* * * * * root /root/script/resolver_dns.sh
````
7. Relaunch `crontab` service
```
systemctl restart crond.service
```

8. Enjoy ;)

Testing systems
----------
- macSierra
- CentOS 7 
