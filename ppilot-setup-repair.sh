#
# !/bin/bash
# a script to setup Privoxy-Pilot and repair Privoxy
# 

#
ppilot_setup() {
  # first time install
  # 
  # even if not first time install good to download most up-to-date ppilot.sh
  echo "downloading latest ppilot.sh"
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
    gzip -k $config_original_file
    # rm $config_file because it will be rewritten in this script
    rm $config_file
  else
    # run only if $config_original_file is present
    echo "Privoxy Pilot seems to have been previously installed on this Mac."
    read -p "Do you want to repair Privoxy Pilot? (Y/N) " choice_repair
    if [[ $choice_repair == [Yy] ]]; then
      echo "repairing privoxy..."
      ppilot_repair $1
    else
      echo "Exiting..."
      exit 1
    fi
  fi
  # 
  echo -e "\r\n \r\n# do not edit above this line\r\n# add configuration options here\r\n# \r\n" >> $config_file
  # 
  if [[ $1 == "shared" ]]; then
    echo -e "# allow privoxy to make connections with the local network" >> $config_file
    echo -e "listen-address $(ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}')":8118 >> $config_file
  fi
  # 
  if [ -n $hostname ]; then
    echo -e "# sets hostname for logs and \"blocked\" page" >> $config_file
    echo "hostname $hostname" >> $config_tmp_file
  fi
  echo -e "# \r\n# \r\n" >> $config_file
  cat $config_original_file >> $config_file
  cp $config_file $config_bak_file
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
    echo "Restoring missing $config_original_file from $config_original_gz_file"
    gunzip -k $config_original_gz_file
    cp $config_original_file $config_file
    ppilot_setup $2
  fi
  # repair privoxy by restoring orginal config file
  if [ -f $config_original_file ]; then
    cp $config_original_file $config_file
    ppilot_setup $2
  fi
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
  log_file="/var/log/privoxy.log"
  filters_dir="/usr/local/etc/privoxy/filters"
  filters_blp_dir="/usr/local/etc/privoxy/filters/blp"
  ppilot_file="/usr/local/etc/privoxy/ppilot.sh"
  hostname=$(hostname)

  echo "This script is used to either setup Privoxy Pilot or repair Privoxy in case there is a problem."
  echo "Follow the instructions cafefully."

  if [[ $1 == "setup" && ( $2 == "shared" || $2 == "solo" ) ]]; then
    #
    echo "setting up privoxy pilot..."
    ppilot_setup $2
  elif [[ $1 == "repair" && ( $2 == "shared" || $2 == "solo" ) ]]; then
    #
    echo "repairing privoxy..."
    ppilot_repair $2
  #  
  else
    echo "usage: ./ppilot-setup-repair.sh [setup shared | setup solo | repair shared | repair solo]"
    echo "  setup shared      setup privoxy pilot and privoxy to be shared with local network clients"
    echo "  setup solo        setup privoxy pilot and privoxy to only be used by this Mac"
    echo "  repair shared     repair and reset privoxy pilot and privoxy to be shared with local network clients"
    echo "  repair solo       repair and reset privoxy pilot and privoxy to only be used by this Mac"
  fi
}

# in the beginning there was main...
main "$@"
exit 0