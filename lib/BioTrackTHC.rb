require 'mechanize'
require 'pry'
require 'BioTrackTHC/constants'
require 'BioTrackTHC/errors'
require 'BioTrackTHC/configuration'
require 'BioTrackTHC/client'
require "BioTrackTHC/version"

module BioTrackTHC
  LOGIN_PAGE      = '/qlogin.asp'.freeze
  LICENSEE_SEARCH = '/qasearch.asp?style=full&maxRows=10&name_startsWith='.freeze
  LICENSE_SEARCH  = '/qasearchreturn.asp?l='.freeze
  SAMPLE_SEARCH   = '/qasearchreturn_lot.asp?l='.freeze
  SAMPLE_RECEIVE  = '/labtestreceive.asp?id='.freeze
  CREATE_RESULTS  = '/labtestresult.asp?id='.freeze
  UPDATE_RESULTS  = '/labtestresult_modify.asp?id='.freeze
  RECEIVE_PAGE    = '/labtestreceive.asp?id='.freeze

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
