require 'test_helper'
require 'tempfile'

class PropertyImporterTest < ActiveSupport::TestCase
  def setup
    Property.delete_all

    @xml_content = <<-XML
      <Properties>
        <Property>
          <PropertyID>
            <Identification IDValue="123"/>
            <MarketingName>Test Property</MarketingName>
            <Email>test@example.com</Email>
            <Address>
              <City>Madison</City>
              <State>WI</State>
            </Address>
          </PropertyID>
          <ILS_Unit>
            <Units>
              <Unit>
                <UnitBedrooms>2</UnitBedrooms>
              </Unit>
              <Unit>
                <UnitBedrooms>1</UnitBedrooms>
              </Unit>
            </Units>
          </ILS_Unit>
        </Property>
        <Property>
          <PropertyID>
            <Identification IDValue="456"/>
            <MarketingName>Other Property</MarketingName>
            <Email>other@example.com</Email>
            <Address>
              <City>NotMadison</City>
              <State>WI</State>
            </Address>
          </PropertyID>
          <ILS_Unit>
            <Units>
              <Unit>
                <UnitBedrooms>3</UnitBedrooms>
              </Unit>
            </Units>
          </ILS_Unit>
        </Property>
      </Properties>
    XML

    @temp_file = Tempfile.new('sample_abodo_feed_test.xml')
    @temp_file.write(@xml_content)
    @temp_file.rewind

    @log_output = StringIO.new
    @logger = Logger.new(@log_output)
  end

  def teardown
    @temp_file.close
    @temp_file.unlink
  end

  test 'only imports properties in Madison' do
    PropertyImporter.call(@temp_file.path, logger: @logger)

    assert_equal 1, Property.count, 'Should import one property located in Madison, WI'

    property = Property.find_by(property_id: '123')
    assert property.present?, "Property with ID '123' should be present"

    assert_equal 3, property.unit_bedrooms, 'Total bedrooms should equal 3'
  end

  test 'skips properties missing required fields' do
    xml_missing_field = <<-XML
      <Properties>
        <Property>
          <PropertyID>
            <Identification IDValue="789"/>
            <MarketingName>Missing Email</MarketingName>
            <Address>
              <City>Madison</City>
              <State>WI</State>
            </Address>
          </PropertyID>
          <ILS_Unit>
            <Units>
              <Unit>
                <UnitBedrooms>2</UnitBedrooms>
              </Unit>
            </Units>
          </ILS_Unit>
        </Property>
      </Properties>
    XML

    temp_file_missing = Tempfile.new('sample_missing.xml')
    temp_file_missing.write(xml_missing_field)
    temp_file_missing.rewind

    PropertyImporter.call(temp_file_missing.path, logger: @logger)

    assert_equal 0, Property.count, 'Property missing required fields should not be imported'

    temp_file_missing.close
    temp_file_missing.unlink
  end
end
