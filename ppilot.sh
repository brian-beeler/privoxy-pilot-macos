#!/bin/bash

# copyright © Brian Beeler 2023 under CC BY-SA license
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
# Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
# Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
# Neither the name of copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# This project is still in its very beginnings and only made public for developement purposes. 
# Do not use anything here until this notice is remove. If you do it will break things.

# functions:
#   blpfl(): blp filter lists: download and edit blp filter lists
#  config():      config list: list and choose .config list
#      ct():       color text: colorizes text in ANSI RGB
#      dd():  date difference: calcutates the amount of time since a file has been modified
#      ft():  filter template: a template for creating new, custom filters lists
#      lr():         log read: displays log files with ANSI colors
#      lw():        log write: write log entries
#      pp():  privoxy process: start, restart or stop the privoxy process
#  status():   current status: displays privoxy status

# function blpfl(): download and create blp filter list
function blpfl() {
  local filter_file_name="$filters_blp_dir/$1"
  # file age or if file is missing set Unix epoch date at 0 (1970-01-01 00:00:00)
  local filter_file_date=$(stat -f "%m" "$filter_file_name" 2>/dev/null || echo 0)
  # 604800 = 7 days
  if [ $((date_epoch - filter_file_date)) -gt 604800 ]; then
    echo -e "$(ct "downloading" "g") $(ct "$1" "b")"
    curl --no-progress-meter -o "$filters_blp_dir/$1-nl.txt" "https://blocklistproject.github.io/Lists/alt-version/$1-nl.txt"
    touch "$filter_file_name"
    echo "# $1" >> $filter_file_name
    echo "# created: $date_stamp_long" >> $filter_file_name
    echo "# " >> $filter_file_name
    echo "{ +block{site found in $filter_file_name.} }" >> $filter_file_name
    echo "# " >> $filter_file_name
    echo "# " >> $filter_file_name
    echo "  " >> $filter_file_name
    cat "$filters_blp_dir/$1-nl.txt" >> $filter_file_name
    echo "$date_stamp_long     filter created $filter_file_name" >> $log_file
    rm "$filters_blp_dir/$1-nl.txt"
  fi
}
# end blpfl()

# function config(): manipulates config file
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
#   actionsfile $filters_dir/(name) to top of config
# 
local blp_fl=("abuse" "ads" "crypto" "drugs" "everything" "facebook" "fraud" "gambling" "malware" "phishing" "piracy" "porn" "ransomware" "redirect" "scam" "tiktok" "torrent" "tracking")
# 
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
  done < $config_mod_file

fi

