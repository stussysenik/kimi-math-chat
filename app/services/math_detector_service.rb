class MathDetectorService
  MATH_PATTERNS = [
    /\$\$.+?\$\$/m,             # display math $$...$$
    /(?<!\$)\$(?!\$).+?(?<!\$)\$(?!\$)/, # inline math $...$
    /\\\(.+?\\\)/,              # inline \(...\)
    /\\\[.+?\\\]/m,             # display \[...\]
    /\\frac\{/,                 # \frac{}{}
    /\\int/,                    # \int
    /\\sum/,                    # \sum
    /\\lim/,                    # \lim
    /\\sqrt/,                   # \sqrt
    /\\(?:alpha|beta|gamma|delta|theta|pi|sigma|omega)/i,
    /\d+\s*[\+\-\*\/\^]\s*\d+\s*=/, # simple equations like 2 + 3 = 5
  ].freeze

  MAX_EXPRESSIONS = 5

  def self.contains_math?(text)
    MATH_PATTERNS.any? { |pattern| text.match?(pattern) }
  end

  def self.extract_expressions(text)
    expressions = []

    # Extract display math blocks
    text.scan(/\$\$(.+?)\$\$/m) { |match| expressions << match[0].strip }

    # Extract inline math
    text.scan(/(?<!\$)\$(?!\$)(.+?)(?<!\$)\$(?!\$)/) { |match| expressions << match[0].strip }

    # Extract \[...\] blocks
    text.scan(/\\\[(.+?)\\\]/m) { |match| expressions << match[0].strip }

    # Extract \(...\) blocks
    text.scan(/\\\((.+?)\\\)/) { |match| expressions << match[0].strip }

    expressions.uniq.first(MAX_EXPRESSIONS)
  end
end
