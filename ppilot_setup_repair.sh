#
# !/bin/bash
# a script to setup Privoxy-Pilot and repair Privoxy
# 

#
ppilot_setup() {
  # first time install
  # 
  # even if not first time install good to download most up-to-date ppilot.sh
  echo -e "\r\ndownloading latest ppilot.sh\r\n"
  curl -o $ppilot_file "https://raw.githubusercontent.com/brian-beeler/privoxy-pilot-macos/main/ppilot.sh"
  # set ppilot.sh as executable
  chmod ug+x $ppilot_file
  # unlikely but just in case config is missing
  if [[ ! -f $config_file ]]; then
    curl -o $config_file "https://raw.githubusercontent.com/brian-beeler/privoxy-pilot-macos/main/config-3.0.34"
  fi
  # check to confirm that this is a first time install and not where repair should be run
  if [[ ! -f $config_original_file ]]; then
    md5 -q $config_file > $config_file_md5
    cp $config_file $config_original_file
    echo "gzip1 start"
    gzip -k $config_original_file
    echo "gzip1 finish"
    # rm $config_file because it will be rewritten in this script
    $ppilot_file config set default
    exit 1
  else
    # run only if $config_original_file is present
    echo "Privoxy Pilot seems to have been previously installed on this Mac."
    read -p "Do you want to repair Privoxy Pilot? (Y/N) " choice_repair
    if [[ $choice_repair == [Yy] ]]; then
      echo "repairing privoxy..."
      ppilot_repair
    else
      echo "Exiting..."
      exit 1
    fi
  fi
}

#
ppilot_repair() {
  # repair privoxy by restoring orginal config file which the only file ppilot touches
  # 
  if [ ! -d $filters_dir ] || [ ! -f $filters_blp_dir ]; then
    echo "Privoxy Pilot does not seem to have been previously installed on this Mac."
    read -p "Do you want to setup Privoxy Pilot? (Y/N) " choice_repair
    if [ $choice_repair == [Yy] ]; then
      echo "setting up privoxy pilot..."
      ppilot_setup $1
    else
      exit 1
    fi
  fi
  # even if not first time install good to download most up-to-date ppilot.sh
  echo "downloading latest ppilot.sh"
  curl -o $ppilot_file "https://raw.githubusercontent.com/brian-beeler/privoxy-pilot-macos/main/ppilot.sh"
  # set ppilot.sh as executable
  chmod ug+x $ppilot_file
  #
  # Unlikely but no $config_original_file && no $config_original_gz_file means some bad happenned
  if [ ! -f $config_original_file ] && [ ! -f $config_original_gz_file ]; then
    curl -o $config_file "https://raw.githubusercontent.com/brian-beeler/privoxy-pilot-macos/main/config-3.0.34"
  fi
  # repair privoxy by restoring orginal config file from compressed save
  if [ ! -f $config_original_file ] && [ -f $config_original_gz_file ]; then
    echo -e "Restoring missing $config_original_file from $config_original_gz_file"
    gunzip -k $config_original_gz_file
    cp $config_original_file $config_file
    ppilot_setup $2
  fi
  # repair privoxy by restoring orginal config file
  if [ -f $config_original_file ]; then
    cp $config_original_file $config_file
    ppilot_setup $2
  fi
}

#
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


  echo -e "\r\nThis script is used to either setup Privoxy Pilot or repair Privoxy in case there is a problem."
  echo -e "Follow the instructions carefully."

  # ! -f $ppilot_setup_repair_file should mean first time run hence the questionare

  if [[ ! -f $ppilot_setup_repair_file ]]; then
    # even if not first time install good to download most up-to-date ppilot.sh
    echo -e "\r\ndownloading latest ppilot_setup_repair.sh\r\n"
    curl -o $ppilot_setup_repair_file "https://raw.githubusercontent.com/brian-beeler/privoxy-pilot-macos/main/ppilot_setup_repair.sh"
    chmod og+rwx $ppilot_setup_repair_file
    if [[ -f $ppilot_setup_repair_file ]]; then
      ppilot_setup
    else
      exit 0
    fi
  fi
  # Normal choices
  if [[ $1 == "setup" ]]; then
    #
    echo "setting up privoxy pilot..."
    ppilot_setup
  elif [[ $1 == "repair" ]]; then
    #
    echo "repairing privoxy..."
    ppilot_repair
  #  
  else
    echo "usage: ./ppilot-setup-repair.sh [ setup | repair ]"
    echo "  setup       setup privoxy pilot"
    echo "  repair      repair and reset privoxy pilot"
  fi
}

# in the beginning there was main...
main "$@"
exit 0