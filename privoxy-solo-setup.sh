#
#!/bin/bash
#a script to setup Privoxy for Privoxy-Pilot

mv /usr/local/etc/privoxy/config /usr/local/etc/privoxy/config.original
echo -e "\r\n\r\n# \r\n# \r\n# \r\n# \r\n" >> /usr/local/etc/privoxy/config
echo -e /usr/local/etc/privoxy/config.original >> /usr/local/etc/privoxy/config
cp /usr/local/etc/privoxy/config /usr/local/etc/privoxy/config.bak