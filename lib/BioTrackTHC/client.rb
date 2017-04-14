module BioTrackTHC
  include Constants
  include Errors

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
        parse_search_response
      else
        false
      end
    end

    private

    def parse_search_response
      self.parsed_response = []
      _html = Nokogiri::HTML(response)
      sample_count = _html.css(ResponsePage::BUTTON_RECEIVE).count
      0.upto(sample_count-1) do |idx|
        _sample_data = {}
        interpolated_receive_btn =
          ResponsePage::BUTTON_RECEIVE_IDX.gsub(/IDX/, "#{idx}")
        if _button = _html.css(interpolated_receive_btn)
          _sample_data[:action] = _button.first.attributes['value'].value
          _sample_data[:onclick] = _button.first.attributes['onclick'].value
        end
        nth_of_type = ":nth-of-type(#{idx + ResponsePage::DATA_OFFSET})"
        ResponsePage::UI_ELEMENTS.each do |ui_element|
          element =
            _html
              .css(
                ResponsePage::UI_ELEMENT_IDX.gsub(/IDX/, ui_element) +
                nth_of_type
              )
              .css(ResponsePage::DATA_ELEMENT)
          next unless element
          if is_lot_batch?(element)
            [
              ResponsePage::SAMPLE_ID_OFFSET,
              ResponsePage::LOT_ID_OFFSET
            ].each do |offset|
              key, value = element.children[offset].text.split(': ')
              _sample_data[key.downcase.gsub(/\s+/, '_').to_sym] = value.strip
            end
          else
            _sample_data[ResponsePage::SAMPLE_ATTR[z].to_sym] = element[0].text
          end
        end
        parsed_response << _sample_data
      end
      sample_count
    end

    def sign_in
      raise Errors::MissingConfiguration if configuration.incomplete?
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

    def is_lot_batch?(el)
      el.children.count == ResponsePage::LOT_BATCH_COLUMN_COUNT
    end

    def configuration
      BioTrackTHC.configuration
    end
  end
end
