class Api::V1::AiController < ApplicationController
  include ActionController::Live

  def show
    data = ''
    response.headers['Content-Type'] = 'text/event-stream'
    response.headers["Last-Modified"] = Time.now.httpdate # Add this line if your Rack version is 2.2.x

    conversation.messages.create(body: params[:title], role: 'user', user_id: 22)
    sse = SSE.new(response.stream, retry: 300, event: "open")
    ai_service = AiService.new(params[:title]) # Initialize AiService with the title

    ai_service.get_response do |chunk|
      # if chunk.dig('choices', 0, 'finish_reason') == 'stop'
      #   write_token_event('[DONE]')
      #   break
      # end
      if token = chunk.dig("choices", 0, "delta", "content")
        data = data + token
        write_token_event(token)
      end
    end
    conversation.messages.create(body: data, role: 'system', user_id: 22)
    sse.close
  end

  private

  def write_token_event(data)
    response.stream.write data
  end

  def conversation
    Conversation.find(10)
  end
end