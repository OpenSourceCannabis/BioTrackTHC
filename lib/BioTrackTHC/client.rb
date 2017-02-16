module BioTrackTHC
  class Client
    attr_accessor :agent, :debug, :response, :parsed_response
    def initialize(opts = {})
      self.agent = Mechanize.new { |agent| agent.follow_meta_refresh = true }
      self.agent.user_agent_alias = 'Windows IE 9'
      self.debug = opts[:debug]
      sign_in
    end

    def sample_search(sample_id)
      agent.get("#{configuration.base_uri}#{BioTrackTHC::SAMPLE_SEARCH}#{sample_id}") do |xml|
        if data = xml.search('data')
          self.response  = Base64.decode64(data.children.to_s)
          puts response if debug
        else
          puts "BioTrackTHC: sample_id #{sample_id} not found" if debug
        end
      end
      if response =~ /myaddreceive/
        parse_search_response
      else
        false
      end
    end

    def license_search(license_id)
      agent.get("#{configuration.base_uri}#{BioTrackTHC::LICENSE_SEARCH}#{license_id}") do |xml|
        if data = xml.search('data')
          self.response  = Base64.decode64(data.children.to_s)
          puts response if debug
        else
          puts "BioTrackTHC: license_id #{sample_id} not found" if debug
        end
      end
      if response =~ /myaddreceive/
        # parse_search_response
        true
      else
        false
      end
    end

    private

    def parse_search_response
      self.parsed_response = {}
      _html = Nokogiri::HTML(response)
      if _button = _html.css('input#button-0')
        parsed_response[:action] = _button.first.attributes['value'].value
        parsed_response[:onclick] = _button.first.attributes['onclick'].value
      end
      # .ui-block-a..e are the div on chunk of decoded HTML
      %w(b c d e).each do |z|
        element = _html.css(".ui-block-#{z}").css('.ui-bar-e')
        # this is the LOT / BATCH
        if element.children.count == 4
          [1,3].each do |i|
            key, value = element.children[i].text.split(': ')
            parsed_response[key.downcase.gsub(/\s+/, '_').to_sym] = value.strip
          end
        else
          key = element[0].text
          value = element[1].text
          parsed_response[key.downcase.to_sym] = value
        end
      end
      true
    end

    def sign_in
      agent.get(configuration.base_uri + BioTrackTHC::LOGIN_PAGE) do |wslcb_page|
        _response = wslcb_page.form_with(name: 'clogin', method: 'POST') do |form|
          form.username  = configuration.username
          form.password = configuration.password
          form.license = configuration.license
          form.radiobutton_with(id: 'mode2').check
        end.submit
        puts _response if debug
      end
    end

    def configuration
      BioTrackTHC.configuration
    end
  end
end
