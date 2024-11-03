#!/bin/bash

source config.cfg

# if config file DD_API_KEY is empty, use ENV variable
if [ -x $datadog_api_key ]; then
  export dd_api_key=$DD_API_KEY
  echo "INFO : using DD_API_KEY from env variable"
else
  export dd_api_key=$datadog_api_key
  echo "INFO : using DD_API_KEY from config file"
fi


## Run every module in NICE, every module will check if it's enabled or not 
## in the configuration
nice ./modules/cpu/cpu.sh
nice ./modules/load/load.sh
nice ./modules/disks/disks.sh
nice ./modules/processes/processes.sh
nice ./modules/networks/networks.sh

