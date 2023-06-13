#!/bin/bash
#
# privoxy-pilot-macos v1.01
#   v1.01:   fixed formatting issues with lapsed time from PID and config creation date to consistent HH:MM:SS.
#            fixed config date up time delay when config set <filter set> evoked by local date update to $date_epoch in status().
#            renamed $bs in status() to $bsip to avoid confusion with bs().
#            made lr() number of entries returned adjustable
#
# copyright © Brian Beeler 2023 under CC BY-SA license
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
# Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
# Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
# Neither the name of copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# This project is still in its early beginnings. 
# Please post any questions or issues to: https://github.com/brian-beeler/privoxy-pilot-macos/issues 
# If you are not comfortable working in the terminal than ask someone that is to help you. 
#
# TODO: new script to check for new version of ppilot. check during set intervals from ppilot
# 
# functions:
#   blpfl(): blp filter lists: download and edit blp filter lists
#      bs():    brew services: start, restart and stop calls to brew services
#  config():      config list: list and choose .config list
#      ct():       color text: colorizes text in ANSI RGB
#      ft():  filter template: a template for creating new, custom filters lists
#      lr():         log read: displays log files with ANSI colors
#      lw():        log write: write log entries
#      pp():  privoxy process: start, restart or stop the privoxy process
#  status():   current status: displays privoxy status
#    main():             main: first function to run

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
    lw "filter $filter_file_name created"
    rm "$filters_blp_dir/$1-nl.txt"
  fi
}
# end blpfl()

#bs(): brew services for privoxy
function bs() {
  local brew_services=$(brew services info privoxy)
  if [[ $1 == "start" && $brew_services == *"Running: true"* ]]; then
    status
    exit 1
  fi
  if [[ $1 == "restart" && $brew_services == *"Running: true"* ]]; then
    brew services restart privoxy
    lw "restart"
    status
    exit 1
  fi
    if [[ $1 == "start" && $brew_services == *"Running: false"* ]]; then
    brew services start privoxy
    lw "start"
    status
    exit 1
  fi
  if [[ $1 == "restart" && $brew_services == *"Running: false"* ]]; then
    brew services start privoxy
    lw "restart"
    status
    exit 1
  fi
  if [[ $1 == "stop" && $brew_services == *"Running: true"* ]]; then
    brew services stop privoxy
    lw "stop"
    exit 1
  fi
  if [[ ($1 == "stop" && $brew_services == *"Running: true"*) || $brew_services == *"privoxy error"* ]]; then
    brew services stop privoxy
    lw "stop"
    exit 1
  fi
}
# end bs()

# function config(): manipulates config file
# TODO: error checking on privoxy.sh config set filter_group_no_exist
#       right now on error no block lists are added
function config() {
  local blp_fl=("abuse" "ads" "crypto" "drugs" "everything" "facebook" "fraud" "gambling" "malware" "phishing" "piracy" "porn" "ransomware" "redirect" "scam" "tiktok" "torrent" "tracking")
# checks for config.bak     and creates one if not found
# options -c restore        restore config from config.bak. retores config to a vanilla state
#         -c backup         backup config config.bak. use after editing config
#         -c set <config>   sets a custom config file in play
#         -c filters        updates blp filter lists
# 
# TODO: set = cp config.bak config, read config.mod, choose line, write:
#   actionsfile $filters_dir/(name) to top of config
# 
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
  echo "# $date_stamp_long $date_epoch" >> $config_tmp_file
  echo "# filter group: $3" >> $config_tmp_file
  echo "# filter list: $filter_list" >> $config_tmp_file
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
  echo "# " >> $config_tmp_file
  # sets hostname
  if [ -n $hostname ]; then
    echo -e "# sets hostname for logs and blocked page" >> $config_tmp_file
    echo "hostname $hostname" >> $config_tmp_file
  fi
  # sets ip address
  echo "# " >> $config_tmp_file
  echo "# sets ip address. 127.0.0.1 default on privoxy install" >> $config_tmp_file
  ip_address=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}')
  ip_address=($ip_address)
  for address in "${ip_address[@]}"
  do
    echo "listen-address $address" >> $config_tmp_file
  done
  echo "# " >> $config_tmp_file
  echo "# activates privoxy log" >> $config_tmp_file
  echo "logfile  /var/log/privoxy.log" >> $config_tmp_file
  echo -e "\r\n# \r\n# do not edit above this line\r\n# add configuration options here\r\n# \r\n \r\n" >> $config_tmp_file
  cat $config_bak_file >> $config_tmp_file
  mv $config_tmp_file $config_file
  lw "config $3 active"
  bs restart
  lw "restart"
  status
