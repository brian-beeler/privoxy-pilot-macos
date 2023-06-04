#
#!/bin/bash
# a script to setup Privoxy for Privoxy-Pilot which also allows local network clients to use Privoxy

curl -o "/usr/local/etc/privoxy/ppilot.sh" "https://raw.githubusercontent.com/brian-beeler/privoxy-pilot-macos/main/ppilot.sh"
chmod ug+x /usr/local/etc/privoxy/ppilot.sh
if [[ -f "/usr/local/etc/privoxy/config" && ! -f "/usr/local/etc/privoxy/config.original" ]]; then
  cp "/usr/local/etc/privoxy/config" "/usr/local/etc/privoxy/config.original"
  gzip "/usr/local/etc/privoxy/config.original"
  mv "/usr/local/etc/privoxy/config" "/usr/local/etc/privoxy/config.original"  
fi
echo -e "\r\n \r\n # do not edit above this line\r\n# add configuration options here\r\n# \r\n" >> /usr/local/etc/privoxy/config
echo -e "# allow privoxy to make connections with the local network" >> /usr/local/etc/privoxy/config
echo -e "listen-address $(ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}')":8118 >> /usr/local/etc/privoxy/config
echo -e "# \r\n# \r\n" >> /usr/local/etc/privoxy/config
cat /usr/local/etc/privoxy/config.original >> /usr/local/etc/privoxy/config
cp /usr/local/etc/privoxy/config /usr/local/etc/privoxy/config.bak