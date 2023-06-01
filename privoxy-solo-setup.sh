#
#!/bin/bash
#a script to setup Privoxy for Privoxy-Pilot

curl -o "/usr/local/etc/privoxy/ppilot.sh" "https://raw.githubusercontent.com/brian-beeler/privoxy-pilot-macos/main/ppilot.sh"
chmod og+x /usr/local/etc/privoxy/ppilot.sh
mv /usr/local/etc/privoxy/config /usr/local/etc/privoxy/config.original
echo -e "\r\n\r\n# \r\n# \r\n# \r\n# \r\n" >> /usr/local/etc/privoxy/config
echo -e /usr/local/etc/privoxy/config.original >> /usr/local/etc/privoxy/config
cp /usr/local/etc/privoxy/config /usr/local/etc/privoxy/config.bak