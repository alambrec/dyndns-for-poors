#!/bin/bash

BASENAME="`basename -s ".sh" $0`"
OLD_IP=""
CURRENT_IP=""
TEST_DNS="8.8.8.8"

IP_PATH="/path/to/wan.ip"
LOG_DIR="/tmp/$BASENAME"
LOG_PATH="$LOG_DIR/$BASENAME.log"

# Get your API key from OVH Account
API_LOGIN="your_api_login_here"
API_PASSWORD="your_api_password_here"
DYNHOST_DOMAIN="dynhost.domain.xyz"

# To log in formatted style every log message
log_message ()
{
  local CURRENT_DATE=$(date +"%b %e %T")
  local CURRENT_LOG="$CURRENT_DATE $BASENAME: $1"
  echo $CURRENT_LOG >> $LOG_PATH
}

# To get old IP
load_old_ip()
{
  if [ -f $IP_PATH ]
  then
    OLD_IP=`cat $IP_PATH`
    return 0
  else
    return 1
  fi
}

# To get external IP
get_wan_ip ()
{
  local ret=1
  ping -q -c1 $TEST_DNS &> /dev/null
  if [ $? -eq 0 ]
  then
    CURRENT_IP=`dig +short myip.opendns.com @resolver1.opendns.com`
    if [ $? -eq 0 ]
    then
      #log_message "Current IP is $CURRENT_IP"
      ret=0
    else
      log_message "Unable to get external IP"
    fi
  else
    log_message "Network not reachable"
  fi
  return $ret
}

# To update DynHost
update_a_record ()
{
  local ret=1
  log_message "Updating dns record"
  # Update the previous record
  curl --user "$API_LOGIN:$API_PASSWORD" "https://www.ovh.com/nic/update?system=dyndns&hostname=$DYNHOST_DOMAIN&myip=$CURRENT_IP"

  if [ $? -eq 0 ]
  then
    echo $CURRENT_IP > $IP_PATH
    ret=0
    log_message "Update A record OK [$CURRENT_IP]"
  else
    log_message "Update A record KO [$CURRENT_IP]"
  fi
  return $ret
}

# Main function
main()
{
  local ret=1
  # Create log dir if it isn't exist
  if [ ! -d "$LOG_DIR" ]
  then
    mkdir -p "$LOG_DIR"
    log_message "Creating log directory"
  fi
  if get_wan_ip
  then
    if ! load_old_ip
    then
      log_message "No old IP detected"
      ret=$(update_a_record)
    else
      if [ "$CURRENT_IP" != "$OLD_IP" ]
      then
        log_message "New IP detected [$OLD_IP -> $CURRENT_IP]"
        ret=$(update_a_record)
      else
        ret=0
      fi
    fi
  fi
  exit "$ret"
}

main
