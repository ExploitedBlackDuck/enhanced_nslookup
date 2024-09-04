# Define the input and output file paths
param (
    [string]$inputFile = "input.txt",
    [string]$outputFile = "output.csv",
    [string]$logFile = "script_log.txt",
    [string]$dnsServer = ""
)

# Clear previous logs
Clear-Content -Path $logFile -ErrorAction SilentlyContinue

# Function to log messages
function Log-Message {
    param (
        [string]$message,
        [string]$type = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "$timestamp [$type] $message"
    Add-Content -Path $logFile -Value $logMessage
    Write-Output $logMessage
}

# Function to perform nslookup
function Perform-Nslookup {
    param (
        [string]$entry
    )
    try {
        if ($dnsServer) {
            $nslookupResult = nslookup $entry $dnsServer
        } else {
            $nslookupResult = nslookup $entry
        }
        if ($entry -match '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$') {
            # Entry is an IP address
            $hostnameLine = $nslookupResult | Select-String -Pattern "Name:"
            $hostname = if ($hostnameLine) { $hostnameLine.Line.Split(" ")[-1].Trim() } else { "Not Available" }
            $ipAddress = $entry
        } else {
            # Entry is an FQDN
            $ipAddressLine = $nslookupResult | Select-String -Pattern "Address:"
            $ipAddress = if ($ipAddressLine) { $ipAddressLine.Line.Split(" ")[-1].Trim() } else { "Not Available" }
            $hostname = $entry
        }
        return [PSCustomObject]@{
            IPAddress = $ipAddress
            Hostname  = $hostname
        }
    } catch {
        Log-Message ("Failed to perform nslookup for {0}: {1}" -f $entry, $_) "ERROR"
        return [PSCustomObject]@{
            IPAddress = if ($entry -match '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$') { $entry } else { "Not Available" }
            Hostname  = if ($entry -match '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$') { "Not Available" } else { $entry }
        }
    }
}

# Read and validate the list of IP addresses and FQDNs from the input file
$entries = Get-Content -Path $inputFile | Where-Object { 
    $_ -match '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' -or $_ -match '^([a-zA-Z0-9]+\.)+[a-zA-Z]{2,}$'
}

$totalEntries = $entries.Count
Log-Message "Starting DNS lookup for $totalEntries entries"

# Process entries with basic parallelism
$results = $entries | ForEach-Object -Parallel {
    $result = Perform-Nslookup -entry $_
    Log-Message ("Processed {0}: IP {1}, Hostname: {2}" -f $_, $result.IPAddress, $result.Hostname)
    $result
} -ThrottleLimit 10

# Export the results to a CSV file
$results | Export-Csv -Path $outputFile -NoTypeInformation

# Generate basic summary
$successfulLookups = ($results | Where-Object { $_.IPAddress -ne "Not Available" -and $_.Hostname -ne "Not Available" }).Count
$failedLookups = $totalEntries - $successfulLookups
$successRate = [math]::Round(($successfulLookups / $totalEntries) * 100, 2)

$summary = @"

Summary:
Total Entries: $totalEntries
Successful Lookups: $successfulLookups
Failed Lookups: $failedLookups
Success Rate: $successRate%
"@

Log-Message $summary
Add-Content -Path $outputFile -Value $summary

Log-Message "Script completed. Results written to $outputFile"
