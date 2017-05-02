require 'mechanize'
require 'pry'
require 'BioTrackTHC/constants'
require 'BioTrackTHC/errors'
require 'BioTrackTHC/configuration'
require 'BioTrackTHC/client'
require "BioTrackTHC/version"

module BioTrackTHC
  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure(&block)
    yield configuration
  end
end
