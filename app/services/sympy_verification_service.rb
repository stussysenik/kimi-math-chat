class SympyVerificationService
  PYTHON_SCRIPT = Rails.root.join("lib/python/sympy_verify.py").to_s
  PYTHON_BIN = Rails.root.join("lib/python/.venv/bin/python3").to_s
  TIMEOUT = 30 # seconds

  Result = Data.define(:verified, :simplified, :latex, :steps, :error)

  def initialize(expression:)
    @expression = expression
  end

  def call
    stdout, stderr, status = nil

    Timeout.timeout(TIMEOUT) do
      stdout, stderr, status = Open3.capture3(python_path, PYTHON_SCRIPT, @expression)
    end

    unless status.success?
      return Result.new(
        verified: false,
        simplified: nil,
        latex: nil,
        steps: [],
        error: stderr.presence || "SymPy process exited with code #{status.exitstatus}"
      )
    end

    data = JSON.parse(stdout)
    Result.new(
      verified: data["verified"],
      simplified: data["simplified"],
      latex: data["latex"],
      steps: data["steps"] || [],
      error: data["error"]
    )
  rescue JSON::ParserError => e
    Result.new(verified: false, simplified: nil, latex: nil, steps: [], error: "JSON parse error: #{e.message}")
  rescue Timeout::Error
    Result.new(verified: false, simplified: nil, latex: nil, steps: [], error: "SymPy verification timed out")
  end

  private

  def python_path
    File.executable?(PYTHON_BIN) ? PYTHON_BIN : "python3"
  end
end
