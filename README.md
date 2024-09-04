# DNS Lookup Script

## Overview

This PowerShell script performs DNS lookups for a list of IP addresses and Fully Qualified Domain Names (FQDNs). It processes the input in parallel, outputs the results to a CSV file, and provides logging and a summary of the operations.

## Features

- Parallel processing of DNS lookups for improved performance
- Support for both IP addresses and FQDNs
- Optional custom DNS server specification
- Input validation to ensure only valid IP addresses or FQDNs are processed
- Logging of script activities and errors
- CSV output of lookup results
- Summary report of script execution

## Prerequisites

- PowerShell 5.1 or later
- Permissions to run PowerShell scripts on your system

## Setup

1. Download the `DNSLookup.ps1` script to your local machine.
2. Ensure you have a text file with the list of IP addresses and/or FQDNs you want to look up, one per line.

## Usage

Run the script from PowerShell, optionally specifying parameters:

```powershell
.\DNSLookup.ps1 [-inputFile <path>] [-outputFile <path>] [-logFile <path>] [-dnsServer <IP>]
```

Parameters:
- `-inputFile`: Path to the input text file (default: "input.txt")
- `-outputFile`: Path for the output CSV file (default: "output.csv")
- `-logFile`: Path for the log file (default: "script_log.txt")
- `-dnsServer`: IP address of a specific DNS server to use (optional)

Example:
```powershell
.\DNSLookup.ps1 -inputFile "myinput.txt" -outputFile "myresults.csv" -dnsServer "8.8.8.8"
```

## Input File Format

The input file should contain one IP address or FQDN per line. For example:

```
192.168.1.1
google.com
10.0.0.1
example.org
```

## Output

The script produces two main outputs:

1. A CSV file containing the lookup results with columns for IP Address and Hostname.
2. A log file with detailed information about the script's execution.

Additionally, a summary of the operation is appended to both the log file and the CSV file.

## Error Handling

The script includes basic error handling:
- Invalid input entries are skipped.
- Failed lookups are logged and marked as "Not Available" in the results.
- Any script-level errors are logged to assist in troubleshooting.

## Performance

The script uses PowerShell's parallel processing capabilities to improve performance when dealing with a large number of entries. By default, it processes up to 10 lookups concurrently.

## Customization

You can modify the script to adjust the parallel processing limit or add additional functionality as needed. Look for the `-ThrottleLimit` parameter in the script to change the number of concurrent operations.

## License

MIT

## Contributing

Contributions to improve the script are welcome. Please submit a pull request or open an issue to discuss proposed changes.

## Support

For questions or issues, please open an issue in the project repository.

