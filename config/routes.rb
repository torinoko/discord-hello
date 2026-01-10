Rails.application.routes.draw do
  get "/auth/discord/callback", to: "sessions#discord_callback"
  root to: "sessions#new"
  get "/health", to: proc { [200, {}, ["ok"]] }
end