fi 
}
# end config()

# function ct(): color text with ANSI colors
function ct() {
    # $1=input text, $2=color
    # red
    if [[ $2 == "r" ]]; then
        echo -e "\033[31m$1\033[0m"
    # green
    elif [[ $2 == "g" ]]; then
        echo -e "\033[32m$1\033[0m"
    # blue
    elif [[ $2 == "b" ]]; then
        echo -e "\033[34m$1\033[0m"
    # cyan
    elif [[ $2 == "c" ]]; then
        echo -e "\033[36m$1\033[0m"
    # magenta
    elif [[ $2 == "m" ]]; then
        echo -e "\033[35m$1\033[0m"
    # yellow
    elif [[ $2 == "y" ]]; then
        echo -e "\033[33m$1\033[0m"
    # red - blinking
    elif [[ $2 == "rb" ]]; then
        echo -e "\033[31;5m$1\033[0m"
    # if unknow color option is passed then just echo input
    else
        echo "$1"
    fi
}
# end ct()

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
  # $2: number of log entries returned
  # 
  # 
  local log_entries_out=$2
  local log_file_line_count=$(wc -l $log_file | awk '{print $1}')
  # regex check for positive integer else log_entries_out=10
  [[ $log_entries_out =~ ^[1-9][0-9]?$ ]] || log_entries_out=10
  # check to see if requested lines out is not greater than log length
  [[ $log_entries_out -gt $log_file_line_count ]] && log_entries_out=$log_file_line_count
  # max 30 log entries out
  [[ $log_entries_out -gt 31 ]] && log_entries_out=30
  local log=$(tail -n $log_entries_out $log_file)
  for ((i=1; i<=$log_entries_out; i++)); do
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
  echo "$date_stamp_long     $1"  >> $log_file
}
# end lw()

