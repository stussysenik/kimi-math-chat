begin
  require "wolfram_ext/wolfram_ext"
rescue LoadError => e
  warn "WolframExt native extension not loaded: #{e.message}"
  warn "Falling back to pure Ruby HTTP client for Wolfram Alpha queries."
end
