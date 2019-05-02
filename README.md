# pinger

Microlib to generate ICMP ping requests.  
Avoids sudo requirement of using raw sockets by shelling out to `ping` and thus pinger has an implicit dependency of `ping`.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     pinger:
       github: aca-labs/pinger
   ```

2. Run `shards install`

## Usage

```crystal
require "pinger"

hostname = "www.duckduckgo.com"
ping = Pinger::Ping.new(hostname, count: 3)

ping.ping
puts {
    host: ping.ip,
    pingable: ping.pingable,
    warning: ping.warning,
    exception: ping.exception
}
```

## Todo

- [] utilise `Crystal::Config.default_target` rather than shelling out to uname

## Contributing

1. [Fork it](https://github.com/aca-labs/pinger/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Caspian Baska](https://github.com/caspiano) - creator and maintainer
