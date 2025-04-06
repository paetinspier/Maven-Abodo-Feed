require 'nokogiri'
require 'open-uri'

class ImportPropertiesJob < ApplicationJob
  queue_as :default

  def perform(_args)
    PropertyImporter.call(logger: Logger.new(STDOUT))
  end
end
