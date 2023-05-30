#!/bin/bash
# copyright 2023 Brian Beeler under CC BY-SA license
#
# This project is still in its very beginnings and only made public for developement purposes. 
# Do not use anything here until this notice is remove. If you do it will break things.
# 

# date and date sensitive values
date_epoch=$(date +%s)
date_stamp_long=$(date -r "$date_epoch" +"%a %b %d %Y %H:%M:%S %Z")
date_stamp=$(date -r "$date_epoch" +"%a %b %d %H:%M:%S")

# checking for log file exsistance
if [ ! -f "/var/log/privoxy.log" ]; then
    touch "/var/log/privoxy.log"
    chmod a+rw "/var/log/privoxy.log"
    echo "$date_stamp_long     created log file"  >> /var/log/privoxy.log
fi

# checks for /usr/local/etc/privoxy/filters/ and creates if not found
if [ ! -d "/usr/local/etc/privoxy/filters/" ]; then
    mkdir -p "/usr/local/etc/privoxy/filters/"
fi

# functions:
#   blpfl(): blp filter lists: download and edit blp filter lists
#  config():      config list: list and choose .config list
#      ct():       color text: colorizes text in ANSI RGB
#      dd():  date difference: calcutates the amount of time since a file has been modified
#      ft():  filter template: a template for creating new, custom filters lists
#      lr():         log read: displays log files with ANSI colors
#      lw():        log write: write log entries
#  status():   current status: displays privoxy status

# download and create blp filter list
function blpfl() {
  # $1 filter to download ie: "ads" would download "https://blocklistproject.github.io/Lists/alt-version/ads-nl.txt"

  if [ ! -d "/usr/local/etc/privoxy/filters/blp" ]; then
    mkdir -p "/usr/local/etc/privoxy/filters/blp"
  fi

  local filter_file_name="/usr/local/etc/privoxy/filters/blp/$1"
  # file age or if file is missing set Unix epoch date at 0 (1970-01-01 00:00:00)
  local filter_file_date=$(stat -f "%m" "$filter_file_name" 2>/dev/null || echo 0)
  # 604800 = 7 days
  if [ $((date_epoch - filter_file_date)) -gt 604800 ]; then
    echo -e "$(ct "downloading" "g") $(ct "$1" "b")"
    curl --no-progress-meter -o "/usr/local/etc/privoxy/filters/blp/$1-nl.txt" "https://blocklistproject.github.io/Lists/alt-version/$1-nl.txt"
    touch "$filter_file_name"
    echo "# $1" >> $filter_file_name
    echo "# created: $date_stamp_long" >> $filter_file_name
    echo "# " >> $filter_file_name
    echo "{ +block{site found in $filter_file_name.} }" >> $filter_file_name
    echo "# " >> $filter_file_name
    echo "# " >> $filter_file_name
    echo "  " >> $filter_file_name
    cat "/usr/local/etc/privoxy/filters/blp/$1-nl.txt" >> $filter_file_name
    echo "$date_stamp_long     filter created $filter_file_name" >> /var/log/privoxy.log
    rm "/usr/local/etc/privoxy/filters/blp/$1-nl.txt"
  fi
}
# end blpfl()

