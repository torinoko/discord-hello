  # app/controllers/sessions_controller.rb
  class SessionsController < ApplicationController
    require "net/http"
    require "uri"
    require "json"

    def new
    end

    def discord_callback
      code = params[:code]
      return if code.blank?

      token_response = exchange_code_for_token(code)
      access_token   = token_response["access_token"]
      user_info = fetch_user_info(access_token)

      notify_admin(user_info)
    end

    private

    def exchange_code_for_token(code)
      uri = URI("https://discord.com/api/oauth2/token")
      res = Net::HTTP.post_form(uri, {
        "client_id" => ENV["DISCORD_CLIENT_ID"],
        "client_secret" => ENV["DISCORD_CLIENT_SECRET"],
        "grant_type" => "authorization_code",
        "code" => code,
        "redirect_uri" => ENV["DISCORD_REDIRECT_URI"]
      })
      JSON.parse(res.body)
    end

    def fetch_user_info(access_token)
      uri = URI("https://discord.com/api/users/@me")
      req = Net::HTTP::Get.new(uri)
      req["Authorization"] = "Bearer #{access_token}"

      res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(req)
      end

      JSON.parse(res.body)
    end

    def notify_admin(user_info)
      admin_id  = ENV["ADMIN_DISCORD_ID"]
      bot_token = ENV["DISCORD_BOT_TOKEN"]

      uri = URI("https://discord.com/api/v10/users/@me/channels")
      req = Net::HTTP::Post.new(uri, {
        "Content-Type" => "application/json",
        "Authorization" => "Bot #{bot_token}"
      })
      req.body = { recipient_id: admin_id }.to_json

      res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(req)
      end
      channel = JSON.parse(res.body)

      dm_uri = URI("https://discord.com/api/v10/channels/#{channel["id"]}/messages")
      dm_req = Net::HTTP::Post.new(dm_uri, {
        "Content-Type" => "application/json",
        "Authorization" => "Bot #{bot_token}"
      })
      dm_req.body = {
        content: "おしゃべりリクエストがありました！ "\
          "#{user_info["username"]}##{user_info["discriminator"]} "\
          "(ID: #{user_info["id"]})"
      }.to_json

      res = Net::HTTP.start(dm_uri.hostname, dm_uri.port, use_ssl: true) do |http|
        http.request(dm_req)
      end
    end
  end
