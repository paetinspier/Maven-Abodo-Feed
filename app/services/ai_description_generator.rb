require 'httparty'

class AiDescriptionGenerator
  include HTTParty
  base_uri 'https://api.openai.com/v1/'

  def initialize(name, city, state, bedrooms)
    @name = name
    @city = city 
    @state = state 
    @bedrooms = bedrooms
  end

  # Generates a description and returns the generated description.
  # Returns the generated text on success, or nil on failure.
  def call
    Rails.logger.debug "[AI] Bearer token is: #{ENV['OPENAI_API_KEY'].inspect}"
    Rails.logger.debug "[AI] Authorization header will be: Bearer #{ENV['OPENAI_API_KEY']}"
    response = self.class.post(
      '/chat/completions',
      headers: {
        'Content-Type'  => 'application/json',
        'Authorization' => "Bearer #{ENV['OPENAI_API_KEY']}"
      },
      body: {
        model:    'gpt-4',
        messages: [
          { role: 'system', content: 'You are a helpful assistant that writes real-estate descriptions.' },
          { role: 'user',   content: "Write a polished marketing description for a property with the following info. city: #{@city}, state: #{@state}, name: #{@name}, number of bedrooms: #{@bedrooms}. This description should be a maximum of 200 words." }
        ]
      }.to_json
    )

    if response.success?
      text = response.parsed_response.dig('choices', 0, 'message', 'content')&.strip
      if text
        #@property.update(description: text)
        return text
      else
        Rails.logger.error "[AI] no content in response: #{response.body}"
      end
      text
    else
      Rails.logger.error "[AI] OpenAI API error (#{response.code}): #{response.body}"
      nil
    end
  rescue JSON::ParserError => e
    Rails.logger.error "[AI] JSON parse error: #{e.message}"
    nil
  end
end
