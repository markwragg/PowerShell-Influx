# PowerShell-Influx

[<img src="influx-logo.png" align="right" width="100">](https://www.influxdata.com/)

[![Build Status](https://github.com/markwragg/PowerShell-Influx/actions/workflows/build.yml/badge.svg)](https://github.com/markwragg/PowerShell-Influx/actions/workflows/build.yml)
![coverage](https://img.shields.io/badge/coverage-93%25-brightgreen.svg)
[![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/Influx?label=PS%20Gallery)](https://www.powershellgallery.com/packages/Influx)
[![PowerShell Gallery Downloads](https://img.shields.io/powershellgallery/dt/Influx?color=D3D3D3)](https://www.powershellgallery.com/packages/Influx)

This is a PowerShell module for interacting with the time-series database platform [InfluxDB](https://www.influxdata.com/). Its primary purpose is to provide a consistent experience for writing metrics into Influx via the REST API (InfluxDB v1.x and v2.x), UDP or StatsD.

## Purpose

This module was written to allow metrics from different sources to be written to InfluxDB, for presentation via one or more Grafana dashboards. By using this module, InfluxDB and Grafana you can create and populate interactive dashboards like these (note: sensitive data has been redacted from these screenshots):

<p align="center">
<img src="https://wragg.io/content/images/2018/02/Grafana-Example-2.png" height=200>  <img src="https://wragg.io/content/images/2018/02/Grafana-TFS-Build-Dashboard.png" height=200>
</p>

For more details on how to implement these tools, [check out my blog post](https://wragg.io/windows-based-grafana-analytics-platform-via-influxdb-and-powershell/). For more information on how to use the Influx PowerShell module, read on below.

## Installation

Install the module from the PowerShell Gallery:

```powershell
Install-Module Influx
```

Or:

```powershell
Install-PSResource Influx
```

## Cmdlets

A full list of implemented cmdlets is provided below for your reference. Use `Get-Help <cmdlet name>` or follow the links below to learn more about their usage.

### Core Cmdlets

Cmdlet                                                                    | Description
--------------------------------------------------------------------------| --------------------------------------------------------------------
[Write-Influx](Documentation/Write-Influx.md)                             | Writes to Influx via the REST API (InfluxDB v1.x or v2.x).
[Write-InfluxUDP](Documentation/Write-InfluxUDP.md)                       | Writes to Influx via UDP.
[Write-StatsD](Documentation/Write-StatsD.md)                             | Writes to Influx via a StatsD listener.
Send-Statsd                                                               | Alias of `Write-StatsD` (for backwards compatibility).
[ConvertTo-InfluxLineString](Documentation/ConvertTo-InfluxLineString.md) | Converts metrics to the Influx line protocol format, output as strings.
[ConvertTo-Metric](Documentation/ConvertTo-Metric.md)                     | Converts the specified properties of any object to a metric object, which can then be easily transmitted to Influx by piping to one of the `Write-*` cmdlets.
[ConvertTo-StatsDString](Documentation/ConvertTo-StatsDString.md)         | Converts a metric object output from one of the `Get-SomeMetric` cmdlets to StatsD string format. This is also performed automatically if a metric object is piped to `Write-StatsD`.

### Third party tool Cmdlets

Cmdlet                                                                        | Description
------------------------------------------------------------------------------| --------------------------------------------------------------------
[Get-3ParSystemMetric](Documentation/Get-3ParSystemMetric.md)                 | Returns a metric object for 3PAR systems.
[Get-3ParVirtualVolumeMetric](Documentation/Get-3ParVirtualVolumeMetric.md)   | Returns a metric object for 3PAR virtual volumes.
[Get-DatacenterMetric](Documentation/Get-DatacenterMetric.md)                 | Returns a metric object for VMware datacenters.
[Get-DatastoreClusterMetric](Documentation/Get-DatastoreClusterMetric.md)     | Returns a metric object for VMware datastore clusters.
[Get-DatastoreMetric](Documentation/Get-DatastoreMetric.md)                   | Returns a metric object for VMware datastores.
[Get-HostMetric](Documentation/Get-HostMetric.md)                             | Returns a metric object for VMware hosts.
[Get-IsilonStoragePoolMetric](Documentation/Get-IsilonStoragePoolMetric.md)   | Returns a metric object for Isilon storage pools.
[Get-ResourcePoolMetric](Documentation/Get-ResourcePoolMetric.md)             | Returns a metric object for VMware resource pools.
[Get-TFSBuildMetric](Documentation/Get-TFSBuildMetric.md)                     | Returns a metric object for TFS builds.
[Get-VMMetric](Documentation/Get-VMMetric.md)                                 | Returns a metric object for VMware virtual machines.
[Send-3ParSystemMetric](Documentation/Send-3ParSystemMetric.md)               | Sends metrics via the Influx REST API for 3PAR systems.
[Send-3ParVirtualVolumeMetric](Documentation/Send-3ParVirtualVolumeMetric.md) | Sends metrics via the Influx REST API for 3PAR virtual volumes.
[Send-DatacenterMetric](Documentation/Send-DatacenterMetric.md)               | Sends metrics via the Influx REST API for VMware datacenters.
[Send-DatastoreClusterMetric](Documentation/Send-DatastoreClusterMetric.md)   | Sends metrics via the Influx REST API for VMware datastore clusters.
[Send-DatastoreMetric](Documentation/Send-DatastoreMetric.md)                 | Sends metrics via the Influx REST API for VMware datastores.
[Send-HostMetric](Documentation/Send-HostMetric.md)                           | Sends metrics via the Influx REST API for VMware hosts.
[Send-IsilonStoragePoolMetric](Documentation/Send-IsilonStoragePoolMetric.md) | Sends metrics via the Influx REST API for Isilon storage pools.
[Send-ResourcePoolMetric](Documentation/Send-ResourcePoolMetric.md)           | Sends metrics via the Influx REST API for VMware resource pools.
[Send-TFSBuildMetric](Documentation/Send-TFSBuildMetric.md)                   | Sends metrics via the Influx REST API for TFS builds.
[Send-VMMetric](Documentation/Send-VMMetric.md)                               | Sends metrics via the Influx REST API for VMware virtual machines.

## Usage

### Writing to Influx

There are 3 methods for writing to Influx currently implemented:

1. `Write-Influx` which uses the Influx REST API to submit metrics via TCP. It supports both InfluxDB v1.x (`-Database` and `-Credential`) and InfluxDB v2.x (`-Organisation`, `-Bucket` and `-Token`).
2. `Write-InfluxUDP` which transmits metrics to an Influx UDP listener.
3. `Write-StatsD` which transmits metrics via UDP to a StatsD listener (the StatsD listener can be enabled via the Influx Telegraf component -- see the StatsD Server section in the telegraf.conf).

For example:

```powershell
$Metric = @{
    Measure = 'Server'
    Tags    = @{ Hostname = $env:COMPUTERNAME }
    Metrics = @{ Memory = 50; CPU = 10 }
}

# REST API (InfluxDB v1.x)
Write-Influx @Metric -Database Web -Server http://myinflux.local:8086 -Verbose

# REST API with authentication (InfluxDB v1.x)
Write-Influx @Metric -Database Web -Server http://myinflux.local:8086 -Credential (Get-Credential) -Verbose

# REST API (InfluxDB v2.x)
Write-Influx @Metric -Organisation myorg -Bucket Web -Token $InfluxToken -Server http://myinflux.local:8086 -Verbose

# Influx UDP
Write-InfluxUDP @Metric -IP 1.2.3.4 -Port 8089 -Verbose

# StatsD UDP
Write-StatsD "Server.CPU,Hostname=$($env:COMPUTERNAME):10|g" -IP 1.2.3.4 -Port 8125 -Verbose
```

> With `Write-InfluxUDP` the destination database is determined by the configuration of the UDP listener on the Influx server, not by the client.

### Collecting metrics from third party tools

This project was created so that PowerShell could be used to routinely query various infrastructure metrics and then send those metrics into Influx for storage, where they could then be presented via a Grafana dashboard.

As such the module also contains a number of cmdlets for retrieving data from various sources. Current implementations include VMware, 3PAR, Isilon and TFS (see [Third party tool Cmdlets](#third-party-tool-cmdlets) above).

The `Get-SomeMetric` cmdlets return a `Metric` type object which can be consumed by any of the `Write-*` cmdlets above via the pipeline or the `-InputObject` parameter. For example:

```powershell
# Get metrics for VMware datastores and write to Influx via the REST API
Get-DatastoreMetric | Write-Influx -Database vmware -Server http://myinflux.local:8086

# Get metrics for 3PAR systems and write to Influx via the Influx UDP listener
Get-3ParSystemMetric -SANIPAddress '3.4.5.6' -SANUserName someuser -SANPasswordFile 'C:\some3parpasswordfile.txt' | Write-InfluxUDP -IP 1.2.3.4

# Get TFS build data and send to Influx via StatsD
# (Write-StatsD converts metric objects received via the pipeline to StatsD formatted strings automatically, as gauges)
Get-TFSBuildMetric -TFSRootURL 'https://mytfsurl.local/tfs' -TFSCollection somecollection -TFSProject someproject | Write-StatsD -IP 1.2.3.4

# Use ConvertTo-StatsDString first if you need a StatsD metric type other than gauge (e.g. 'c' for counter)
Get-TFSBuildMetric -TFSRootURL 'https://mytfsurl.local/tfs' -TFSCollection somecollection -TFSProject someproject | ConvertTo-StatsDString -Type c | Write-StatsD -IP 1.2.3.4
```

#### Send cmdlets

There are also `Send-SomeMetric` cmdlets that were implemented to retrieve metrics from a data source and send them to Influx via the REST API in one step. These continue to exist for backwards compatibility, but for more flexibility use the `Get-SomeMetric` cmdlets and pipe their results to whatever `Write-*` method you want to use for interacting with Influx.

### Converting other objects to metrics

The results of other PowerShell commands, or custom objects, can also be sent to Influx. Simply map the object properties to a `Metric` object using the `ConvertTo-Metric` cmdlet:

```powershell
# Send data from Get-Process to InfluxDB using the REST API with authentication
Get-Process -Name chrome |
    ConvertTo-Metric -Measure process -MetricProperty CPU, PagedMemorySize, Handles -TagProperty ProcessName |
    Write-Influx -Database windows_system_monitor -Server http://myinflux.local:8086 -Credential (Get-Credential) -Verbose
```

#### Choosing tags and metrics

> Influx indexes tags, so use them for values you want to group or filter by that have a limited set of possible values (e.g. a host or process name). Numeric values that change frequently, or unique identifiers such as a process ID, should be metrics instead, as using them as tags creates a new series for every distinct value.

### Implementation Example

Here is an example script which could be run as a scheduled task every 5 minutes to send stats from various sources into Influx. Note this requires a number of dependent modules be present such as the VMware PowerCLI cmdlets.

> This script uses the `Send-SomeMetric` cmdlets which combine the equivalent `Get-SomeMetric` cmdlet with `Write-Influx` to transmit metrics in one command via the REST API. By default these write to `http://localhost:8086`; use `-Server` and `-Database` to change this.

```powershell
Import-Module Influx

# VMware
Connect-VIServer 1.2.3.4 | Out-Null

Send-HostMetric
Send-DatastoreMetric
Send-ResourcePoolMetric
Send-DatastoreClusterMetric
Send-DatacenterMetric

# 3PAR
Send-3ParSystemMetric -SANIPAddress '3.4.5.6' -SANUserName someuser -SANPasswordFile 'C:\some3parpasswordfile.txt'

# Isilon
# Warning: Disable-SSLValidation turns off certificate validation for the whole PowerShell session.
# Only use it where the Isilon uses a self-signed certificate you trust.
Import-Module SSLValidation
Disable-SSLValidation

Send-IsilonStoragePoolMetric -IsilonName someisilon -Cluster test -IsilonPasswordFile 'C:\someIsilonpasswordfile.txt'

# TFS
Send-TFSBuildMetric -TFSRootURL 'https://mytfsurl.local/tfs' -TFSCollection somecollection -TFSProject someproject -Database tfs
```
