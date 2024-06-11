#!/bin/bash

# Your SecurityTrails API key
API_KEY="SECURITY-TRAILS-API"

read -p "Enter the domain: " DOMAIN

API_URL="https://api.securitytrails.com/v1/domain/$DOMAIN/subdomains"

OUTPUT_FILE="subdomains.txt"

> $OUTPUT_FILE

PAGE=1

while true; do
    response=$(curl -s -H "APIKEY: $API_KEY" "$API_URL?children_only=true&page=$PAGE")

    if [ $? -ne 0 ]; then
        echo "Error: Failed to fetch data from SecurityTrails API"
        exit 1
    fi

    subdomains=$(echo $response | jq -r '.subdomains[]?')

    if [ -z "$subdomains" ]; then
        break
    fi

    for subdomain in $subdomains; do
        full_subdomain="$subdomain.$DOMAIN"
        if ! grep -q "^$full_subdomain$" "$OUTPUT_FILE"; then
            echo $full_subdomain | tee -a $OUTPUT_FILE
        fi
    done

    PAGE=$((PAGE + 1))
done

echo "All subdomains have been saved to $OUTPUT_FILE"
