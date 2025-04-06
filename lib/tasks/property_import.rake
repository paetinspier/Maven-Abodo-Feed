namespace :property do
  desc 'Fetch and parse XML data, then import matching properties'
  task import: :environment do
    PropertyImporter.call(logger: Logger.new(STDOUT))
  end
end
