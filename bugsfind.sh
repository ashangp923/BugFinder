#!/bin/bash

# Check if required tools are installed
check_tools() {
    local tools=("sqlmap" "curl" "nc" "wafw00f" "nikto" "nmap" "dirb" "wapiti")
    for tool in "${tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            echo "$tool is not installed. Please install it to use this script."
            exit 1
        fi
    done
}

# Function to perform reconnaissance
perform_recon() {
    target="$1"
    output_dir="$(dirname "$0")/bug_output"

    # Create an output directory if it doesn't exist and set permissions
    mkdir -p "$output_dir"
    chmod -R 755 "$output_dir"

    # Run SQLMap for database vulnerability scanning
    sqlmap -u "$target" --level 5 --risk 3 -o "$output_dir/sqlmap_scan.txt"

    # Use WAFW00F to detect web application firewalls (WAFs)
    wafw00f "$target" | tee "$output_dir/wafw00f_scan.txt"

    # Run Nikto for web vulnerability scanning
    nikto -h "$target" -output "$output_dir/nikto_scan.txt"

    # Run Nmap for port scanning
    nmap -p- -oN "$output_dir/nmap_scan.txt" "$target"

    # Run dirb for basic directory enumeration
    dirb "http://$target" /usr/share/wordlists/dirb/common.txt -o "$output_dir/dirb_scan.txt"

    # Run Wapiti for basic web vulnerability scanning
    wapiti -u "http://$target" -o "$output_dir/wapiti_scan"

    # Transfer files or packets to your website
    curl -T /home/ashan/helloMrbug.png "http://$target/upload.php"

    # Send a packet using netcat
    echo "Your packet data" | nc "$target" 80

    echo "Reconnaissance and testing completed. Results are saved in $output_dir"
}

# Check if a target is provided as an argument
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <TARGET>"
    exit 1
fi

target="$1"

check_tools
perform_recon "$target"

