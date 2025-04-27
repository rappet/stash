#!/bin/bash

read -r -d '' ZONEHEADER <<- EOM
$TTL 1h    ; Default TTL
@    IN    SOA    <NAMESERVER 1>.    <ABUSE EMAIL>. (
    2019071201    ; serial
    1h        ; slave refresh interval
    15m        ; slave retry interval
    1w        ; slave copy expire time
    1h        ; NXDOMAIN cache time
    )
;
; domain name servers
;
@    IN    NS    <NAMESERVER 1>.
@    IN    NS    <NAMESERVER 2>.
; IPv6 PTR entries
EOM

# Script:

function reverseIp6 {
    echo "$1" | awk -F: 'BEGIN {OFS=""; }{addCount = 9 - NF; for(i=1; i<=NF;i++){if(length($i) == 0){ for(j=1;j<=addCount;j++){$i = ($i "0000");} } else { $i = substr(("0000" $i), length($i)+5-4);}}; print}' | rev | sed -e "s/./&./g"
}


if [ -z "$1" ]
then
    echo "Usage: $0 <zonefile>"
    exit 1
fi

RECORD=(`cat $1 | grep AAAA | awk -v'OFS=,' '$2 == "IN" {print $4}'`)
HOST=(`cat $1 | grep AAAA | awk -v'OFS=,' '$2 == "IN" {print $1}'`)

echo "$ZONEHEADER"
for (( i=0; i<${#RECORD[@]}; i++ )); do
	echo "$(reverseIp6 ${RECORD[i]})ip6.arpa.     IN    PTR	 ${HOST[i]}";
done
