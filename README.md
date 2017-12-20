# PowerShell-Influx

This is a PowerShell module for interacting with the time-series database platform Influx: https://www.influxdata.com/. At the moment the primary purpose is to enable a consistent experience for writing metrics in to Influx via the REST API. This is done via the `Write-Influx` cmdlet, which accepts hashtables for the key/value pair tag and metric data.

For example:

```
Write-Influx -Measure WebServer -Tags @{Server='Host01'; OS='Windows'} -Metrics @{CPU=100; Memory=50} -Database Web -Server http://myinflux.local:8086
```

This project was created so that PowerShell could be used to routinely query for various infrastructure metrics and then send those metrics in to Influx for storage, where they could then be presented via a Grafana dashboard.

The module also contains a number of implementation examples for sending data to Influx from various sources such as VMWare, 3PAR, Isilon and TFS. You will find these under `\Public\<source>`.

## Installation

The module is not currently published in the PSGallery. To install it clone/download the Influx folder to a PSModule directory.

## Usage Example

Here is an example script which could be run as a scheduled task every 5 minutes to send stats from various sources in to Influx. Note this requires a number of dependent modules be present such as the VMWare PowerShell cmdlets:

```
Import-Module Influx

#VMWARE
Connect-VIServer 1.2.3.4 | Out-Null

Send-HostMetrics
Send-DatastoreMetrics
Send-ResourcePoolMetrics
Send-DatastoreClusterMetrics
Send-DatacenterMetrics

#3PAR
Send-3ParSystemMetrics -SANIPAddress '3.4.5.6' -SANUserName someuser -SANPasswordFile 'C:\some3parpasswordfile.txt'

#Isilon
Import-Module SSLValidation
Disable-SSLValidation

Send-IsilonStoragePoolMetrics -IsilonName someisilon -Cluster test -IsilonPasswordFile 'C:\someIsilonpasswordfile.txt'

#TFS

Send-TFSBuildMetrics -TFSRootURL 'https://mytfsurl.local/tfs' -TFSCollection somecollection -TFSProject someproject -Database tfs
```
