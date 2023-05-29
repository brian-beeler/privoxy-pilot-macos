# 
# this file contains details on modifying children of config
# https://blocklistproject.github.io/Lists/ for descriptions of various filters
# 
# to create a child config file named "default" that blocks ads,tracking,fraud,mylist: default=ads,tracking,fraud,mylist
# the new config file name will be configuration.name ie: /usr/local/etc/privoxy/configs-filters/configuration.default
# the new filter file name will be filter.name ie: /usr/local/etc/privoxy/configs-filters/filter.ads-nl
# 
default=ads,tracking,fraud,mylist
distractions=ads,tracking,fraud,mylist,distractions
uber=ads,tracking,fraud,mylist,distractions,crypto,gambling




