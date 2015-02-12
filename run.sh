#! /usr/bin/env ruby

require "anmo"

ENV['MEMCACHE_SERVERS'] = "#{ENV['MEMCACHE_PORT_11211_TCP_ADDR']}:11211"

Anmo.server = "0.0.0.0"
Anmo.launch_server 9999
