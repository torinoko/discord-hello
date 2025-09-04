Rails.application.routes.draw do
  get "/auth/discord/callback", to: "sessions#discord_callback"
  get "/login", to: "sessions#new"
end
