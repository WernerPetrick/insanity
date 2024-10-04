module SanityPostsHelper
  
  BASE_URL = "https://#{ENV['SANITY_PROJECT_ID']}.api.sanity.io/v#{ENV['SANITY_API_VERSION']}/data/query/#{ENV['SANITY_DATASET']}"
  SANITY_API_URL = "https://#{ENV['SANITY_PROJECT_ID']}.api.sanity.io/v#{ENV['SANITY_API_VERSION']}/data/mutate/#{ENV['SANITY_DATASET']}"
  SANITY_TOKEN = ENV['SANITY_TOKEN'] 
  
  def self.fetch(query, params = {})
    if params.any?
      params.each do |key, value|
        query = query.gsub("$#{key}", value.to_s)
      end
    end
    
    encoded_query = URI.encode_www_form_component(query)
    response = HTTP.get("#{BASE_URL}?query=#{encoded_query}")
    JSON.parse(response.body.to_s)
  rescue HTTP::Error => e
    Rails.logger.error("Sanity API error: #{e.message}")
    nil
  end

  def self.create_document(document_data)
    mutation = {
      mutations: [
        {
          create: document_data
        }
      ]
    }

    response = HTTP.auth("Bearer #{SANITY_TOKEN}")
                   .post(SANITY_API_URL, json: mutation)

    if response.status.success?
      JSON.parse(response.body.to_s)
    else
      Rails.logger.error("Failed to create document: #{response.body.to_s}")
      nil
    end
  rescue HTTP::Error => e
    Rails.logger.error("Sanity API error: #{e.message}")
    nil
  end
  
  def self.patch_document(id, patch_operations)
    mutation = {
      mutations: [
        {
          patch: {
            id: id,
            set: patch_operations[:set],
            unset: patch_operations[:unset],
            inc: patch_operations[:inc],
            dec: patch_operations[:dec],
          }
        }
      ]
    }

    response = HTTP.auth("Bearer #{SANITY_TOKEN}")
                   .post(SANITY_API_URL, json: mutation)

    if response.status.success?
      JSON.parse(response.body.to_s)
    else
      Rails.logger.error("Failed to patch document: #{response.body.to_s}")
      nil
    end
  rescue HTTP::Error => e
    Rails.logger.error("Sanity API error: #{e.message}")
    nil
  end
  
end
