module SanityPostsHelper
  
  BASE_URL = "https://#{ENV['SANITY_PROJECT_ID']}.api.sanity.io/v#{ENV['SANITY_API_VERSION']}/data/query/#{ENV['SANITY_DATASET']}"

  def self.fetch(query)
    response = HTTP.get("#{BASE_URL}?query=#{query}")
    JSON.parse(response.body.to_s)
  rescue HTTP::Error => e
    Rails.logger.error("Sanity API error: #{e.message}")
    nil
  end

end
