# PowerShell-Influx

[![Build Status](https://dev.azure.com/markwragg/GitHub/_apis/build/status/markwragg.PowerShell-Influx?branchName=master)](https://dev.azure.com/markwragg/GitHub/_build/latest?definitionId=4&branchName=master) ![Test Coverage](https://img.shields.io/badge/coverage-96%25-brightgreen.svg?maxAge=60)

This is a PowerShell module for interacting with the time-series database platform Influx: https://www.influxdata.com/. At the moment the primary purpose is to enable a consistent experience for writing metrics in to Influx via the REST API, UDP or StatsD. 

# Purpose

This module was written to allow metrics from different sources to be written to InfluxDB, for presentation via one or more Grafana Dashboards. By utilising this module, InfluxDB and Grafana you can create and populate interactive dashboards like these (note: sensitive data has been redacted from these screenshots):

<p align="center">
<img src="http://wragg.io/content/images/2018/02/Grafana-Example-2.png" height=200>  <img src="http://wragg.io/content/images/2018/02/Grafana-TFS-Build-Dashboard.png" height=200>
</p>

For more details on how to implement these tools, [check out my blog post](http://wragg.io/windows-based-grafana-analytics-platform-via-influxdb-and-powershell/). For more information on how to use the Influx PowerShell module, read on below.

# Installation

The module is published in the PSGallery, so if you have PowerShell 5 can be installed by running:
```
Install-Module Influx -Scope CurrentUser
```

# Usage

There are 3 methods for writing to Influx currently implemented:

1. `Write-Influx` which uses the Influx REST API to submit metrics via TCP.
2. `Write-InfluxUDP` which transmits metrics to an Influx UDP listener.
3. `Write-StatsD` which transmits metrics via UDP to a StatsD listener (the StatsD listener can be enabled via the Influx Telegraf component -- see the Statsd Server section in the telegraf.conf).

For example:

```
#REST API
Write-Influx -Measure Server -Tags @{Hostname=$env:COMPUTERNAME} -Metrics @{Memory=50;CPU=10} -Database Web -Server http://myinflux.local:8086 -Verbose

#REST API with authentication
Write-Influx -Measure Server -Tags @{Hostname=$env:COMPUTERNAME} -Metrics @{Memory=50;CPU=10} -Database Web -Server http://myinflux.local:8086 -Credential (Get-Credential) -Verbose
 
#Influx UDP
Write-InfluxUDP -Measure Server -Tags @{Hostname=$env:COMPUTERNAME} -Metrics @{Memory=50;CPU=10} -Database Web -IP 1.2.3.4 -Port 8089 -Verbose
 
#StatsD UDP
Write-Statsd "Server.CPU,Hostname=$($env:COMPUTERNAME):10|g" -IP 1.2.3.4 -Port 8125 -Verbose
```

This project was created so that PowerShell could be used to routinely query various infrastructure metrics and then send those metrics in to Influx for storage, where they could then be presented via a Grafana dashboard.

As such the module also contains a number of cmdlets for retrieving data various sources. Current implementations include: VMWare, 3PAR, Isilon and TFS. You will find these cmdlets under `\Public\<source>`.

The `Get-SomeMetric` cmdlets return a `Metric` type object which can be consumed by any of the `Write-*` cmdlets above via the pipeline or the `-InputObject' parameter. For example:

```
# Get metrics for VMWare Datastores and write to Influx via the REST API
Get-DatastoreMetric | Write-Influx

# Get metrics for 3PAR Systems and write to Influx via the Influx UDP listener
Get-3ParSystemMetric -SANIPAddress '3.4.5.6' -SANUserName someuser -SANPasswordFile 'C:\some3parpasswordfile.txt' | Write-InfluxUDP

# Get TFS Build data and send to Influx via StatsD (note that Write-StatsD converts the metric object received via the pipleine to StatsD formatted strings automatically)
Get-TFSBuildMetric -TFSRootURL 'https://mytfsurl.local/tfs' -TFSCollection somecollection -TFSProject someproject -Database tfs | Write-StatsD -Type g
```

There are also `Send-SomeMetric` cmdlets that were implemented to retrieve metrics from a datasource and send it to Influx via the REST API in one step. These continue to exist for backwards compatibility, but for more flexibility use the `Get-SomeMetric` cmdlets and pipe their results to whatever `Write-*` method you want to use for interacting with Influx.

Results of other Powershell commands or custom objects can be sent to Influx. Simply map the object properties to a Metric object using the ConvertTo-Metric cmdlet.
```
#Send data from Get-Process to InfluxDB using the REST API with authentication
Get-Process -Name <__Processname__> | ConvertTo-Metric -Measure test -MetricProperty CPU,PagedmemorySize -TagProperty Handles,Id,ProcessName | Write-Influx -Database windows_system_monitor -Server http://<__InfluxEndpoint__>:8086 -Credential (Get-Credential) -Verbose
```

## Implementation Example

Here is an example script which could be run as a scheduled task every 5 minutes to send stats from various sources in to Influx. Note this requires a number of dependent modules be present such as the VMWare PowerShell cmdlets.

> This script uses the `Send-SomeMetric` cmdlets which combine the equivalent `Get-SomeMetric` cmdlet with `Write-Influx` to transmit metrics in one command via the REST API.

```
Import-Module Influx

#VMWARE
Connect-VIServer 1.2.3.4 | Out-Null

Send-HostMetric
Send-DatastoreMetric
Send-ResourcePoolMetric
Send-DatastoreClusterMetric
Send-DatacenterMetric

#3PAR
Send-3ParSystemMetric -SANIPAddress '3.4.5.6' -SANUserName someuser -SANPasswordFile 'C:\some3parpasswordfile.txt'

#Isilon
Import-Module SSLValidation
Disable-SSLValidation

Send-IsilonStoragePoolMetric -IsilonName someisilon -Cluster test -IsilonPasswordFile 'C:\someIsilonpasswordfile.txt'

#TFS
Send-TFSBuildMetric -TFSRootURL 'https://mytfsurl.local/tfs' -TFSCollection somecollection -TFSProject someproject -Database tfs
```

# Cmdlets

A full list of implemented cmdlets is provided below for your reference. Use `Get-Help <cmdlet name>` with these to learn more about their usage.

Cmdlet                       | Description
-----------------------------| --------------------------------------------------------------------
Get-3ParSystemMetric         | Returns a metric object for 3PAR systems.
Get-3ParVirtualVolumeMetric  | Returns a metric object for 3PAR virtual volumes.
Get-DatacenterMetric         | Returns a metric object for VMWare datacenters.
Get-DatastoreClusterMetric   | Returns a metric object for VMWare datastore clusters.
Get-DatastoreMetric          | Returns a metric object for VMWare datastores.
Get-HostMetric               | Returns a metric object for VMWare hosts.
Get-IsilonStoragePoolMetric  | Returns a metric object for Isilon storage pools.
Get-ResourcePoolMetric       | Returns a metric object for VMWare resource pools.
Get-TFSBuildMetric           | Returns a metric object for TFS builds.
Get-VMMetric                 | Returns a metric object for VMWare virtual machines.
Send-3ParSystemMetric        | Sends metrics via the Influx REST API for 3PAR systems.
Send-3ParVirtualVolumeMetric | Sends metrics via the Influx REST API for 3PAR virtual volumes.
Send-DatacenterMetric        | Sends metrics via the Influx REST API for VMWare datacenters.
Send-DatastoreClusterMetric  | Sends metrics via the Influx REST API for VMWare datastore clusters.
Send-DatastoreMetric         | Sends metrics via the Influx REST API for VMWare datastores.
Send-HostMetric              | Sends metrics via the Influx REST API for VMWare hosts.
Send-IsilonStoragePoolMetric | Sends metrics via the Influx REST API for Isilon storage pools.
Send-ResourcePoolMetric      | Sends metrics via the Influx REST API for VMWare resource pools.
Send-TFSBuildMetric          | Sends metrics via the Influx REST API for TFS builds.
Send-VMMetric                | Sends metrics via the Influx REST API for VMWare virtual machines.
Write-Influx                 | Writes to Influx via the REST API.
Write-InfluxUDP              | Writes to Influx via UDP.
Write-StatsD                 | Writes to Influx via a StatsD listener.
Send-Statsd                  | Alias of Write-StatsD (for backwards compatibility).
ConvertTo-StatsDString       | Converts a metric object output from one of the `Get-SomeMetric` cmdlets to StatsD string format. This is also performed automatically if a metric object is piped to `Write-StatsD`.
ConvertTo-Metric             | Converts the specified properties of any object to a metric object, which can then be easily transmitted to Influx by piping to one of the `Write-` cmdlets.
ConvertTo-InfluxLineString   | Convert metrics to the Influx line protocol format, output as strings.
