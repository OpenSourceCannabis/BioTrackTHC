module BioTrackTHC
  include Constants
  include Errors

  class Client
    attr_accessor :agent,
                  :debug,
                  :response,
                  :parsed_response,
                  :licensees,
                  :sample_id,
                  :sample_amount_used
    def initialize(opts = {})
      self.agent = Mechanize.new { |agent| agent.follow_meta_refresh = true }
      self.agent.user_agent_alias = 'Windows IE 9'
      self.debug = opts[:debug]
      sign_in
    end

    def search_sample(sample_id)
      self.sample_id = sample_id
      agent.get("#{configuration.base_uri}#{Constants::API::SAMPLE_SEARCH}#{sample_id}") do |xml|
        self.response = nil
        self.parsed_response = []
        if data = xml.search('data')
          self.response  = Base64.decode64(data.children.to_s)
          puts response if debug
        else
          puts "BioTrackTHC: sample_id #{sample_id} not found" if debug
        end
      end
      if response =~ /myaddreceive|myaddresults/
        parse_search_response
      else
        false
      end
    end

    def search_license(license_id)
      agent.get("#{configuration.base_uri}#{Constants::API::LICENSE_SEARCH}#{license_id}") do |xml|
        self.response = nil
        if data = xml.search('data')
          self.response  = Base64.decode64(data.children.to_s)
          puts response if debug
        else
          puts "BioTrackTHC: license_id #{sample_id} not found" if debug
        end
      end
      if response =~ /myaddreceive|myaddresults/
        parse_search_response
      else
        false
      end
    end

    def search_licensee(query)
      agent.get("#{configuration.base_uri}#{Constants::API::LICENSEE_SEARCH}#{query}") do |response|
        self.licensees = JSON.parse(response.body)['items']
        licensees.any?
      end
    end

    def receive_sample(sample_id, pct=1)
      pct = 1 if pct > 1
      search_sample(sample_id) unless sample_available?(sample_id)
      _sample =
        parsed_response
          .find{|el| el[:sample_id].gsub(/\D/,'') == sample_id.gsub(/\D/,'') && el[:action] == 'Receive Sample' }
      if _sample
        agent.get("#{configuration.base_uri}#{Constants::API::RECEIVE_PAGE}#{_sample[:id]}") do |page|
          _response = page.form_with(name: 'addlicensee', method: 'POST') do |form|
            form.id = _sample[:id]
            form.submit = 1
            form.receive_quantity = _sample[:quantity].to_f * pct
          end.submit
          puts _response.body if debug
        end
      else
        puts "#{sample_id} not found" if debug
      end
    end

    def create_results(sample_id, results = {})
      receive_sample(sample_id) unless sample_available?(sample_id)
      _sample =
        parsed_response
          .find{|el| el[:sample_id].gsub(/\D/,'') == sample_id.gsub(/\D/,'') && el[:action] == 'Add Results'}
      if _sample
        agent.get("#{configuration.base_uri}#{Constants::API::CREATE_RESULTS}#{_sample[:id]}") do |page|
          _response = page.form_with(name: 'addlicensee', method: 'POST') do |form|
            setup_results(form, results)
          end.submit
          true
          puts _response.body if debug
        end
      else
        puts "#{sample_id} not found" if debug
      end
    end

    def update_results(sample_id, results = {})
      agent.get("#{configuration.base_uri}#{Constants::API::UPDATE_RESULTS}#{sample_id}") do |page|
        _response = page.form_with(name: 'addlicensee', method: 'POST') do |form|
          setup_results(form, results)
        end
        puts _response if debug
        _response.submit
      end
    end

    def form_fields(sample_id)
      search_sample(sample_id) unless sample_available?(sample_id)
      _sample =
        parsed_response
          .find{|el| el[:sample_id].gsub(/\D/,'') == sample_id.gsub(/\D/,'') && el[:action] == 'Add Results'}
      if _sample
        page = agent.get("#{configuration.base_uri}#{Constants::API::CREATE_RESULTS}#{_sample[:id]}")
        self.sample_amount_used = page.forms[0].fields.find{|z| z.name == 'sample_amount_used'}.value
        page.forms[0].fields.find_all{|z| z.type == 'text' || z.type.nil? }.map(&:name)
      else
        []
      end
    end

    def can_receive_sample?(sample_id = nil)
      sample_id = self.sample_id
      parsed_response &&
      parsed_response
        .any?{|el| el[:sample_id].gsub(/\D/,'') == sample_id.gsub(/\D/,'') && el[:action] == 'Receive Sample'}
    end

    def can_create_results?(sample_id = nil)
      sample_id = self.sample_id
      parsed_response &&
      parsed_response
        .any?{|el| el[:sample_id].gsub(/\D/,'') == sample_id.gsub(/\D/,'') && el[:action] == 'Add Results'}
    end

    def can_update_results?
      false
    end

    private

    def setup_results(form, results)
      fields = form.fields.map(&:name)
      form.page1_moisture = results[:page1_moisture] if fields.index('page1_moisture')
      form.page2_THC = results[:page2_THC] if fields.index('page2_THC')
      form.page2_THCA = results[:page2_THCA] if fields.index('page2_THCA')
      form.total_thc = results[:page2_THC].to_f + (0.877 * results[:page2_THCA].to_f) if fields.index('total_thc')
      form.page2_CBD = results[:page2_CBD] if fields.index('page2_CBD')
      form.page2_CBDA = results[:page2_CBDA] if fields.index('page2_CBDA')
      form.total_cbd = results[:page2_CBD].to_f + (0.877 * results[:page2_CBDA].to_f) if fields.index('total_cbd')
      form.send(:'page2_Total Cannabinoids', form.total_thc.to_f + form.total_cbd.to_f) if fields.index('page2_Total Cannabinoids')
      form.page3_Stems = results[:page3_Stems] if fields.index('page3_Stems')
      form.page3_Other = results[:page3_Other] if fields.index('page3_Other')
      form.page4_aerobic_bacteria = results[:page4_aerobic_bacteria] if fields.index('page4_aerobic_bacteria')
      form.page4_yeast_and_mold = results[:page4_yeast_and_mold] if fields.index('page4_yeast_and_mold')
      form.page4_coliforms = results[:page4_coliforms] if fields.index('page4_coliforms')
      form.page4_bile_tolerant = results[:page4_bile_tolerant] if fields.index('page4_bile_tolerant')
      form.page4_e_coli_and_salmonella = results[:page4_e_coli_and_salmonella] if fields.index('page4_e_coli_and_salmonella')
      form.page6_total_mycotoxins = results[:page6_total_mycotoxins] if fields.index('page6_total_mycotoxins')
      form.page7_pesticide_screening = results[:page7_pesticide_screening] if fields.index('page7_pesticide_screening')
      form.page8_heavy_metal = results[:page8_heavy_metal] if fields.index('page8_heavy_metal')
      form.sample_amount_destroyed = results[:sample_amount_destroyed] if fields.index('sample_amount_destroyed')
      form.sample_amount_other =  results[:sample_amount_other] if fields.index('sample_amount_other')
    end

    def sample_available?(sample_id)
      parsed_response &&
      parsed_response
        .any?{|el| el[:sample_id].gsub(/\D/,'') == sample_id.gsub(/\D/,'')}
    end

    def parse_search_response
      self.parsed_response = []
      _html = Nokogiri::HTML(response)
      sample_count =
        _html.css(Constants::ResponsePage::BUTTON_RECEIVE).count +
        _html.css(Constants::ResponsePage::BUTTON_RESULTS).count
      0.upto(sample_count-1) do |idx|
        _sample_data = {}
        interpolated_receive_btn =
          Constants::ResponsePage::BUTTON_ACTION_IDX.gsub(/IDX/, "#{idx}")
        if _button = _html.css(interpolated_receive_btn)
          _sample_data[:action] = _button.first.attributes['value'].value
          _sample_data[:onclick] = _button.first.attributes['onclick'].value
          _sample_data[:id] = _sample_data[:onclick].gsub(/\D/, '')
        end
        nth_of_type = ":nth-of-type(#{idx + Constants::ResponsePage::DATA_OFFSET})"
        Constants::ResponsePage::UI_ELEMENTS.each do |ui_element|
          element =
            _html
              .css(
                Constants::ResponsePage::UI_ELEMENT_IDX.gsub(/IDX/, ui_element) +
                nth_of_type
              )
              .css(Constants::ResponsePage::DATA_ELEMENT)
          next unless element
          if is_lot_batch?(element)
            [
              Constants::ResponsePage::SAMPLE_ID_OFFSET,
              Constants::ResponsePage::LOT_ID_OFFSET
            ].each do |offset|
              key, value = element.children[offset].text.split(': ')
              _sample_data[key.downcase.gsub(/\s+/, '_').to_sym] = value.strip
            end
          else
            _sample_data[Constants::ResponsePage::SAMPLE_ATTR[ui_element].to_sym] = element[0].text
          end
        end
        parsed_response << _sample_data
      end
      sample_count
    end

    def sign_in
      raise Errors::MissingConfiguration if configuration.incomplete?
      agent.get(configuration.base_uri + Constants::API::LOGIN_PAGE) do |wslcb_page|
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
      el.children.count == Constants::ResponsePage::LOT_BATCH_COLUMN_COUNT
    end

    def configuration
      BioTrackTHC.configuration
    end
  end
end
