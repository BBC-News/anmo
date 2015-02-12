Anmo
====

[![Build status](https://secure.travis-ci.org/sthulbourn/anmo.png)](https://travis-ci.org/sthulbourn/anmo)

What?
-----
Anmo acts as a mock api and can be used to store arbitrary pieces of data for integration testing flaky APIs.
This is generally *not a good idea*, but where you can't use [VCR](https://github.com/myronmarston/vcr) anmo is now an option.

How?
----

```
require "anmo"

Thread.new { Anmo.launch_server }

Anmo.create_request({
  :path => "/lookatmyhorse",
  :body => "my horse is amazing"
})
```

```
curl http://localhost:8787/lookatmyhorse
my horse is amazing
```

Docker
----

To run using docker containers, start memcached and then start anmo.

```sh

docker run --name memcache -d memcached

docker run --link memcache:memcache -d -p 9999:9999 bbcnews/anmo

```
