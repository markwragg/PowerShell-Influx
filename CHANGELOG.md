# Change Log

## !Deploy

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
