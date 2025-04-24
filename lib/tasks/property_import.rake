namespace :property do
  desc 'Fetch and parse XML data, then import matching properties'
  task import: :environment do
    PropertyImporter.call(logger: Logger.new(STDOUT))
  end

  desc 'Generate missing descriptions for all properties'
  task generate_descriptions: :environment do
    logger = Logger.new(STDOUT)

    Property.where(description: [nil, '']).find_each do |property|
      logger.info "Generating description for Property ##{property.id} (#{property.name})"
      text = AiDescriptionGenerator.new(property.name, "Madison", "WI", property.unit_bedrooms).call

      if text.present?
        property.update!(description: text)
        logger.info "✅ Saved description for ##{property.id}"
      else
        logger.error "❌ Failed to generate for ##{property.id}"
      end
    end

    logger.info "Done generating descriptions."
  end
end
