Gem::Specification.new do |s|
  s.name        = "wolfram_ext"
  s.version     = "0.1.0"
  s.summary     = "Rust-powered Wolfram Alpha client for Ruby"
  s.authors     = ["Kimi Math Chat"]
  s.files       = Dir["lib/**/*.rb", "ext/**/*.{rb,rs}", "Cargo.toml", "src/**/*.rs"]
  s.extensions  = ["ext/wolfram_ext/extconf.rb"]

  s.required_ruby_version = ">= 3.1"
  s.add_dependency "rb_sys", "~> 0.9"
end
