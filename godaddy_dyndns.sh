#!/bin/sh

BASENAME="`basename -s ".sh" $0`"
OLD_IP=""
CURRENT_IP=""
TEST_DNS="8.8.8.8"

IP_PATH="/var/tmp/ip.external"
LOG_PATH="/var/tmp/$BASENAME.log"

# Get your API key from https://developer.godaddy.com
API_KEY="your_api_key_here"
API_SECRET="your_api_secret_here"
DOMAIN="your_domain_here"

# Update A record
RECORD_TYPE="A"
# For an A-Record, the record name is equivalent to DOMAIN
# but for a TXT-Record, the record name is the key of TXT-Record
RECORD_NAME=$DOMAIN


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
      log_message "Current IP is $CURRENT_IP"
      ret=0
    else
      log_message "Unable to get external IP"
    fi
  else
    log_message "Network not reachable"
  fi
  return $ret
}

# To update A record on GoDaddyDNS
update_a_record ()
{
  local ret=1
  log_message "Updating dns record"
  # Update the previous record
  local JSON_RESPONSE=$(curl -s -X PUT \
  -H "Authorization: sso-key $API_KEY:$API_SECRET" \
  -H "Content-Type: application/json" \
  -d "[{\"data\": \"$CURRENT_IP\", \"ttl\": 600}]" \
  "https://api.godaddy.com/v1/domains/$DOMAIN/records/$RECORD_TYPE/$RECORD_NAME")

  if [ $JSON_RESPONSE == "{}" ]
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
  exit $ret
}

main
