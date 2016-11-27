module BioTrackTHC
  class Client
    attr_accessor :agent, :debug, :sample_data
    def initialize(opts = {})
      self.agent = Mechanize.new { |agent| agent.follow_meta_refresh = true }
      self.debug = opts[:debug]
      sign_in
    end

    def search(sample_id)
      agent.get("#{configuration.base_uri}#{BioTrackTHC::LABTEST_SEARCH}#{sample_id}") do |xml|
        if data = xml.search('data')
          self.sample_data  = Base64.decode64(data.children.to_s)
          puts sample_data if debug
        else
          puts 'not found' if debug
        end
      end
    end

    private

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
