#!/bin/bash

source ./config.cfg

if [ "$load_module" = true ]; then
    echo "INFO : running load module"
    paws_hostname=$(hostname -f)
    f_hostname=$unique_hostname

    timestamp=$(date +%s)
    load_1m=$(cat /proc/loadavg | awk '{print $1}')
    load_5m=$(cat /proc/loadavg | awk '{print $2}')
    load_15m=$(cat /proc/loadavg | awk '{print $3}')
    my_hostname=$(hostname -f)


    # Crea il payload JSON
    metric_data=$(cat << EOF
    {
        "series": [
            {
                "metric": "datapaws.load",
                "points": [[ $(date +%s), $load_1m ]],
                "type": "points",
                "host": "$f_hostname",
                "tags": [
                    $metric_tags, "paws_hostname:$paws_hostname", "load:1m"
                ]
            },
            {
                "metric": "datapaws.load",
                "points": [[ $(date +%s), $load_5m ]],
                "type": "points",
                "host": "$f_hostname",
                "tags": [
                    $metric_tags, "paws_hostname:$paws_hostname", "load:5m"
                ]
            },
            {
                "metric": "datapaws.load",
                "points": [[ $(date +%s), $load_15m ]],
                "type": "points",
                "host": "$f_hostname",
                "tags": [
                    $metric_tags, "paws_hostname:$paws_hostname", "load:15m"
                ]
            }


        ]
    }
EOF
    )

    # Invia la metrica a Datadog usando l'API
    curl -X POST "$datadog_endpoint" \
    -H "Content-Type: application/json" \
    -H "DD-API-KEY: $dd_api_key" \
    -d "$metric_data"


    echo "INFO : end load module"
fi

