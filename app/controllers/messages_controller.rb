class MessagesController < ApplicationController
  def create
    @conversation = Conversation.find(params[:conversation_id])
    @message = @conversation.messages.create!(
      role: :user,
      content: params[:content]
    )

    GenerateResponseJob.perform_later(@conversation.id)

    head :ok
  end
end
