#!/bin/bash 

source ./config.cfg

if [ "$network_module" = true ]; then
    echo "INFO : running network module"
    paws_hostname=$(hostname -f)
    f_hostname=$unique_hostname

    timestamp=$(date +%s)

    # Cicla su ciascuna interfaccia di rete attiva
    for iface in $(ls /sys/class/net); do
        # Raccogli le metriche per l'interfaccia corrente
        rx_bytes=$(cat /sys/class/net/$iface/statistics/rx_bytes)
        tx_bytes=$(cat /sys/class/net/$iface/statistics/tx_bytes)
        rx_packets=$(cat /sys/class/net/$iface/statistics/rx_packets)
        tx_packets=$(cat /sys/class/net/$iface/statistics/tx_packets)
        rx_errors=$(cat /sys/class/net/$iface/statistics/rx_errors)
        tx_errors=$(cat /sys/class/net/$iface/statistics/tx_errors)

        # Crea il set di tag per questa interfaccia
        metric_tags_with_iface="$metric_tags, \"interface:$iface\", \"paws_hostname:$paws_hostname\" "

        # Costruisce il payload JSON per le metriche di rete
        metric_data=$(cat << EOF
        {
            "series": [
                {
                    "metric": "datapaws.network.rx_bytes",
                    "points": [[ $timestamp, $rx_bytes ]],
                    "type": "gauge",
                    "host": "$f_hostname",
                    "tags": [ $metric_tags_with_iface ]
                },
                {
                    "metric": "datapaws.network.tx_bytes",
                    "points": [[ $timestamp, $tx_bytes ]],
                    "type": "gauge",
                    "host": "$f_hostname",
                    "tags": [ $metric_tags_with_iface ]
                },
                {
                    "metric": "datapaws.network.rx_packets",
                    "points": [[ $timestamp, $rx_packets ]],
                    "type": "gauge",
                    "host": "$f_hostname",
                    "tags": [ $metric_tags_with_iface ]
                },
                {
                    "metric": "datapaws.network.tx_packets",
                    "points": [[ $timestamp, $tx_packets ]],
                    "type": "gauge",
                    "host": "$f_hostname",
                    "tags": [ $metric_tags_with_iface ]
                },
                {
                    "metric": "datapaws.network.rx_errors",
                    "points": [[ $timestamp, $rx_errors ]],
                    "type": "gauge",
                    "host": "$f_hostname",
                    "tags": [ $metric_tags_with_iface ]
                },
                {
                    "metric": "datapaws.network.tx_errors",
                    "points": [[ $timestamp, $tx_errors ]],
                    "type": "gauge",
                    "host": "$f_hostname",
                    "tags": [ $metric_tags_with_iface ]
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

    echo "INFO : end network module"
fi

