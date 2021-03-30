# fluent-plugin-utmpx

[Fluentd](https://fluentd.org/) input plugin to extract `/var/log/wtmp` or `/var/run/utmp`.

This plugin uses [linux-utmpx](https://github.com/fluent-plugins-nursery/linux-utmpx) to parse above files.

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

| parameter | type               | description                             | default |
|-----------|--------------------|-----------------------------------------|---------|
| path      | string (required)  | Path to wtmp,utmp                       |         |
| tag       | string (required)  | Tag string                              |         |
| interval  | integer (optional) | Interval to check `path` (N seconds)    | `10`    |
| pos_file  | string (required)  | Record the position it last read into this file |         |


The extracted record contains:

| field | type   | description       |
|-------|--------|-------------------|
| type  | string | Type of login. It must be either `EMPTY`, `RUN_LVL`, `BOOT_TIME`, `NEW_TIME`, `OLD_TIME`, `INIT_PROCESS`, `LOGIN_PROCESS`, `USER_PROCESS`, `DEAD_PROCESS` or `ACCOUNTING`. |
| pid  | integer | Process ID |
| line  | string | Device name (e.g. `pts/N`) |
| user  | string | Username |
| host  | string | Hostname for remote login |

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
2021-03-05 09:03:42.629627000 +0900 wtmp: {"user":"kenhys","type":"RUN_LVL","pid":53,"line":"pts/8","host":"tmux(9528).%4"}
2021-03-05 09:03:46.521452000 +0900 wtmp: {"user":"kenhys","type":"INIT_PROCESS","pid":1673,"line":"pts/8","host":"tmux(9528).%4"}
2021-03-05 09:03:46.521452000 +0900 wtmp: {"user":"kenhys","type":"LOGIN_PROCESS","pid":1673,"line":"pts/8","host":"tmux(9528).%4"}
2021-03-05 09:03:58.026903000 +0900 wtmp: {"user":"kenhys","type":"USER_PROCESS","pid":3018,"line":"pts/8","host":"tmux(9528).%4"}
2021-03-05 09:05:21.940292000 +0900 wtmp: {"user":"kenhys","type":"USER_PROCESS","pid":10248,"line":"pts/8","host":"tmux(9528).%4"}
2021-03-05 09:05:22.473919000 +0900 wtmp: {"user":"kenhys","type":"USER_PROCESS","pid":10248,"line":"pts/8","host":"tmux(9528).%4"}
2021-03-05 09:05:22.921871000 +0900 wtmp: {"user":"kenhys","type":"USER_PROCESS","pid":10248,"line":"pts/8","host":"tmux(9528).%4"}
2021-03-05 09:05:23.337814000 +0900 wtmp: {"user":"kenhys","type":"USER_PROCESS","pid":10248,"line":"pts/8","host":"tmux(9528).%4"}
2021-03-05 09:05:23.753983000 +0900 wtmp: {"user":"kenhys","type":"USER_PROCESS","pid":10248,"line":"pts/8","host":"tmux(9528).%4"}
2021-03-05 09:05:24.170198000 +0900 wtmp: {"user":"kenhys","type":"USER_PROCESS","pid":10248,"line":"pts/8","host":"tmux(9528).%4"}
2021-03-05 20:54:58.325838000 +0900 wtmp: {"user":"kenhys","type":"DEAD_PROCESS","pid":10248,"line":"pts/8","host":"tmux(9528).%4"}
2021-03-05 20:54:58.941467000 +0900 wtmp: {"user":"kenhys","type":"DEAD_PROCESS","pid":10248,"line":"pts/8","host":"tmux(9528).%4"} 
2021-03-05 20:54:59.459935000 +0900 wtmp: {"user":"kenhys","type":"DEAD_PROCESS","pid":10248,"line":"pts/8","host":"tmux(9528).%4"} 
2021-03-05 20:54:59.923351000 +0900 wtmp: {"user":"kenhys","type":"DEAD_PROCESS","pid":10248,"line":"pts/8","host":"tmux(9528).%4"} 
2021-03-05 21:31:43.002278000 +0900 wtmp: {"user":"kenhys","type":"DEAD_PROCESS","pid":10248,"line":"pts/8","host":"tmux(9528).%4"} 
2021-03-05 21:31:43.900405000 +0900 wtmp: {"user":"kenhys","type":"DEAD_PROCESS","pid":10248,"line":"pts/8","host":"tmux(9528).%4"} 
2021-03-05 21:32:06.755036000 +0900 wtmp: {"user":"kenhys","type":"DEAD_PROCESS","pid":0,"line":"pts/8","host":"tmux(9528).%4"}
```


## Copyright

* Copyright(c) 2021- Kentaro Hayashi
* License
  * Apache License, Version 2.0
