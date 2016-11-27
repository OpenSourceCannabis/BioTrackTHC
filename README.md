# BioTrackTHC

## Usage

```ruby
BioTrackTHC.configure do |config|
  config.username = 'info@sdpharmlabs.com'
  config.password = 'VVTE4Ykyh7oVDg'
  config.license = '980000225'
  config.base_uri = 'https://wslcb.mjtraceability.com'
  config.results = []
end

client = BioTrackTHC::Client.new
client.search('7265877419094151')
```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
