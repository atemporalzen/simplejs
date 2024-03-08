#!/bin/bash

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
BLUE=$(tput setaf 4)
RESET=$(tput sgr0)

if [ -z "$1" ]
then
   echo "${BLUE}Usage: simplejs.sh target.com ${RESET}"
else
   echo "${GREEN}[+] Gathering subdomains ${RESET}"
   assetfinder -subs-only $1 | grep $1 | httpx -silent -mc 200 | tee /tmp/subdomains_$1.txt > /dev/null 2>&1
   echo "${BLUE}Saved to /tmp/subdomains_$1.txt ${RESET}"
   echo "${GREEN}[+] Listing js files ${RESET}"
   cat /tmp/subdomains_$1.txt | unfurl domains | waybackurls | grep .js | httpx -silent -mc 200 | tee /tmp/js_$1.txt > /dev/null 2>&1
   echo "${BLUE}Saved to /tmp/js_$1.txt ${RESET}"
   echo "${GREEN}[+] Looking for disclosures${RESET}"
   
   # Specify the path to the URLs file
   urls_file="/tmp/js_$1.txt"
  
   # Nuclei js files
   nuclei -silent -l $urls_file -t ~/nuclei-templates/exposures | tee /tmp/nuclei_$1.txt
fi
