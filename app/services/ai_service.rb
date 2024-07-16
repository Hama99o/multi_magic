class AiService
  def initialize(query, ai_type = 'chatgpt')
    @query = query
    @ai_type = ai_type
  end

  def get_response(&block)
    case @ai_type
    when 'chatgpt'
      # Use the content writer to write a draft post
      ChatgptService.new .write_draft_post(@query, &block)
    else
      raise "Unsupported AI type: #{@ai_type}"
    end
  end
end
