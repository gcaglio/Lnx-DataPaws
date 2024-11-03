#!/bin/bash 

source ./config.cfg

if [ "$cpu_module" = true ]; then
    echo "INFO : running cpu module"
    paws_hostname=$(hostname -f)
    f_hostname=$unique_hostname


    timestamp=$(date +%s)
    #%Cpu(s):  0.0 us, 11.8 sy,  0.0 ni, 88.2 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
    cpu_user=$(top -b -n1 | grep "Cpu(s)" | awk '{print $2}')
    cpu_steal=$(top -b -n1 | grep "Cpu(s)" | awk '{print $16}')
    cpu_idle=$(top -b -n1 | grep "Cpu(s)" | awk '{print $8}')
    cpu_nice=$(top -b -n1 | grep "Cpu(s)" | awk '{print $6}')
    cpu_sys=$(top -b -n1 | grep "Cpu(s)" | awk '{print $4}')
    cpu_wa=$(top -b -n1 | grep "Cpu(s)" | awk '{print $10}')



    # Crea il payload JSON
    metric_data=$(cat << EOF
    {
        "series": [
            {
                "metric": "datapaws.cpu.user",
                "points": [[ $(date +%s), $cpu_user ]],
                "type": "gauge",
                "host": "$f_hostname",
                "tags": [
                    $metric_tags, "paws_hostname:$paws_hostname"
                ]
            },
            {
                "metric": "datapaws.cpu.steal",
                "points": [[ $(date +%s), $cpu_steal ]],
                "type": "gauge",
                "host": "$f_hostname",
                "tags": [
                    $metric_tags, "paws_hostname:$paws_hostname"
                ]
            },
            {
                "metric": "datapaws.cpu.idle",
                "points": [[ $(date +%s), $cpu_idle ]],
                "type": "gauge",
                "host": "$f_hostname",
                "tags": [
                    $metric_tags, "paws_hostname:$paws_hostname"
                ]
            },
            {
                "metric": "datapaws.cpu.iowait",
                "points": [[ $(date +%s), $cpu_wa ]],
                "type": "gauge",
                "host": "$f_hostname",
                "tags": [
                    $metric_tags, "paws_hostname:$paws_hostname"
                ]
            },
            {
                "metric": "datapaws.cpu.sys",
                "points": [[ $(date +%s), $cpu_sys ]],
                "type": "gauge",
                "host": "$f_hostname",
                "tags": [
                    $metric_tags, "paws_hostname:$paws_hostname"
                ]
            },
            {
                "metric": "datapaws.cpu.nice",
                "points": [[ $(date +%s), $cpu_nice ]],
                "type": "gauge",
                "host": "$f_hostname",
                "tags": [
                    $metric_tags, "paws_hostname:$paws_hostname"
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

    echo "INFO : end cpu module"
fi

