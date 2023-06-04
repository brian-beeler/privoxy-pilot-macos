#
#!/bin/bash
# a script to config Privoxy for Privoxy-Pilot

echo -e "\r\n \r\n # do not edit above this line\r\n# add local configuration here\r\n# \r\n" >> /usr/local/etc/privoxy/config
cat /usr/local/etc/privoxy/config.original >> /usr/local/etc/privoxy/config
cp /usr/local/etc/privoxy/config /usr/local/etc/privoxy/config.bak