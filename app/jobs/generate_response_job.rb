class GenerateResponseJob < ApplicationJob
  queue_as :default

  BROADCAST_INTERVAL = 0.1 # seconds between Turbo broadcasts during streaming

  def perform(conversation_id)
    conversation = Conversation.find(conversation_id)
    llm = LlmService.new(model_id: conversation.model_id)

    messages = build_messages(conversation)

    assistant_message = conversation.messages.create!(
      role: :assistant,
      content: "",
      streaming: true
    )

    full_content = +""
    last_broadcast = Time.now

    LangfuseTracingService.trace_generation(
      conversation: conversation,
      message: assistant_message,
      model_id: conversation.model_id
    ) do
      llm.chat_stream(messages: messages) do |chunk|
        full_content << chunk

        if Time.now - last_broadcast >= BROADCAST_INTERVAL
          assistant_message.update_columns(content: full_content)
          assistant_message.broadcast_replace_to(conversation)
          last_broadcast = Time.now
        end
      end
    end

    assistant_message.update!(content: full_content, streaming: false)

    VerifyMathJob.perform_later(assistant_message.id) if MathDetectorService.contains_math?(full_content)
  rescue => e
    Rails.logger.error("GenerateResponseJob failed: #{e.message}")
    if defined?(assistant_message) && assistant_message&.persisted?
      assistant_message.update!(
        content: full_content.presence || "Sorry, I encountered an error generating a response.",
        streaming: false
      )
    end
  end

  private

  def build_messages(conversation)
    msgs = []
    if conversation.system_prompt.present?
      msgs << { role: "system", content: conversation.system_prompt }
    else
      msgs << { role: "system", content: "You are a helpful math assistant. When showing math, use LaTeX notation with $...$ for inline and $$...$$ for display math. Show your work step by step." }
    end

    conversation.messages.order(:created_at).each do |msg|
      next if msg.system?
      msgs << { role: msg.role, content: msg.content }
    end
    msgs
  end
end
