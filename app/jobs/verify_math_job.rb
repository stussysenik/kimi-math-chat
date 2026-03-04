class VerifyMathJob < ApplicationJob
  queue_as :default

  def perform(message_id)
    message = Message.find(message_id)
    message.update!(contains_math: true)

    MathVerificationOrchestrator.new(message).run
  rescue => e
    Rails.logger.error("VerifyMathJob failed: #{e.message}")
  end
end
