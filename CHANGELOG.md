# Change Log

## [2.0.2] - 2026-09-25

* [Bug] Fixed [#16](https://github.com/markwragg/PowerShell-Influx/issues/16) where a `[datetime]` metric value was written using its culture-dependent `ToString()` representation, which is not valid InfluxDB Line Protocol and always failed the write with `invalid number`. `[datetime]` metric values are now converted to a Unix nanosecond integer field. Also, a metric value that's a complex object with no meaningful `ToString()` (e.g. certain SDK objects) now emits a `Write-Warning` instead of silently writing the type name. Boolean metric values are unaffected - InfluxDB requires them unquoted, which this module already did correctly.

## [2.0.1] - 2026-09-25

* [Bug] Fixed [#36](https://github.com/markwragg/PowerShell-Influx/issues/36) where tag/measurement/field-key values containing a backslash (e.g. a Windows path like `C:\`) were incorrectly escaped to `C:\\`, resulting in an invalid tag value once written to InfluxDB. InfluxDB Line Protocol does not require escaping the backslash character outside of quoted field values. Note: InfluxDB's line protocol parser cannot accept a measurement, tag key/value or field key that *ends* in a backslash under any escaping scheme (a limitation of InfluxDB itself, not this module) - `Write-Influx`/`Write-InfluxUDP`/`ConvertTo-InfluxLineString` now emit a `Write-Warning` when this occurs so it's clear why InfluxDB rejects the write.

## [2.0.0] - 2026-09-25

* [Breaking] Removed the unused `-Database` and `-Server` parameters from `Get-DatastoreMetric`. They had no effect (that function never writes to Influx); use the identically-named parameters on `Send-DatastoreMetric` instead.

## [1.0.103] - 2024-09-07

* [Feature] Added `-TrustServerCertificate` to `Write-Influx` to ignore SSL certificate validation errors. Thanks [@Max-Lyulchenko](https://github.com/max-lyulchenko)!
* [Feature] Added `-SingleLineMetrics` to `Write-Influx` to combine metrics into a single call of the Influx Line Protocol. Thanks [@Max-Lyulchenko](https://github.com/max-lyulchenko)!

## [1.0.102] - 2023-05-06

* [Bug] Merged fix for [#38](https://github.com/markwragg/PowerShell-Influx/issues/38) where using `Write-Influx` or `Write-InfluxUDP` without tags resulted in an error due to an empty hashtable being treated as true. Thanks [@DerT94](https://github.com/DerT94)
* [Feature] Added a -BulkSize parameter to `Write-Influx` with a default of 5000 (the recommended bulk size). When using `-Bulk` writes will occur when the number of metrics in the bulk reach this size. Thanks [@DerT94](https://github.com/DerT94)

## [1.0.101] - 2021-12-11

* [Feature] Added support for Influx v2.x to the `Write-Influx` cmdlet. `Write-Influx` still supports Influx v1, which is assumed if the `-Database` parameter is used. If the new `-Organisation` `-Bucket` and `-Token` parameters are used then Influx v2 is assumed. Thanks [@Robin Hermann](https://github.com/R-Studio) for contributing most of this change.

## [1.0.100] - 2020-02-21

* [Bug] Merged fix [#31](https://github.com/markwragg/PowerShell-Influx/pull/31) from [@Trovalo](https://github.com/Trovalo) where `Out-InfluxEscapeString` was escaping more characters than were necessary.

## [1.0.99] - 2019-12-03

* [Feature] Multiple fields for a single metric are written via a single Influx line protocol entry.
* [Feature] Tags are now sorted alphabetically to improve performance.
* [Bug] The full set of special characters are now escaped when writing to Influx.

Thanks [@Trovalo](https://github.com/Trovalo) for these enhancements!

## [1.0.80] - 2018-08-22

- [Feature] Added a `-Credential` parameter to `Write-Influx` as requested in #9. This allows `Write-Influx` to be used with instances of Influx where authentication has been enabled (disabled by default).
