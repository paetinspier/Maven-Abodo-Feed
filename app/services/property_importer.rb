require 'nokogiri'
require 'open-uri'

class PropertyImporter
  def self.call(file_path = Rails.root.join('db/data/sample_abodo_feed.xml'), logger: Rails.logger)
    new(file_path, logger).import
  end

  def initialize(file_path, logger)
    @file_path = file_path
    @logger = logger
  end

  def import
    logger.info('Fetching XML ...')
    xml_data = URI.open(@file_path).read
    doc = Nokogiri::XML(xml_data)

    imported = 0
    skipped = 0
    failed = 0

    doc.xpath('//Property').each do |property|
      property_id = property.at_xpath('./PropertyID/Identification/@IDValue')&.value
      unless property_id
        logger.warn('Skipping property: missing ID')
        skipped += 1
        next
      end
      name = property.at_xpath('./PropertyID/MarketingName')&.text
      unless name
        logger.warn('Skipping property: missing name')
        skipped += 1
        next
      end
      email = property.at_xpath('./PropertyID/Email')&.text
      unless email
        logger.warn('Skipping property: missing email')
        skipped += 1
        next
      end
      city = property.at_xpath('./PropertyID/Address/City')&.text
      unless city
        logger.warn('Skipping property: missing city')
        skipped += 1
        next
      end
      state       = property.at_xpath('./PropertyID/Address/State')&.text

      unless city == 'Madison' && state == 'WI'
        logger.info("Skipping property #{property_id}: not in Madison, WI")
        skipped += 1
        next
      end

      total_bedrooms = property.xpath('./ILS_Unit/Units/Unit/UnitBedrooms')
                               .map { |node| node.text.to_f }
                               .sum

      begin
        prop = Property.find_or_initialize_by(property_id: property_id)
        prop.update!(
          name: name,
          email: email,
          unit_bedrooms: total_bedrooms
        )
        logger.info("Imported property: #{name} (#{property_id})")
        imported += 1
      rescue ActiveRecord::RecordInvalid => e
        logger.error("Failed to save property #{property_id}: #{e.message}")
        failed += 1
      end
    end

    logger.info("Import summary: #{imported} imported, #{skipped} skipped, #{failed} failed.")
  rescue StandardError => e
    logger.error("Import failed: #{e.message}\n#{e.backtrace.join("\n")}")
  end

  private

  def logger
    @logger
  end
end
