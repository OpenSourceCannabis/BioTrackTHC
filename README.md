# BioTrackTHC

## Usage

```ruby
BioTrackTHC.configure do |config|
  config.username = ''
  config.password = ''
  config.license = ''
  config.base_uri = 'https://wslcb.mjtraceability.com'
end

client = BioTrackTHC::Client.new(debug: true)

client.sample_search('0199 2612 0934 4923')
client.parsed_response

client.license_search('980221')
```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
