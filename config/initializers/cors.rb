# Be sure to restart your server when you modify this file.
#
# Compartilhamento de recursos entre origens (CORS). Restrinja `origins` em produção
# via a env var CORS_ORIGINS. Leia mais: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV.fetch("CORS_ORIGINS", "*").split(",")

    resource "*",
             headers: :any,
             methods: %i[get post put patch delete options head]
  end
end
