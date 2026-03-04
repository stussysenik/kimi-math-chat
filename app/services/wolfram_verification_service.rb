class WolframVerificationService
  Result = Data.define(:verified, :result_text, :pods, :error)

  def initialize(expression:)
    @expression = expression
    @app_id = Rails.application.credentials.dig(:wolfram, :app_id) || ENV["WOLFRAM_APP_ID"]
  end

  def call
    unless @app_id.present?
      return Result.new(verified: false, result_text: nil, pods: nil, error: "Wolfram Alpha API key not configured")
    end

    # Try Rust extension first, fall back to HTTP
    if defined?(WolframExt)
      call_rust_ext
    else
      call_http
    end
  end

  private

  def call_rust_ext
    json_str = WolframExt.query(@app_id, @expression)
    data = JSON.parse(json_str)

    if data["error"]
      Result.new(verified: false, result_text: nil, pods: nil, error: data["error"])
    else
      result_text = extract_result(data["pods"])
      Result.new(
        verified: result_text.present?,
        result_text: result_text,
        pods: data["pods"],
        error: nil
      )
    end
  rescue => e
    Result.new(verified: false, result_text: nil, pods: nil, error: "Rust ext error: #{e.message}")
  end

  def call_http
    require "net/http"
    require "uri"

    uri = URI("https://api.wolframalpha.com/v2/query")
    uri.query = URI.encode_www_form(
      input: @expression,
      appid: @app_id,
      output: "json",
      format: "plaintext"
    )

    response = Net::HTTP.get_response(uri)
    unless response.is_a?(Net::HTTPSuccess)
      return Result.new(verified: false, result_text: nil, pods: nil, error: "HTTP #{response.code}")
    end

    data = JSON.parse(response.body)
    query_result = data.dig("queryresult")

    if query_result&.dig("success")
      pods = query_result["pods"]
      result_text = extract_result_from_pods(pods)
      Result.new(verified: result_text.present?, result_text: result_text, pods: pods, error: nil)
    else
      Result.new(verified: false, result_text: nil, pods: nil, error: "Wolfram Alpha could not interpret the query")
    end
  rescue => e
    Result.new(verified: false, result_text: nil, pods: nil, error: "HTTP error: #{e.message}")
  end

  def extract_result(pods)
    return nil unless pods.is_a?(Array)
    result_pod = pods.find { |p| p["id"] == "Result" || p["title"]&.include?("Result") }
    result_pod ||= pods.find { |p| p["id"] == "Solution" }
    result_pod&.dig("subpods", 0, "plaintext")
  end

  def extract_result_from_pods(pods)
    return nil unless pods.is_a?(Array)
    result_pod = pods.find { |p| p["id"] == "Result" || p["title"]&.include?("Result") }
    result_pod ||= pods.find { |p| p["id"] == "Solution" }
    result_pod&.dig("subpods", 0, "plaintext")
  end
end
