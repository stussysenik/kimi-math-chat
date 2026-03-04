class LlmService
  NVIDIA_BASE_URI = "https://integrate.api.nvidia.com/v1"

  def initialize(model_id: "moonshotai/kimi-k2-instruct")
    @model_id = model_id
    @client = OpenAI::Client.new(
      access_token: Rails.application.credentials.dig(:nvidia, :api_key) || ENV["NVIDIA_API_KEY"],
      uri_base: NVIDIA_BASE_URI
    )
  end

  def chat(messages:)
    response = @client.chat(
      parameters: {
        model: @model_id,
        messages: messages,
        temperature: 0.7,
        max_tokens: 4096
      }
    )
    response.dig("choices", 0, "message", "content")
  end

  def chat_stream(messages:, &block)
    @client.chat(
      parameters: {
        model: @model_id,
        messages: messages,
        temperature: 0.7,
        max_tokens: 4096,
        stream: proc { |chunk, _bytesize|
          content = chunk.dig("choices", 0, "delta", "content")
          block.call(content) if content.present?
        }
      }
    )
  end
end
