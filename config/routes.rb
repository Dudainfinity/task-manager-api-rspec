Rails.application.routes.draw do
  # Health check — returns 200 if the app boots with no exceptions.
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resources :projects do
        member do
          get :progress
        end
        resources :tasks do
          member do
            post :complete
          end
        end
      end
    end
  end

  root to: ->(_env) {
    [ 200, { "Content-Type" => "application/json" },
     [ { name: "task-manager-api-rspec", status: "ok" }.to_json ] ]
  }
end
