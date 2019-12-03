# Change Log

## [1.0.99] - 2019-12-03

* [Feature] Multiple fields for a single metric are written via a single Influx line protocol entry.
* [Feature] Tags are now sorted alphabetically to improve performance.
* [Bug] The full set of special characters are now escaped when writing to Influx.

Thanks [@Trovalo](https://github.com/Trovalo) for these enhancements!

## [1.0.80] - 2018-08-22

- [Feature] Added a `-Credential` parameter to `Write-Influx` as requested in #9. This allows `Write-Influx` to be used with instances of Influx where authentication has been enabled (disabled by default).
