#!/bin/bash 

source ./config.cfg


if [ "$disk_module" = true ]; then
    echo "INFO : running disk module"
    timestamp=$(date +%s)

    paws_hostname=$(hostname -f)
    f_hostname=$unique_hostname


    df -h | grep '^/dev/' | grep -v '^/dev/loop' | grep -v '^tmpfs' | grep -v '^udev' | while read -r line; do
        mountpoint=$(echo "$line" | awk '{print $6}')
        deviceid=$(echo "$line" | awk '{print $1}')
        used_percentage=$(echo "$line" | awk '{print $5}' | sed 's/%//')
        my_hostname=$(hostname -f)

    # Crea il payload JSON
    metric_data=$(cat << EOF
    {
        "series": [
            {
                "metric": "datapaws.disk.used",
                "points": [[ $(date +%s), $used_percentage ]],
                "type": "gauge",
                "host": "$f_hostname",
                "tags": [
                    $metric_tags, "device_id:$deviceid","mountpoint:$mountpoint","paws_hostname:$paws_hostname"
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


    done
    echo "INFO : end disk module"
fi

