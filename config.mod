# /usr/local/etc/privoxy/config.mod
# this file contains user instrustion on modifying /usr/local/etc/privoxy/config
#
# to create a filter configuration group named "default" that blocks sites found in:
#   ads, tracking, fraud from the block list project
#   "mylist" in /usr/local/etc/privoxy/filters
#   add the following line:
#     default=ads,tracking,fraud,mylist,blah
#
# reserved names for blp (block list project) filters: 
#   abuse, ads, crypto, drugs, everything, facebook, fraud, gambling, malware, phishing
#   piracy, porn, ransomware, redirect, scam, tiktok, torrent, tracking
# see https://blocklistproject.github.io/Lists/ for descriptions of their various filters
# any filters in /usr/local/etc/privoxy/filters with a blp reserved name will be ignored
# 
# do not edit any files in /usr/local/etc/privoxy/filters/blp/
# add custom lists to /usr/local/etc/privoxy/filters/
# 
default=ads,tracking,fraud,mylist,blah
distractions=ads,tracking,fraud,mylist,distractions
uber=ads,tracking,fraud,mylist,distractions,crypto,gambling
