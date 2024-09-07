# Change Log

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
