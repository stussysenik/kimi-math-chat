class Message < ApplicationRecord
  belongs_to :conversation
  has_many :verifications, dependent: :destroy

  enum :role, { system: 0, user: 1, assistant: 2 }

  validates :role, presence: true

  after_create_commit -> { broadcast_append_to conversation, target: "messages" }
  after_update_commit -> { broadcast_replace_to conversation }

  def verification_status
    return nil unless contains_math?
    return :pending if verifications.empty?

    statuses = verifications.pluck(:status)
    if statuses.all? { |s| s == "passed" }
      :passed
    elsif statuses.any? { |s| s == "failed" }
      :failed
    elsif statuses.any? { |s| s == "running" }
      :running
    else
      :pending
    end
  end
end