#
# function status(): display privoxy status including PID, uptime,
function status() {
  local bsip=$(brew services info privoxy)
  # $date_epoch updated local for latest date 
  local date_epoch=$(date +%s)
  local cf_date=$(head -n 1 $config_file | tail -n 1)
  local cf_date=($cf_date)
  local cf_date_epoch="${cf_date[7]}"
  cf_date=$(date -r $cf_date_epoch "+%a %b %d %T")
  local cf_lapse="$(td "$date_epoch" "$cf_date_epoch")"
  local cf_dl="$(ct "$cf_date" "y") ($(ct "$cf_lapse" "y"))"
  local filter_group=$(head -n 2 $config_file | tail -n 1)
  local filter_list=$(head -n 3 $config_file | tail -n 1)
  filter_group=($filter_group)
  filter_list=($filter_list)
  filter_group="${filter_group[3]}"
  filter_list="${filter_list[3]}"
  bsip=($bsip)
  local bsip_user=${bsip[9]}
  local bsip_pid=${bsip[11]}
  if [[ $bsip_pid =~ ^0*[1-9][0-9]{0,6}$ ]]; then
    local up_date=$(ps -p $bsip_pid -o lstart=)
    up_date=($up_date)
    [[ ${#up_date[2]} -eq 1 ]] && up_date[2]="0${up_date[2]}"
    up_date="${up_date[0]} ${up_date[1]} ${up_date[2]} ${up_date[3]}"
    local up_time=$(td "$date_epoch" "$(date -jf "%a %b %d %T %Y" "$up_date" +%s)" )
    local up_date_time="$(ct "$up_date" "y") ($(ct "$up_time" "y"))"
  else
    local up_date_time=""
  fi
  echo -e "         pid: $(ct "$bsip_pid" "y")"
  echo -e "        user: $(ct "$bsip_user" "y")"
  echo -e "          up: $up_date_time"
  echo -e "      config: $(ct "$cf_date" "y") ($(ct "$cf_lapse" "y"))"
  echo -e "filter group: $(ct "$filter_group" "b")"
  echo -e "filter lists: $(ct "$filter_list" "b")"  
  echo "              -------------------"
  lr 1 $1
}
# status()

# time difference between to times expressed in HH:MM:SS
function td(){
  if [[ $1 =~ ^[1-9][0-9]*$ && $2 =~ ^[1-9][0-9]*$ ]]; then
    local seconds=$(($1-$2))
    if [[ $seconds -lt 0 ]]; then
      seconds=${seconds#-}
    fi
    local hours=$((seconds/3600))
    local minutes=$(((seconds%3600)/60))
    local seconds=$((seconds%60))
    local diff=$(printf "%02d:%02d:%02d\n" $hours $minutes $seconds)
    echo "$diff"
  fi
}

function main() {
  # date and date sensitive values
  date_epoch=$(date +%s)
  date_stamp_long=$(date -r "$date_epoch" +"%a %b %d %Y %H:%M:%S %Z")
  date_stamp=$(date -r "$date_epoch" +"%a %b %d %H:%M:%S")
  date_stamp_ISO=$(date -r "$date_epoch" +"%Y-%m-%d %H:%M:%S")
  config_original_file="/usr/local/etc/privoxy/config.original"
  config_original_gz_file="/usr/local/etc/privoxy/config.original.gz"
  config_bak_file="/usr/local/etc/privoxy/config.bak"
  config_tmp_file="/usr/local/etc/privoxy/config.tmp"
  config_file="/usr/local/etc/privoxy/config"
  config_mod_file="/usr/local/etc/privoxy/config.mod"
  config_file_md5="/usr/local/etc/privoxy/config.md5"
  log_file="/var/log/ppilot.log"
  privoxy_dir="/usr/local/etc/privoxy/"
  filters_dir="/usr/local/etc/privoxy/filters"
  filters_blp_dir="/usr/local/etc/privoxy/filters/blp"
  ppilot_file="/usr/local/etc/privoxy/ppilot.sh"
  ppilot_setup_repair_file="/usr/local/etc/privoxy/ppilot_setup_repair.sh"
  hostname=$(hostname)

  # checking for log file exsistance
  if [ ! -f $log_file ]; then
  touch $log_file
  chmod og+rw $log_file
  lw "$log_file created"
  fi
  # checks for $filters_dir and $filters_blp_dir created. creates if not found
  if [ ! -d $filters_dir ]; then
    mkdir -p $filters_dir
    mkdir -p $filters_blp_dir
    lw "$filters_dir created"
    lw "$filters_blp_dir created"
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
    lw "$config_original_file.gz created"
    lw "$config_bak_file created"
    lw "$config_file created"
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
    lw "$config_original_file.gz created"
    lw "$config_bak_file created"
  fi
  # checks for config and no config.bak. creates config.bak 
  if [[ -f "$config_file" ]] && [[ ! -f "$config_bak_file" ]]; then
    gzip -d $config_original_file
    cp $config_original_file $config_bak_file
    cp $config_original_file $config_file
    chmod a+rw $config_bak_file
    chmod a+rw $config_file
    gzip $config_original_file
    # macOS seems to have an issue with this
    chmod a-w $config_original_file.gz
    lw "$config_bak_file created"
    lw "$config_file created"
  fi
  # checks for config.mod and creates if not found
  if [ ! -f $config_mod_file ]; then
    echo -e "$(ct "getting" "g") $(ct "config.mod" "b")"
    curl --no-progress-meter -o $config_mod_file "https://raw.githubusercontent.com/brian-beeler/privoxy-pilot-macos/main/config.mod"
    lw "$config_mod_file created"
  fi
  # checks for mylist filter list and creates if not found
  if [ ! -f "$filters_dir/mylist" ]; then
    echo -e "$(ct "getting" "g") $(ct "filters/mylist" "b")"
    curl --no-progress-meter -o "$filters_dir/mylist" "https://raw.githubusercontent.com/brian-beeler/privoxy-pilot-macos/main/filters/mylist"
    lw "$filters_dir/mylist created"
  fi
  # checks for distractions filter list and creates if not found
  if [ ! -f "$filters_dir/distractions" ]; then
    echo -e "$(ct "getting" "g") $(ct "filters/distractions" "b")"
    curl --no-progress-meter -o "$filters_dir/distractions" "https://raw.githubusercontent.com/brian-beeler/privoxy-pilot-macos/main/filters/distractions"
    lw "$filters_dir/distractions created"
  fi

  # start, stop or restart
  if [[ $1 == "start" || $1 == "stop" || $1 == "restart" ]]; then
    bs $1
  elif [[ $1 == "status" ]]; then
    status $2
  # config
  elif [ "$1" = "config" ]; then
    config $1 $2 $3
  # display log file
  elif [[ $1 == "log" ]]; then
    lr 0 $2
  # filter template
  elif [[ $1 == "filter" ]]; then
    ft $2
  #  
  else
    echo "usage: ./ppilot.sh [start|stop|restart|status|config|filter|log]"
    echo "  start                   start server"
    echo "  stop                    stop server"
    echo "  restart                 restart server"
    echo "  status <number>         display privoxy status with optional number of log entries up to 30"
    echo "                            default is 10"
    echo "  config list             list filter groups"
    echo "  config set <group>      set filter group"
    echo "  filter <name>           create new filter list"
    echo "  log <number>            display log file with optional number of entries up to 30"
    echo "                            default is 10"
  fi
}

main "$@"
exit 0