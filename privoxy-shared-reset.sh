#
#!/bin/bash
# a script to config Privoxy for Privoxy-Pilot which also allows local network clients to use Privoxy

echo -e "\r\n\r\n# \r\n# " >> /usr/local/etc/privoxy/config
echo -e "# allow privoxy to make connections with the local network" >> /usr/local/etc/privoxy/config
echo -e "listen-address $(ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}')":8118 >> /usr/local/etc/privoxy/config
echo -e "# \r\n# \r\n" >> /usr/local/etc/privoxy/config
cat /usr/local/etc/privoxy/config.original >> /usr/local/etc/privoxy/config
cp /usr/local/etc/privoxy/config /usr/local/etc/privoxy/config.bak