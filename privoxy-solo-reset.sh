#
#!/bin/bash
# a script to config Privoxy for Privoxy-Pilot

echo -e "\r\n \r\n # \r\n# \r\n" >> /usr/local/etc/privoxy/config
cat /usr/local/etc/privoxy/config.original >> /usr/local/etc/privoxy/config
cp /usr/local/etc/privoxy/config /usr/local/etc/privoxy/config.bak