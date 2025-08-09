require 'net/http'
require 'json'

class AiPriorityClassifier
    # GEMINI_API_URL = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-001'

    def self.classify_priority(title:, description: nil)
      new.classify_priority(title: title, description: description)
    end
  
    def initialize
      @api_key = ENV['GEMINI_API_KEY']
    end
  
    def classify_priority(title:, description: nil)
      begin
        response = make_api_request(title, description)
        Rails.logger.debug "Response: #{response}"
        extract_priority_from_response(response)
      rescue StandardError => e
        Rails.logger.error "AI Priority Classification failed: #{e.message}"
        fallback_priority
      end
    end
  
    private
  
    def make_api_request(title, description)
      prompt = build_prompt(title, description)
      uri = URI("https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=#{ENV['GEMINI_API_KEY']}")
      headers = { 'Content-Type' => 'application/json' }
      body = {
        contents: [
          { parts: [{ text: prompt }] }
        ]
      }.to_json
  
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Post.new(uri.request_uri, headers)
      request.body = body
  
      response = http.request(request)
      JSON.parse(response.body)
    end
  
    def build_prompt(title, description)
      "Given the following task:\nTitle: #{title}\nDescription: #{description}\nClassify its priority as one of: Priority 1, Priority 2, Priority 3, Priority 4. Respond with only the priority label."
    end
  
    def extract_priority_from_response(response)
      text = response.dig('candidates', 0, 'content', 'parts', 0, 'text')
      priority = text.to_s.strip.match(/Priority [1-4]/).to_s
      priority.presence || fallback_priority
    end
  
    def fallback_priority
      # Default to Priority 2 (Important but Not Urgent) as a reasonable default
      'Priority 2'
    end
  end