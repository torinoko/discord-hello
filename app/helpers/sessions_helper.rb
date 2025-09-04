module SessionsHelper
  def discord_oauth_url
    client_id     = ENV["DISCORD_CLIENT_ID"]
    redirect_uri  = ENV["DISCORD_REDIRECT_URI"]
    scope         = "identify"
    response_type = "code"

    "https://discord.com/api/oauth2/authorize?client_id=#{client_id}&redirect_uri=#{redirect_uri}&response_type=#{response_type}&scope=#{scope}"
  end
end