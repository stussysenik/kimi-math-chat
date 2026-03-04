Langfuse.configure do |config|
  config.public_key = Rails.application.credentials.dig(:langfuse, :public_key) || ENV["LANGFUSE_PUBLIC_KEY"]
  config.secret_key = Rails.application.credentials.dig(:langfuse, :secret_key) || ENV["LANGFUSE_SECRET_KEY"]
  config.host = ENV.fetch("LANGFUSE_HOST", "https://cloud.langfuse.com")
end if defined?(Langfuse) && (
  Rails.application.credentials.dig(:langfuse, :public_key).present? ||
  ENV["LANGFUSE_PUBLIC_KEY"].present?
)
