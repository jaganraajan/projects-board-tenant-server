class AiPriorityClassifier
  API_URL = 'https://api.openai.com/v1/chat/completions'

  def self.classify_priority(title:, description: nil)
    new.classify_priority(title: title, description: description)
  end

  def initialize
    @api_key = ENV['OPENAI_API_KEY']
  end

  def classify_priority(title:, description: nil)
    return fallback_priority if @api_key.blank?

    begin
      response = make_api_request(title, description)
      extract_priority_from_response(response)
    rescue StandardError => e
      Rails.logger.error "AI Priority Classification failed: #{e.message}"
      fallback_priority
    end
  end

  private

  def make_api_request(title, description)
    prompt = build_prompt(title, description)
    
    connection = Faraday.new(url: API_URL) do |conn|
      conn.request :json
      conn.response :json, content_type: /\bjson$/
      conn.adapter Faraday.default_adapter
    end

    response = connection.post do |req|
      req.headers['Authorization'] = "Bearer #{@api_key}"
      req.headers['Content-Type'] = 'application/json'
      req.body = {
        model: 'gpt-3.5-turbo',
        messages: [
          {
            role: 'system',
            content: system_prompt
          },
          {
            role: 'user',
            content: prompt
          }
        ],
        max_tokens: 50,
        temperature: 0.3
      }
    end

    response
  end

  def system_prompt
    <<~PROMPT
      You are an expert in productivity and the Eisenhower Matrix (7 Habits of Highly Effective People).
      
      Classify tasks into one of these four priorities based on urgency and importance:
      - Priority 1: Urgent & Important (Q1)
      - Priority 2: Not Urgent & Important (Q2) 
      - Priority 3: Urgent & Not Important (Q3)
      - Priority 4: Not Urgent & Not Important (Q4)
      
      Respond with ONLY the priority (e.g., "Priority 1") - no explanation needed.
    PROMPT
  end

  def build_prompt(title, description)
    task_info = "Task Title: #{title}"
    task_info += "\nTask Description: #{description}" if description.present?
    task_info += "\n\nClassify this task according to the Eisenhower Matrix:"
    task_info
  end

  def extract_priority_from_response(response)
    return fallback_priority unless response.success?

    content = response.body.dig('choices', 0, 'message', 'content')
    return fallback_priority if content.blank?

    # Extract priority from response content
    priority_match = content.match(/Priority [1-4]/)
    priority_match ? priority_match[0] : fallback_priority
  end

  def fallback_priority
    # Default to Priority 2 (Important but Not Urgent) as a reasonable default
    'Priority 2'
  end
end