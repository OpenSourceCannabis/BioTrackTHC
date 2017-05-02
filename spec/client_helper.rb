module ClientHelper
  def stub_session
    allow(BioTrackTHC::Client).to receive(:sign_in).and_return(true)
  end
end

RSpec.configure do |config|
  config.include ClientHelper
end
