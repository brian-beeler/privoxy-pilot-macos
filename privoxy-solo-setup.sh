#
#!/bin/bash
# a script to setup Privoxy for Privoxy-Pilot

curl -o "/usr/local/etc/privoxy/ppilot.sh" "https://raw.githubusercontent.com/brian-beeler/privoxy-pilot-macos/main/ppilot.sh"
chmod ug+x /usr/local/etc/privoxy/ppilot.sh
if [[ -f "/usr/local/etc/privoxy/config" && ! -f "/usr/local/etc/privoxy/config.original" ]]; then
  cp "//usr/local/etc/privoxy/config" "/usr/local/etc/privoxy/config.original"
  gzip "/usr/local/etc/privoxy/config.original"
  mv "/usr/local/etc/privoxy/config" "/usr/local/etc/privoxy/config.original"  
fi
echo -e "\r\n \r\n # \r\n# \r\n" >> /usr/local/etc/privoxy/config
cat /usr/local/etc/privoxy/config.original >> /usr/local/etc/privoxy/config
cp /usr/local/etc/privoxy/config /usr/local/etc/privoxy/config.bak