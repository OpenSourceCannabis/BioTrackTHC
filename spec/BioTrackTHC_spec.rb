require 'spec_helper'

describe BioTrackTHC do
  before(:each) { stub_session }

  it 'has a version number' do
    expect(BioTrackTHC::VERSION).not_to be nil
  end

  it 'accepts a configuration' do
    BioTrackTHC.configure do |config|
      config.username = 'info@example.com'
      config.password = '987987987'
    end
    expect(BioTrackTHC.configuration.username).to eq('info@example.com')
    expect(BioTrackTHC.configuration.password).to eq('987987987')
    expect(BioTrackTHC.configuration.incomplete?).to be_truthy
  end

  it 'does not initialize without credentials' do
    expect { BioTrackTHC::Client.new() }
      .to(raise_error(BioTrackTHC::Errors::MissingConfiguration))
  end

  it 'initializes with credentials' do
    BioTrackTHC.configure do |config|
      config.username = 'info@example.com'
      config.password = '987987987'
      config.license = '980000225'
      config.base_uri = 'https://wslcb.mjtraceability.com'
    end
    expect { BioTrackTHC::Client.new() }
      .not_to raise_error
  end

end
