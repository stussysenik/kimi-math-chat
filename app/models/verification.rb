class Verification < ApplicationRecord
  belongs_to :message

  enum :status, { pending: 0, running: 1, passed: 2, failed: 3, error: 4 }

  after_update_commit :broadcast_update

  private

  def broadcast_update
    broadcast_replace_to message.conversation,
      target: "verification_#{id}",
      partial: "verifications/verification",
      locals: { verification: self }
  end
end
