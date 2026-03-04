class ConversationsController < ApplicationController
  def index
    @conversations = Conversation.order(updated_at: :desc)
    @conversation = @conversations.first
  end

  def show
    @conversations = Conversation.order(updated_at: :desc)
    @conversation = Conversation.find(params[:id])
    render :index
  end

  def create
    @conversation = Conversation.create!(title: "New Chat")
    redirect_to @conversation
  end

  def destroy
    @conversation = Conversation.find(params[:id])
    @conversation.destroy
    redirect_to root_path
  end

  def update_model
    @conversation = Conversation.find(params[:id])
    @conversation.update!(model_id: params[:model_id])
    head :ok
  end
end
