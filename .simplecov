# SimpleCov configuration — auto-loaded when `require "simplecov"` runs.
SimpleCov.start "rails" do
  enable_coverage :branch

  add_filter %w[/spec/ /config/ /db/ /bin/ /vendor/ /test/]
  add_filter "app/channels"
  add_filter "app/jobs/application_job.rb"
  add_filter "app/mailers/application_mailer.rb"

  add_group "Models",      "app/models"
  add_group "Controllers", "app/controllers"
  add_group "Services",    "app/services"
  add_group "Serializers", "app/serializers"

  # Enforce coverage thresholds in CI (set COVERAGE=true to enforce locally too).
  if ENV["CI"] || ENV["COVERAGE"]
    minimum_coverage line: 95, branch: 80
  end
end