# config
# TODO: error checking on privoxy.sh config set filter_group_no_exist
#       right now on error no block lists are added
function config() {
# checks for config.bak     and creates one if not found
# options -c restore        restore config from config.bak. retores config to a vanilla state
#         -c backup         backup config config.bak. use after editing config
#         -c set <config>   sets a custom config file in play
#         -c filters        updates blp filter lists
# 
# TODO: set = cp config.bak config, read config.mod, choose line, write:
#   actionsfile /usr/local/etc/privoxy/filters/(name).filter to top of config
# 
local blp_fl=("abuse" "ads" "crypto" "drugs" "everything" "facebook" "fraud" "gambling" "malware" "phishing" "piracy" "porn" "ransomware" "redirect" "scam" "tiktok" "torrent" "tracking")
# 
# checks for config.bak and creates if not found
if [ ! -f "/usr/local/etc/privoxy/config.bak" ]; then
    cp "/usr/local/etc/privoxy/config" "/usr/local/etc/privoxy/config.bak"
    chmod a+rw "/usr/local/etc/privoxy/config.bak"
    echo "$date_stamp_long     config.bak created"  >> /var/log/privoxy.log
fi
# checks for config.mod and creates if not found
if [ ! -f "/usr/local/etc/privoxy/config.mod" ]; then
  echo -e "$(ct "getting" "g") $(ct "config.mod" "b")"
  curl --no-progress-meter -o "/usr/local/etc/privoxy/config.mod" "https://raw.githubusercontent.com/brian-beeler/privoxy-pilot-macos/main/config.mod"
fi
# checks for mylist filter list and creates if not found
if [ ! -f "/usr/local/etc/privoxy/filters/mylist" ]; then
  echo -e "$(ct "getting" "g") $(ct "filters/mylist" "b")"
  curl --no-progress-meter -o "/usr/local/etc/privoxy/filters/mylist" "https://raw.githubusercontent.com/brian-beeler/privoxy-pilot-macos/main/filters/mylist"
fi
# checks for distractions filter list and creates if not found
if [ ! -f "/usr/local/etc/privoxy/filters/distractions" ]; then
  echo -e "$(ct "getting" "g") $(ct "filters/distractions" "b")"
  curl --no-progress-meter -o "/usr/local/etc/privoxy/filters/distractions" "https://raw.githubusercontent.com/brian-beeler/privoxy-pilot-macos/main/filters/distractions"
fi

# if ./privoxy.sh config list is called
if [[ "$2" = "list" ]]; then
  #TODO: everything 

  #read config.mod for groups
  #display as: group: filter, filter, filter, filter

  # reads config.mod and saves filters to $filter_list
  while IFS= read -r line; do
    if [[ $line =~ ^[a-zA-Z0-9] ]]; then
      line_tag=$(echo "$line" | awk -F= '{print $1}')
      IFS=',' read -ra array <<< "$(echo "$line" | awk -F= '{print $2}')"
      joined_elements=$(IFS=,; echo "${array[*]}")
      echo "$(ct "$line_tag" "b"): $(ct "$joined_elements" "g")"
    fi
  done < "/usr/local/etc/privoxy/config.mod"

fi

# if ./privoxy.sh config set <filter group> is called
if [ "$2" = "set" ] && [ -n "$3" ]; then
  local filter_list=()

  # copies listing of file names in /usr/local/etc/privoxy/filters/ to filters_dir_files
  local declare filters_dir_files
  dir_list=$(ls -p /usr/local/etc/privoxy/filters/ | grep -v /)  
  for item in $dir_list; do
    filters_dir_files+=("$item")
  done
  #echo "filters_dir_files: ${filters_dir_files[@]}"

  # reads config.mod and saves filters to $filter_list
  while IFS= read -r line; do
    if [[ $line == \#* ]]; then
      continue
    fi
    if [[ $line == $3* ]]; then
      value=${line#*=}
      filter_list+=("$value")
    fi
  done < "/usr/local/etc/privoxy/config.mod"

  #cleans filter_list of \r
  filter_list=$(echo "$filter_list" | tr -d '\r')
  # write to a clean config
  echo "# $date_stamp_long     $3 active" >> "/usr/local/etc/privoxy/config.tmp"
  echo "# " >>  "/usr/local/etc/privoxy/config.tmp"
  IFS=',' read -ra filters <<< "$filter_list"
  for filter in "${filters[@]}"; do
    # if filter is in blp filter list 
    if [[ " ${blp_fl[@]} " =~ " $filter " ]]; then
      blpfl $filter
      echo "actionsfile /usr/local/etc/privoxy/filters/blp/$filter" >> "/usr/local/etc/privoxy/config.tmp"
    fi
    # 
    if [[ " ${filters_dir_files[@]} " =~ " $filter " ]]; then
      echo "actionsfile /usr/local/etc/privoxy/filters/$filter" >> "/usr/local/etc/privoxy/config.tmp"
    fi

  done
  echo " " >> "/usr/local/etc/privoxy/config.tmp"
  echo " " >> "/usr/local/etc/privoxy/config.tmp"
  cat "/usr/local/etc/privoxy/config.bak" >> "/usr/local/etc/privoxy/config.tmp"
  mv /usr/local/etc/privoxy/config.tmp /usr/local/etc/privoxy/config
  lw "set configuration $3 active"
  brew services restart privoxy
  lw "restart"
fi 
}
# end blpfl()


# color text
function ct() {
    # $1=input text, $2=color
    if [[ $2 == "r" ]]; then
        echo -e "\033[31m$1\033[0m"
    elif [[ $2 == "g" ]]; then
        echo -e "\033[32m$1\033[0m"
    elif [[ $2 == "b" ]]; then
        echo -e "\033[34m$1\033[0m"
    elif [[ $2 == "c" ]]; then
        echo -e "\033[36m$1\033[0m"
    elif [[ $2 == "m" ]]; then
        echo -e "\033[35m$1\033[0m"
    elif [[ $2 == "y" ]]; then
        echo -e "\033[33m$1\033[0m"
    elif [[ $2 == "rb" ]]; then
        echo -e "\033[31;5m$1\033[0m"
    else
        echo "$1"
    fi
}
# end ct()

# date difference
function dd() {
    local file="$1"
    local file_date=$(date -r "$file" +%s)
    if [ -e "$file" ]; then
      local diff=$((date_epoch - file_date))
      local s=$(printf "%02d" $((diff % 60)))
      local m=$(printf "%02d" $((diff % (60 * 60) / 60)))
      local h=$(printf "%02d" $((diff % (60 * 60 * 24) / (60 * 60))))
      local d=$(printf "%02d" $((diff / (60 * 60 * 24))))
      if [ "$d" -gt 0 ]; then
        echo "$d:$h:$m:$s"
      elif [ "$h" -gt 0 ]; then
        echo "$h:$m:$s"
      else
        echo "$m:$s"
      fi
    else
      echo "File $file does not exist."
    fi
}
# end dd()

# 
function ft() {
  # $1 is filter/file name
  # copies listing of file names in /usr/local/etc/privoxy/filters/ to filters_dir_files
  local declare filters_dir_files
  dir_list=$(ls -p /usr/local/etc/privoxy/filters/ | grep -v /)  
  for item in $dir_list; do
    filters_dir_files+=("$item")
  done
  filters_dir_files+=("blp")
  match_found=false
  if [ -n "$1" ]; then
    for item in "${filters_dir_files[@]}"; do
    if [[ "$item" == "$1" ]]; then
      match_found=true
      break
    fi
    done
    if $match_found; then
      echo $(ct "There is already a filter list or folder named $1." "y")
    else
      echo "# /usr/local/etc/privoxy/filters/$1"  >> /usr/local/etc/privoxy/filters/$1
      echo "# "  >> /usr/local/etc/privoxy/filters/$1
      echo "# this file contains a group of user selected sites to block"  >> /usr/local/etc/privoxy/filters/$1
      echo "# "  >> /usr/local/etc/privoxy/filters/$1
      echo "# details for the privoxy "blocked" page to display on why a site was blocked:"  >> /usr/local/etc/privoxy/filters/$1
      echo "{ +block{site found in /usr/local/etc/privoxy/filters/$1.} }"  >> /usr/local/etc/privoxy/filters/$1
      echo "# "  >> /usr/local/etc/privoxy/filters/$1
      echo "# .example.com will block all sites ending in that domain"  >> /usr/local/etc/privoxy/filters/$1
      echo "# www.example.com will block just that site and not others in that domain"  >> /usr/local/etc/privoxy/filters/$1
      echo "# "  >> /usr/local/etc/privoxy/filters/$1
      echo ".example.com"  >> /usr/local/etc/privoxy/filters/$1
      echo $(ct "/usr/local/etc/privoxy/filters/$1 created" "g")
    fi
    else
      echo $(ct "Please supply a filter list name" "y")
  fi
}
# end ft()

# log read. displays log files in ANSI colors
function lr() {
  # $1: "0" = no header, "1" = header
  local log_file="/var/log/privoxy.log"
  log_line_count=$(wc -l < "$log_file")
  if (( log_line_count > 10 )); then
    log_line_count=10
  fi
  
  local log=$(tail -n $log_line_count $log_file)

  for ((i=1; i<=$log_line_count; i++)); do
    line=$(echo "$log" | awk "NR==$i")
    local sl="$line"
    local sl_date=$(ct "${sl:0:10} ${sl:16:8}" "y")

    if [[ $sl == *"start" ]]; then
      local sl_reason=$(ct "start" "g")
    elif [[ $sl == *"restarted" ]]; then
      local sl_reason=$(ct "restarted" "g")
    elif [[ $sl == *"stop" ]]; then
      local sl_reason=$(ct "stop" "rb")
    elif [[ $sl == *"status error" ]]; then
      local sl_reason="status $(ct "error" "rb")"
    elif [[ $sl == *"status started" ]]; then
      local sl_reason="status $(ct "started" "g")"
    elif [[ $sl == *"filter.list created" ]]; then
      local sl_reason="$(ct "filter.list" "b") $(ct "created" "g")"
    elif [[ $sl == *".config active" ]]; then
      local sl_config=$(echo "$sl" | awk -F 'privoxy ' '{print $2}' | awk -F ' active' '{print $1}')
      local sl_reason="status $(ct "$sl_config" "b") $(ct "active" "g")"
    elif [[ $sl == *"set configuration"* && $sl == *active ]]; then
      local sl_reason="${sl:41:17} $(ct "${sl:59:$((${#sl}-6-60))}" "b") $(ct "${sl:${#sl}-6:8}" "g")"
    else
      local sl_reason=""
    fi
    
    if [[ $1 == 0 ]]; then
      sl="$sl_date privoxy $sl_reason"
    elif [[ $i -eq 1 && $1 == 1 ]]; then
      sl="         log: $sl_date privoxy $sl_reason"
    elif [[ $i -gt 1 && $1 == 1 ]]; then
      sl="              $sl_date privoxy $sl_reason"
    fi

    echo -e "$sl"
  done
}
# end lr()

# log write. writes a log entry
function lw() {
  # $1: text
  echo "$date_stamp_long     privoxy $1"  >> /var/log/privoxy.log
}
# end lw()

# display status
function status() {
  local config_head=$(head -n 1 "/usr/local/etc/privoxy/config")
  local filter_group="${config_head:35:$((${#config_head} - 6 - 36))}"
# Read the file line by line
while IFS= read -r line
do
  # Check if the line starts with the filter set
  if [[ "$line" == "$filter_group"* ]]; then
    local filter_list="${line#"$filter_group="}"
    break
  fi
done < "/usr/local/etc/privoxy/config.mod"
output=$(brew services list | grep privoxy)
if [[ $output == *"started"* ]]; then
  pid=$(ps xa | grep "/usr/local/opt/privoxy/sbin/privoxy --no-daemon /usr/local/etc/privoxy/config" | grep -v grep | awk '{print $1}')
  up_since=$(ps -p $pid -o lstart= | awk '{print $1,$2,$3,$4}')
  up_time=$(ps -p $pid -o etime= )
  config_date=$(ls -lD "%a %b %d %H:%M:%S" /usr/local/etc/privoxy/config | awk '{print $6,$7,$8,$9}')
  echo -e "         pid: $(ct "$pid" "y")"
  echo -e "          up: $(ct "$up_since" "y") ($(ct "$up_time" "y"))"
  echo -e "      config: $(ct "$config_date" "y") ($(ct "$(dd "/usr/local/etc/privoxy/config")" "y"))"
  echo -e "filter group: $(ct "$filter_group" "b")"
  echo -e "     filters: $(ct "$filter_list" "b")"  
  echo "              -------------------"
  lr 1
elif [[ $output == *"none"* ]]; then
  #echo -e "OUTPUT: $output"
  #echo -e "$(color_text "$output" "error" "red")"
  #echo -e "$date_stamp     privoxy status $(ct "error" "r")" >> /var/log/privoxy.log
  lw "status error"
else
  echo -e "$(ct "$output" "r")"
fi
}
# status()


# main (for lack of better words)

# start
if [[ $1 == "start" ]]; then
  brew services start privoxy
  lw "start" 

# stop
elif [[ $1 == "stop" ]]; then
  brew services stop privoxy
  lw "stop"
 
# restart
elif [[ $1 == "restart" ]]; then
  brew services restart privoxy
  lw "restart" 

# status
elif [[ $1 == "-s" ]] || [[ $1 == "status" ]]; then
  status

# config
elif [ "$1" = "config" ]; then
  config $1 $2 $3

# display log file
elif [[ $1 == "log" ]]; then
  lr 0

# filter template
elif [[ $1 == "filter" ]]; then
  ft $2

# 
else
  echo "usage: ./privoxy.sh [start|stop|restart|status|config|filter|log]"
  echo "  start                   start server"
  echo "  stop                    stop server"
  echo "  restart                 restart"
  echo "  status                  display privoxy status"
  echo "  config list             list filter groups"
  echo "  config set <group>      set filter group"
  echo "  filter <name>           create new filter list"
  echo "  log                     display log file"
fi