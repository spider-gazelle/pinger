# pinger

[![CI](https://github.com/spider-gazelle/pinger/actions/workflows/ci.yml/badge.svg)](https://github.com/spider-gazelle/pinger/actions/workflows/ci.yml)

Microlib to generate ICMP ping requests.  
Avoids sudo requirement of using raw sockets by shelling out to `ping` and thus pinger has an implicit dependency of `ping`.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     pinger:
       github: spider-gazelle/pinger
   ```

2. Run `shards install`

## Usage

```crystal
require "pinger"

hostname = "www.duckduckgo.com"
pinger = Pinger.new(hostname, count: 3)

pinger.ping # => true / false
puts {
    host: pinger.ip,
    pingable: pinger.pingable,
    warning: pinger.warning,
    exception: pinger.exception
}
```

Or if you would like an error raised

```crystal

require "pinger"

hostname = "www.doesnotexist.com"
pinger = Pinger.new(hostname, count: 3)

pinger.ping! # => self / raise pinger.exception

```


## Todo

- [ ] utilise `Crystal::Config.default_target` rather than shelling out to uname

## Contributing

1. [Fork it](https://github.com/spider-gazelle/pinger/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Caspian Baska](https://github.com/caspiano)
- [Stephen von Takach](https://github.com/stakach)
