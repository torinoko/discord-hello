Rails.application.routes.draw do
  get "/auth/discord/callback", to: "sessions#discord_callback"
  root to: "sessions#new"
end
