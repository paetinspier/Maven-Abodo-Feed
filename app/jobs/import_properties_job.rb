require 'nokogiri'
require 'open-uri'

class ImportPropertiesJob < ApplicationJob
  queue_as :default

  def perform(_args)
    xml_url = Rails.root.join('db/data/sample_abodo_feed.xml')

    begin
      puts 'Fetching XML ...'
      xml_data = URI.open(xml_url).read
      doc = Nokogiri::XML(xml_data)

      doc.xpath('//Property').each do |property|
        property_id = property.at_xpath('./PropertyID/Identification/@IDValue')&.value
        name        = property.at_xpath('./PropertyID/MarketingName')&.text
        email       = property.at_xpath('./PropertyID/Email')&.text
        city        = property.at_xpath('./PropertyID/Address/City')&.text
        state       = property.at_xpath('./PropertyID/Address/State')&.text

        next unless city == 'Madison' && state == 'WI'

        total_bedrooms = property.xpath('./ILS_Unit/Units/Unit/UnitBedrooms')
                                 .map { |node| node.text.to_f }
                                 .sum
        prop = Property.find_or_initialize_by(property_id: property_id)
        prop.update!(
          name: name,
          email: email,
          unit_bedrooms: total_bedrooms
        )
        puts "Imported property: #{name} (#{property_id})"
      end

      puts 'Import completed successfully.'
    rescue StandardError => e
      puts "Error during import: #{e.message}"
    end
  end
end
