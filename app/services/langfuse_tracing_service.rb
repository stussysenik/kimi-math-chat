class LangfuseTracingService
  def self.enabled?
    defined?(Langfuse) && Langfuse.respond_to?(:trace)
  end

  def self.trace_generation(conversation:, message:, model_id:, &block)
    return yield unless enabled?

    trace = Langfuse.trace(
      name: "chat_generation",
      metadata: {
        conversation_id: conversation.id,
        model_id: model_id
      },
      session_id: conversation.session_id
    )

    generation = trace.generation(
      name: "llm_response",
      model: model_id,
      input: conversation.messages.order(:created_at).map { |m| { role: m.role, content: m.content } }
    )

    result = yield

    generation.end(
      output: message.content,
      usage: { total_tokens: message.content&.length.to_i / 4 } # rough estimate
    )

    result
  rescue => e
    Rails.logger.warn("Langfuse tracing error: #{e.message}")
    yield
  end

  def self.trace_verification(message:, verifier:, &block)
    return yield unless enabled?

    trace = Langfuse.trace(
      name: "math_verification",
      metadata: {
        message_id: message.id,
        verifier: verifier
      },
      session_id: message.conversation.session_id
    )

    span = trace.span(name: "verify_#{verifier}")
    result = yield
    span.end

    result
  rescue => e
    Rails.logger.warn("Langfuse tracing error: #{e.message}")
    yield
  end
end
