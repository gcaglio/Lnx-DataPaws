#!/bin/bash 

source ./config.cfg

if [ "$processes_module" = true ]; then
    echo "INFO : running process module"
    paws_hostname=$(hostname -f)
    f_hostname=$unique_hostname
    timestamp=$(date +%s)

    # Cicla sui primi 50 processi ordinati per utilizzo CPU
    ps -eo pid,pcpu,pmem,vsize,rss,comm,args --sort=-pcpu | head -n 51 | tail -n +2 | while read -r pid cpu mem vsize rss comm args; do
        # Prepara i tag specifici del processo
        escaped_args=$(echo "$args" | sed 's/"/\\"/g')
        metric_tags_with_pid="$metric_tags, \"pid:$pid\", \"executable:$comm\", \"cmdline:$escaped_args\", \"paws_hostname:$paws_hostname\" "

        # Crea il payload JSON per il processo corrente
        metric_data=$(cat << EOF
        {
            "series": [
                {
                    "metric": "datapaws.process.cpu",
                    "points": [[ $timestamp, $cpu ]],
                    "type": "gauge",
                    "host": "$f_hostname",
                    "tags": [ $metric_tags_with_pid ]
                },
                {
                    "metric": "datapaws.process.memory",
                    "points": [[ $timestamp, $mem ]],
                    "type": "gauge",
                    "host": "$f_hostname",
                    "tags": [ $metric_tags_with_pid ]
                },
                {
                    "metric": "datapaws.process.vsize",
                    "points": [[ $timestamp, $vsize ]],
                    "type": "gauge",
                    "host": "$f_hostname",
                    "tags": [ $metric_tags_with_pid ]
                },
                {
                    "metric": "datapaws.process.rss",
                    "points": [[ $timestamp, $rss ]],
                    "type": "gauge",
                    "host": "$f_hostname",
                    "tags": [ $metric_tags_with_pid ]
                }
            ]
        }
EOF
        )

        # Invia la metrica a Datadog
        curl -X POST "$datadog_endpoint" \
        -H "Content-Type: application/json" \
        -H "DD-API-KEY: $dd_api_key" \
        -d "$metric_data"

    done

    echo "INFO : end process module"
fi

