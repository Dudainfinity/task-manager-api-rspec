source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.1.3"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"

# Serialização JSON
gem "jsonapi-serializer", "~> 2.2"

# Paginação
gem "kaminari", "~> 1.2"

# Compartilhamento de recursos entre origens (CORS)
gem "rack-cors"

# SDK oficial da Anthropic — sugestão de subtarefas com a Claude
gem "anthropic", "~> 1.49"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false

  # --- Testing / TDD toolchain ---
  gem "rspec-rails", "~> 7.1"          # framework de testes RSpec
  gem "factory_bot_rails", "~> 6.4"    # fábricas de dados de teste
  gem "faker", "~> 3.4"                # dados falsos
  gem "shoulda-matchers", "~> 6.4"     # matchers expressivos de modelo
end

group :test do
  gem "simplecov", "~> 0.22", require: false  # cobertura de código
end
