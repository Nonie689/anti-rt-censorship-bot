#!/usr/bin/bash

## comment out to debug the script!
#set -xv

banner () {
echo -e "\n\n

  #######################################################################\n
  #                                                                     #\n
  #    Russia Today Magazin URL deblocker     ######     ##########     #\n
  #                                           #    #         #          #\n
  #        This script for bypassing          #####          #          #\n
  #               censorship                  # #            #          #\n
  #                                           #   #          #          #\n
  #    v.0.4.2    license open GPLv3          #    #         #          #\n
  #                                           #     #        #    #     #\n
  #                                                              # #    #\n
  #    Source URL: github.com/Nonie689/anti-rt-censorship-bot     #     #\n
  #                                                                     #\n
  #######################################################################\n
  \n
  \n"

}

banner

# Base settings!
cookies_file="cookies.txt"

# Comment if you have no problems with the DDOS protection mechanism!
#inject_cookie="Cookie: $(cat $cookies_file)"

database_folder="./"

gen_timestamp() {
  echo $(date +%Y.%m.%d-%H\:%M)
}

#File naming Settings!
timestamp="$(gen_timestamp)"
new_name="File-de.rt.com_$timestamp-x-original.rss"
converted_rss="File-de.rt.com_$timestamp-telegramm.rss"

TARGETURL=rtde.xyz

## Work Step 1 - Start checking !
### Check changes of rss!

while true; do

# Check first run!

previos_file_chk=$(ls -l --sort=time ${database_folder}File-de.rt.com_*telegramm.rss | wc -l)

if test $previos_file_chk -gt 0 ; then
  latest_rss_filename="$database_folder$(echo File-de.rt.com_$(ls -l --sort=time ${database_folder}File-de.rt.com_*telegramm.rss | head -1 | awk -F "File-de.rt.com_" '{print $2}'))"
fi

echo "  $(echo $(gen_timestamp)) - Request .rss from Russia Today!"

#curl "de.rt.com/feeds/news/" --referer https://mail.rt.com/ -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.5' -H 'DNT: 1' -H 'Connection: keep-alive' -H "$inject_cookie"  -H 'Upgrade-Insecure-Requests: 1' -H 'Sec-Fetch-Dest: document' -H 'Sec-Fetch-Mode: navigate' -H 'Sec-Fetch-Site: same-origin' -H 'Sec-Fetch-User: ?1' -H 'TE: trailers' -H 'Pragma: no-cache' -H 'Cache-Control: no-cache' -o "${database_folder}${new_name}" > /dev/null 2>&1 
curl 'https://de.rt.com/feeds/news/' -H 'User-Agent:  FeedFetcher-Google; (+http://www.google.com/feedfetcher.html)' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.5' -H 'DNT: 1' -H 'Connection: keep-alive' -H 'Upgrade-Insecure-Requests: 1' -H 'Sec-Fetch-Dest: document' -H 'Sec-Fetch-Mode: navigate' -H 'Sec-Fetch-Site: none' -H 'Cache-Control: max-age=0' -o "${database_folder}${new_name}" > /dev/null 2>&1
## Check response!
check_ddos_protect_wall=$(echo $(grep -E "<title>DDOS-GUARD</title>" "$database_folder$new_name" )| wc -l)

if test $check_ddos_protect_wall -gt 0 ; then
   echo
   echo "Please Enter a new valid raw cookie for rt.com - the system has kicked us out!"
   echo "Cookie ID:"
   read new_cookie
   echo $new_cookie > $cookies_file
   rm -f "$database_folder$new_name" 2 > /dev/null
   if test -z $cookie_inject; then
     echo
     echo "Don't forget to uncomment the cookie_inject variable!"
   fi
   continue
fi 

# Change the wrong domain's on the rss file!

sed 's|'de.rt.com'|'"${TARGETURL}"'|g' "$database_folder$new_name"  > "$database_folder$converted_rss"

if test $previos_file_chk -gt 0 ; then
  if cmp --silent -- "$database_folder$converted_rss" "$latest_rss_filename"; then
    echo
    echo "No changes at the rss file!"
    rm "$database_folder$converted_rss"
    rm "$database_folder$new_name"
  else
    echo
    echo "Found changes!"
    diff -u "$latest_rss_filename" "$database_folder$converted_rss" | grep -E "^\+"
  fi
fi

# Restart Loop sequence in 10 minutes!
echo
echo "________________________________"
echo
echo " Job done, will restart the main sequence for de.rt.com in 10 minutes!"
sleep 600
echo
echo " Time is up - Job is waking up and restart the work!"
echo
sleep 5

done
