require 'mechanize'
require 'BioTrackTHC/configuration'
require 'BioTrackTHC/client'
require "BioTrackTHC/version"

module BioTrackTHC
  LOGIN_PAGE = '/qlogin.asp'.freeze
  LABTEST_SEARCH = '/qasearchreturn_lot.asp?l='.freeze
  LABTEST_RECEIVE = '/labtestreceive.asp?id='.freeze
  LABTEST_RESULTS = '/labtestresult.asp?id='.freeze
  # https://wslcb.mjtraceability.com/
  # page7_pesticide_screening
  # page8_heavy_metal
  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure(&block)
    yield configuration
  end
end
