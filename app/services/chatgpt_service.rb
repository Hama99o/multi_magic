class ChatgptService
  MODEL = 'gpt-3.5-turbo'

  def initialize
    @client = OpenAI::Client.new
  end

  def write_draft_post(title, &block)
    # Estimate token count for the title
    title_token_count = estimate_token_count(title)

    # Define the total token limit (correcting it to 4096) and reserve for the response
    total_token_limit = 2096
    response_token_reserve = 500

    # Calculate the remaining token count available for previous messages
    available_token_for_messages = total_token_limit - title_token_count - response_token_reserve

    # Fetch messages within the token limit (adjusted for GPT-3.5's limit)
    messages = fetch_messages_with_token_limit(conversation, token_limit: available_token_for_messages)

    # Add the new user message (the title)
    messages.push({ role: "user", content: title })

    # Debugging output to verify message count
    p "Total messages sent: #{messages.count}"

    # Call the OpenAI API with the conversation history + new message
    @client.chat(
      parameters: {
        model: MODEL,
        temperature: 0.7,
        messages: messages,  # Ensure the messages array is passed here
        stream: block        # Use the block for streaming responses
      }
    )
  end

  def conversation
    # Replace '10' with dynamic conversation selection based on user or context
    Conversation.find(10)
  end

  # Function to estimate token count for a given text
  def estimate_token_count(text)
    # Rough estimate: 1 token ~ 4 characters on average (adjust as needed)
    (text.length / 4.0).ceil
  end

  # Retrieve messages, limiting based on token count
  def fetch_messages_with_token_limit(conversation, token_limit:)
    messages = []
    cumulative_token_count = 0

    # Fetch messages in reverse chronological order (latest first)
    conversation.messages.order(created_at: :desc).each do |message|
      # Estimate the token count for the current message
      message_token_count = estimate_token_count(message.body)

      # Check if adding this message would exceed the token limit
      break if cumulative_token_count + message_token_count > token_limit

      # Add the message to the array and update the cumulative token count
      messages.unshift({
        role: message.role,
        content: message.body
      })
      cumulative_token_count += message_token_count
    end

    messages
  end
end
