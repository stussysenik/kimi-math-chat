class MathVerificationOrchestrator
  def initialize(message)
    @message = message
  end

  def run
    expressions = MathDetectorService.extract_expressions(@message.content)
    return if expressions.empty?

    expressions.each do |expression|
      verify_with_sympy(expression)
      verify_with_wolfram(expression)
    end
  end

  private

  def verify_with_sympy(expression)
    verification = @message.verifications.create!(
      verifier: "sympy",
      status: :running,
      input_expression: expression
    )

    start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)

    result = SympyVerificationService.new(expression: expression).call

    elapsed_ms = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time) * 1000).round(1)

    verification.update!(
      status: result.verified ? :passed : :failed,
      result: result.to_h.to_json,
      error_message: result.error,
      execution_time_ms: elapsed_ms
    )
  rescue => e
    verification&.update!(status: :error, error_message: e.message)
  end

  def verify_with_wolfram(expression)
    verification = @message.verifications.create!(
      verifier: "wolfram",
      status: :running,
      input_expression: expression
    )

    start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)

    result = WolframVerificationService.new(expression: expression).call

    elapsed_ms = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time) * 1000).round(1)

    verification.update!(
      status: result.verified ? :passed : :failed,
      result: result.to_h.to_json,
      error_message: result.error,
      execution_time_ms: elapsed_ms
    )
  rescue => e
    verification&.update!(status: :error, error_message: e.message)
  end
end
