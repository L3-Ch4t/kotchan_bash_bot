#!/bin/bash

#test if file exist
#wget -O/tmp/proxies 'https://api.proxyscrape.com/?request=getproxies&proxytype=http&timeout=10000&country=all&ssl=yes&anonymity=all'

function error
{
   echo $1
   exit 1
}

function gen_proxies
{
   if [ -f "/tmp/proxies" ]
   then
      echo "proxies exists"
   else
      echo "generating proxies"
      wget -O/tmp/proxies 'https://api.proxyscrape.com/?request=getproxies&proxytype=http&timeout=10000&country=all&ssl=yes&anonymity=all'
   fi
}

get_proxy=Nothing

function change_message
{
   if [ -z "$1" ] 
   then
      error "no message to post"
   else
      cat kotch.data \
	 | sed '12d' \
	 | sed "12i$1\r" \
	 > /tmp/kotch
      mv /tmp/kotch kotch.data
   fi
}

function time_post
{
get_proxy=$(shuf /tmp/proxies | head -n1 | sed 's/\r//g')
echo $get_proxy
timeout 10 curl 'https://kotchan.fun/chat/int' \
  -H 'Accept: application/json, text/javascript, */*; q=0.01' \
  -H 'User-Agent: Mozilla/5.0 (compatible; Exabot/3.0 (BiggerBetter); +http://www.exabot.com/go/robot)' \
  -H 'Content-Type: multipart/form-data; boundary=----WebKitFormBoundaryMCFiyjb02QxKM2SH' \
  --proxy "http://$(echo $get_proxy)" \
  --data-binary @kotch.data \
  --compressed && success=1 || success=0
}

function remove_useless_ip
{
   cat /tmp/proxies \
      | sed "/$get_proxy/d" \
      > /tmp/updated_prox
   echo $get_proxy got removed
   mv /tmp/updated_prox /tmp/proxies
}


change_message "$1"
gen_proxies
while [[ $success -eq '0' ]]
do
   remove_useless_ip
   time_post
done
