# fluent-plugin-utmpx

[Fluentd](https://fluentd.org/) input plugin to extract `/var/log/wtmp` or `/var/run/utmp`.

## Installation

### RubyGems

```
$ gem install fluent-plugin-utmpx
```

### Bundler

Add following line to your Gemfile:

```ruby
gem "fluent-plugin-utmpx"
```

And then execute:

```
$ bundle
```

## Configuration

## Fluent::Plugin::UtmpxInput

| parameter | type               | description                                     | default |
|-----------|--------------------|-------------------------------------------------|---------|
| path      | string (required)  | Path to wtmp,utmp                               |         |
| tag       | string (required)  | Tag string                                      |         |
| interval  | integer (optional) | Interval to check wtmp/utmp (N seconds)         | `10`    |
| pos_file  | string (required)  | Record the position it last read into this file |         |

## Usage

Here is the example to use `utmpx` input plugin.

```
<source>
  @type utmpx
  tag wtmp
  pos_file wtmp.pos
  path /var/log/wtmp
</source>

<match **>
  @type stdout
</match>
```

Then you can retrieve these events.

```
2021-03-29 09:05:20.576275000 +0900 utmp: {"user":"kenhys","type":"BOOT_TIME","pid":0,"line":"pts/10","host":""}
2021-03-29 09:05:24.585670000 +0900 utmp: {"user":"kenhys","type":"RUN_LVL","pid":53,"line":"pts/10","host":""}
2021-03-29 09:05:24.586492000 +0900 utmp: {"user":"kenhys","type":"LOGIN_PROCESS","pid":1598,"line":"pts/10","host":""}
2021-03-29 09:06:16.805749000 +0900 utmp: {"user":"kenhys","type":"USER_PROCESS","pid":2268,"line":"pts/10","host":""}
2021-03-29 09:06:31.114443000 +0900 utmp: {"user":"kenhys","type":"USER_PROCESS","pid":9643,"line":"pts/10","host":""}
2021-03-29 09:06:31.504274000 +0900 utmp: {"user":"kenhys","type":"USER_PROCESS","pid":9643,"line":"pts/10","host":""}
2021-03-29 09:06:31.944433000 +0900 utmp: {"user":"kenhys","type":"USER_PROCESS","pid":9643,"line":"pts/10","host":""}
2021-03-29 09:06:32.344603000 +0900 utmp: {"user":"kenhys","type":"USER_PROCESS","pid":9643,"line":"pts/10","host":""}
2021-03-29 17:37:04.883202000 +0900 utmp: {"user":"kenhys","type":"DEAD_PROCESS","pid":9643,"line":"pts/10","host":""}
2021-03-29 17:36:55.729927000 +0900 utmp: {"user":"kenhys","type":"DEAD_PROCESS","pid":9643,"line":"pts/10","host":""}
```


## Copyright

* Copyright(c) 2021- Kentaro Hayashi
* License
  * Apache License, Version 2.0
