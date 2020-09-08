#!/bin/bash
ipv4_address=$({{ dyndns_get_ipv4_command }})
ipv6_address=$({{ dyndns_get_ipv6_command }})

old_ipv4_address=$(cat dyndns_nsupdate.txt 2>/dev/null | grep -Po '(?<=A )(?:[0-9]{1,3}\.){3}[0-9]{1,3}')
old_ipv6_address=$(cat dyndns_nsupdate.txt 2>/dev/null | grep -Po '(?<=AAAA )(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))')

if ! [ -f dyndns_nsupdate.txt ] || [ "$old_ipv4_address" != "$ipv4_address" ] || [ "$old_ipv6_address" != "$ipv6_address" ]; then
  rm dyndns_nsupdate.txt 2>/dev/null

  echo "server {{ powerdns_dynamicdns_nsupdate_server }}
zone {{ powerdns_dynamicdns_zone }}
update delete {{ powerdns_dynamicdns_record_name }} A
update delete {{ powerdns_dynamicdns_record_name }} AAAA" >>dyndns_nsupdate.txt

  if [ "$ipv4_address" != "" ]; then
    echo "update add {{ powerdns_dynamicdns_record_name }} 60 A" $ipv4_address >>dyndns_nsupdate.txt
  fi

  if [ "$ipv6_address" != "" ]; then
    echo "update add {{ powerdns_dynamicdns_record_name }} 60 AAAA" $ipv6_address >>dyndns_nsupdate.txt
  fi

  echo "send" >>dyndns_nsupdate.txt

  nsupdate -k dyndns_tsig_key -v dyndns_nsupdate.txt

fi
