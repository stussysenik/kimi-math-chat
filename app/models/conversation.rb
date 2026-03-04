class Conversation < ApplicationRecord
  AVAILABLE_MODELS = {
    "moonshotai/kimi-k2-instruct" => "Kimi K2 Instruct",
    "moonshotai/kimi-k2.5" => "Kimi K2.5",
    "moonshotai/kimi-k2-thinking" => "Kimi K2 Thinking"
  }.freeze

  has_many :messages, dependent: :destroy

  before_create :set_defaults

  def display_title
    title.presence || "New Conversation"
  end

  def model_display_name
    AVAILABLE_MODELS[model_id] || model_id
  end

  private

  def set_defaults
    self.model_id ||= "moonshotai/kimi-k2-instruct"
    self.session_id ||= SecureRandom.hex(16)
  end
end
