# CHANGELOG

## 0.5.0 (2021-04-02)

* Changed to keep compatibility with Fluentd 1.11 [GitHub#3] [GitHub#4]

## 0.4.0 (2021-03-31)

* Update to latest linux-utmpx 0.3.0
  This fixes the problem that unexpected TypeError is raised

## 0.3.0 (2021-03-30)

* Fixed a bug that the content of previous event is discarded
  with multiple event stream. In the previous version, it always return latest event.
* Changed to use linux-utmpx 0.2.0

## 0.2.0 (2021-03-29)

* `pos_file` configuration parameter was supported.