# if ./privoxy.sh config set <filter group> is called
if [ "$2" = "set" ] && [ -n "$3" ]; then
  local filter_list=()

  # copies listing of file names in $filters_dir to filters_dir_file_names
  local declare filters_dir_file_names
  dir_list=$(ls -p $filters_dir | grep -v /)  
  for item in $dir_list; do
    filters_dir_file_names+=("$item")
  done
  #echo "filters_dir_file_names: ${filters_dir_file_names[@]}"

  # reads config.mod and saves filters to $filter_list
  while IFS= read -r line; do
    if [[ $line == \#* ]]; then
      continue
    fi
    if [[ $line == $3* ]]; then
      value=${line#*=}
      filter_list+=("$value")
    fi
  done < $config_mod_file

  #cleans filter_list of \r
  filter_list=$(echo "$filter_list" | tr -d '\r')
  # write to a clean config
  echo "# $date_stamp_long     $3 active" >> $config_tmp_file
  echo "# " >>  $config_tmp_file
  IFS=',' read -ra filters <<< "$filter_list"
  for filter in "${filters[@]}"; do
    # if filter is in blp filter list 
    if [[ " ${blp_fl[@]} " =~ " $filter " ]]; then
      blpfl $filter
      echo "actionsfile $filters_blp_dir/$filter" >> $config_tmp_file
    fi
    # 
    if [[ " ${filters_dir_file_names[@]} " =~ " $filter " ]]; then
      echo "actionsfile $filters_dir/$filter" >> $config_tmp_file
    fi

  done
  echo " " >> $config_tmp_file
  echo " " >> $config_tmp_file
  echo " " >> $config_tmp_file
  cat $config_bak_file >> $config_tmp_file
  mv $config_tmp_file $config_file
  lw "config $3 active"
  pp restart
  lw "restart"
fi 
}
# end blpfl()


# function ct(): color text with ANSI colors
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

# function dd(): age of file or date difference between now and date file was created
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

# function ft(): filter file template
function ft() {
  # $1 is filter/file name
  # copies listing of file names in $filters_dir to filters_dir_file_names
  local declare filters_dir_file_names
  dir_list=$(ls -p $filters_dir | grep -v /)  
  for item in $dir_list; do
    filters_dir_file_names+=("$item")
  done
  filters_dir_file_names+=("blp")
  match_found=false
  if [ -n "$1" ]; then
    for item in "${filters_dir_file_names[@]}"; do
    if [[ "$item" == "$1" ]]; then
      match_found=true
      break
    fi
    done
    if $match_found; then
      echo $(ct "There is already a filter list or folder named $1." "y")
    else
      echo "# $filters_dir/$1"  >> $filters_dir/$1
      echo "# "  >> $filters_dir/$1
      echo "# this file contains a group of user selected sites to block"  >> $filters_dir/$1
      echo "# "  >> $filters_dir/$1
      echo "# details for the privoxy "blocked" page to display on why a site was blocked:"  >> $filters_dir/$1
      echo "{ +block{site found in $filters_dir/$1.} }"  >> $filters_dir/$1
      echo "# "  >> $filters_dir/$1
      echo "# .example.com will block all sites ending in that domain"  >> $filters_dir/$1
      echo "# www.example.com will block just that site and not others in that domain"  >> $filters_dir/$1
      echo "# "  >> $filters_dir/$1
      echo ".example.com"  >> $filters_dir/$1
      echo $(ct "$filters_dir/$1 created" "g")
    fi
    else
      echo $(ct "Please supply a filter list name" "y")
  fi
}
# end ft()

# function lr(): log read. displays log files in ANSI colors
function lr() {
  # $1: "0" = no header, "1" = header
  # 
  # 
  log_file_line_count=$(wc -l < "$log_file")
  if (( log_file_line_count > 10 )); then
    log_file_line_count=10
  fi
  
  local log=$(tail -n $log_file_line_count $log_file)

  for ((i=1; i<=$log_file_line_count; i++)); do
    line=$(echo "$log" | awk "NR==$i")
    local sl="$line"
    local sl_date=$(ct "${sl:0:10} ${sl:16:8}" "y")
    if [[ $sl == *"restart" ]]; then
      local sl_reason=$(ct "restart" "g")
    elif [[ $sl == *"start" ]]; then
      local sl_reason=$(ct "start" "g")
    elif [[ $sl == *"stop" ]]; then
      local sl_reason=$(ct "stop" "rb")
    elif [[ $sl == *"status error" ]]; then
      local sl_reason="status $(ct "error" "rb")"
    elif [[ $sl == *"config.bak created" ]]; then
      local sl_reason="$(ct "config.bak" "b") $(ct "created" "g")"
    elif [[ $sl == *"config"* && *"active" ]]; then
      local sl_center="${sl#*config}" && sl_center="${sl_center%active*}"
      local sl_reason="config $(ct $sl_center "b") $(ct "active" "g")"
    elif [[ $sl == *"filter"* && *"created" ]]; then
      local sl_center="${sl#*filter}" && sl_center="${sl_center%created*}"
      local sl_reason="filter $(ct $sl_center "b") $(ct "created" "g")"
    else
      local sl_reason=""
    fi
    
    if [[ $1 == 0 ]]; then
      sl="$sl_date   $sl_reason"
    elif [[ $i -eq 1 && $1 == 1 ]]; then
      sl="         log: $sl_date   $sl_reason"
    elif [[ $i -gt 1 && $1 == 1 ]]; then
      sl="              $sl_date   $sl_reason"
    fi

    echo -e "$sl"
  done
}
# end lr()

# function lw(): log write. writes a log entry
function lw() {
  # $1: text
  echo "$date_stamp_long     privoxy $1"  >> $log_file
}
# end lw()

# function pp(): privoxy process. starts, restarts and ends the privoxy process
function pp(){
  local ps_search=$(ps xa | grep "/usr/local/opt/privoxy/sbin/privoxy")
  local ps_search=($ps_search)
  local pos=0
  local ps_n="/usr/local/opt/privoxy/sbin/privoxy /usr/local/etc/privoxy/config"

  if [[ $1 == "start" ]]; then
    output=$(eval "$ps_n") && echo "$output"
    while [[ $pos -lt ${#ps_search[@]} ]]; do
      if [[ "${ps_search[$pos]} ${ps_search[$(($pos + 1))]}" == $ps_n ]]; then
        echo "Privoxy is up"
        lw "start"
        status
        break
      fi
      ((pos++))
    done
    echo "Privoxy could not be started"
    lw "error"
    exit 1
  elif [[ $1 == "restart" ]]; then
    pkill -f "/usr/local/opt/privoxy/sbin/privoxy"
    lw "stop"
    output=$(eval "$ps_n") && echo "$output"
    while [[ $pos -lt ${#ps_search[@]} ]]; do
      if [[ "${ps_search[$pos]} ${ps_search[$(($pos + 1))]}" == $ps_n ]]; then
        echo "Privoxy is up"
        lw "restart"
        status
        exit 0
      fi
      ((pos++))
    done
    echo "Privoxy could not be started"
    lw "error"
    exit 1
  elif [[ $1 == "stop" ]]; then
    pkill -f "/usr/local/opt/privoxy/sbin/privoxy"
    lw "stop"
    exit 0
  fi
}

# function status(): display privoxy status including PID, uptime,
function status() {
  local config_head=$(head -n 1 $config_file)
  local filter_group="${config_head:35:$((${#config_head} - 6 - 36))}"
# Read the file line by line
while IFS= read -r line
do
  # Check if the line starts with the filter set
  if [[ "$line" == "$filter_group"* ]]; then
    local filter_list="${line#"$filter_group="}"
    break
  fi
done < $config_mod_file
local pid=$(ps xa | grep "/usr/local/opt/privoxy/sbin/privoxy $config_file" | grep -v grep | awk '{print $1}')
if [[ $pid =~ ^0*[1-9][0-9]{0,2}$ ]]; then
  up_since=$(ps -p $pid -o lstart= | awk '{print $1,$2,$3,$4}')
  up_time=$(ps -p $pid -o etime= )
  config_date=$(ls -lD "%a %b %d %H:%M:%S" $config_file | awk '{print $6,$7,$8,$9}')
  echo -e "         pid: $(ct "$pid" "y")"
  echo -e "          up: $(ct "$up_since" "y") ($(ct "$up_time" "y"))"
  echo -e "      config: $(ct "$config_date" "y") ($(ct "$(dd $config_file)" "y"))"
  echo -e "filter group: $(ct "$filter_group" "b")"
  echo -e "     filters: $(ct "$filter_list" "b")"  
  echo "              -------------------"
  lr 1
elif [[ $output == *"none"* ]]; then
  #echo -e "OUTPUT: $output"
  #echo -e "$(color_text "$output" "error" "red")"
  #echo -e "$date_stamp     privoxy status $(ct "error" "r")" >> $log_file
  lw "status error"
else
  echo -e "$(ct "$output" "r")"
fi
}
# status()

#
# end of functions
#

# 
# main (for lack of better words)
# 

# date and date sensitive values
date_epoch=$(date +%s)
date_stamp_long=$(date -r "$date_epoch" +"%a %b %d %Y %H:%M:%S %Z")
date_stamp=$(date -r "$date_epoch" +"%a %b %d %H:%M:%S")
config_original_file="/usr/local/etc/privoxy/config.original"
config_bak_file="/usr/local/etc/privoxy/config.bak"
config_tmp_file="/usr/local/etc/privoxy/config.tmp"
config_file="/usr/local/etc/privoxy/config"
config_mod_file="/usr/local/etc/privoxy/config.mod"
log_file="/var/log/privoxy.log"
filters_dir="/usr/local/etc/privoxy/filters"
filters_blp_dir="/usr/local/etc/privoxy/filters/blp"


# checking for log file exsistance
if [ ! -f $log_file ]; then
  touch $log_file
  chmod og+rw $log_file
  echo "$date_stamp_long      $log_file created" >> $log_file
fi

# checks for $filters_dir and $filters_blp_dir created. creates if not found
if [ ! -d $filters_dir ]; then
  mkdir -p $filters_dir
  mkdir -p $filters_blp_dir
  echo "$date_stamp_long     $filters_dir created"  >> $log_file
  echo "$date_stamp_long     $filters_blp_dir created"  >> $log_file
fi

# checks for $config_original_file, $config_bak_file and config_file. 
# if all are missing something really, really wrong has happenned
# Privoxy config version 3.0.34 used
if [ ! -f $config_file ] && [ ! -f $config_bak_file ] && [ ! -f $config_original_file ]; then
  curl --no-progress-meter -o $config_original_file "https://raw.githubusercontent.com/brian-beeler/privoxy-pilot-macos/main/config-3.0.34"
  cp $config_original_file $config_bak_file
  cp $config_original_file $config_file
  chmod ug+rw $config_file
  chmod ug+rw $config_original_file
  chmod ug+rw $config_bak_file
  gzip $config_original_file
  # macOS seems to have an issue with this
  chmod a-w $config_original_file.gz
  echo "$date_stamp_long     $config_original_file.gz created"  >> $log_file
  echo "$date_stamp_long     $config_bak_file created"  >> $log_file
  echo "$date_stamp_long     $config_file created"  >> $log_file
fi
# checks for $config_file, no $config_bak_file and no $config_original_file.
# most likely only happens on ppilot.sh inital run
if [[ -f "$config_file" ]] && [[ ! -f "$config_original_file" ]] && [[ ! -f "$config_original_file.gz" ]] ; then
  cp $config_file $config_original_file
  cp $config_file $config_bak_file
  chmod ug+rw $config_original_file
  chmod ug+rw $config_bak_file
  gzip $config_original_file
  # macOS seems to have an issue with this
  chmod a-w $config_original_file.gz
  echo "$date_stamp_long     $config_original_file.gz created"  >> $log_file
  echo "$date_stamp_long     $config_bak_file created"  >> $log_file
fi
# checks for config and mo config.bak. creates config.bak 
if [[ -f "$config_file" ]] && [[ ! -f "$config_bak_file" ]]; then
  gzip -d $config_original_file
  cp $config_original_file $config_bak_file
  cp $config_original_file $config_file
  chmod a+rw $config_bak_file
  chmod a+rw $config_file
  gzip $config_original_file
  # macOS seems to have an issue with this
  chmod a-w $config_original_file.gz
  echo "$date_stamp_long     $config_bak_file created"  >> $log_file
  echo "$date_stamp_long     $config_file created"  >> $log_file
fi
# checks for config.mod and creates if not found
if [ ! -f $config_mod_file ]; then
  echo -e "$(ct "getting" "g") $(ct "config.mod" "b")"
  curl --no-progress-meter -o $config_mod_file "https://raw.githubusercontent.com/brian-beeler/privoxy-pilot-macos/main/config.mod"
  echo "$date_stamp_long     $config_mod_file created"  >> $log_file
fi
# checks for mylist filter list and creates if not found
if [ ! -f "$filters_dir/mylist" ]; then
  echo -e "$(ct "getting" "g") $(ct "filters/mylist" "b")"
  curl --no-progress-meter -o "$filters_dir/mylist" "https://raw.githubusercontent.com/brian-beeler/privoxy-pilot-macos/main/filters/mylist"
  echo "$date_stamp_long     $filters_dir/mylist created"  >> $log_file
fi
# checks for distractions filter list and creates if not found
if [ ! -f "$filters_dir/distractions" ]; then
  echo -e "$(ct "getting" "g") $(ct "filters/distractions" "b")"
  curl --no-progress-meter -o "$filters_dir/distractions" "https://raw.githubusercontent.com/brian-beeler/privoxy-pilot-macos/main/filters/distractions"
  echo "$date_stamp_long     $filters_dir/distractions created"  >> $log_file
fi

# start, stop or restart
if [[ $1 == "start" || $1 == "stop" || $1 == "restart" ]]; then
  pp $1
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
  echo "usage: ./ppilot.sh [start|stop|restart|status|config|filter|log]"
  echo "  start                   start server"
  echo "  stop                    stop server"
  echo "  restart                 restart server"
  echo "  status                  display privoxy status"
  echo "  config list             list filter groups"
  echo "  config set <group>      set filter group"
  echo "  filter <name>           create new filter list"
  echo "  log                     display log file"
fi