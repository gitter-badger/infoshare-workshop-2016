# Sample app for Google OAuth2 Strategy
# Make sure to setup the ENV variables GOOGLE_KEY and GOOGLE_SECRET
# Run with "bundle exec rackup"

require 'rubygems'
require 'bundler'
require 'sinatra'
require 'omniauth'
require 'omniauth-google-oauth2'
require 'dotenv'
require 'mail'
Dotenv.load

require 'google/apis/gmail_v1'

class App < Sinatra::Base
  get '/' do
    <<-HTML
    <ul>
      <li><a href='/auth/google_oauth2'>Sign in with Google</a></li>
    </ul>
    HTML
  end

  get '/auth/:provider/callback' do
    content_type 'text/plain'
    session[:email] = request.env['omniauth.auth']['info']['email']
    session[:token] = request.env['omniauth.auth']['credentials']['token']

    redirect to('/dashboard')
  end

  get '/auth/failure' do
    content_type 'text/plain'
    request.env['omniauth.auth'].to_hash.inspect
  end

  get '/dashboard' do
    api = gmail_api

    api.list_user_messages('me', q: 'from:orbitz') do |result, err|
      raise err if err

      @messages = []
      result.messages.each do |message|
        fetched_message = api.get_user_message('me', message.id, format: 'raw')
        parsed_message = Mail.new(fetched_message.raw)
        @messages << parsed_message
      end

      @total_messages = result.result_size_estimate
    end

    erb :dashboard
  end

  get '/search' do
    api = gmail_api

    api.list_user_messages('me', q: params['q']) do |result, err|
      raise err if err

      @messages = []
      if result.messages
        result.messages.each do |message|
          fetched_message = api.get_user_message('me', message.id, format: 'raw')
          parsed_message = Mail.new(fetched_message.raw)
          @messages << parsed_message
        end
      end

      @total_messages = result.result_size_estimate
    end

    erb :search
  end

  private

  def gmail_api
    Google::Apis::GmailV1::GmailService.new.tap do |service|
      service.authorization = authorization
    end
  end

  def authorization
    Signet::OAuth2::Client.new(
      authorization_uri: 'https://accounts.google.com/o/oauth2/auth',
      token_credential_uri:  'https://www.googleapis.com/oauth2/v3/token',
      client_id: ENV['GOOGLE_KEY'],
      client_secret: ENV['GOOGLE_SECRET'],
      scope: 'https://www.googleapis.com/auth/gmail.readonly',
      redirect_uri: 'https://example.client.com/oauth',

      access_token: session[:token],
      username: session['email']
    )
  end
end

use Rack::Session::Cookie, secret: ENV['RACK_COOKIE_SECRET']

use OmniAuth::Builder do
  # For additional provider examples please look at 'omni_auth.rb'
  provider :google_oauth2, ENV['GOOGLE_KEY'], ENV['GOOGLE_SECRET'], {
    scope: 'email, profile, https://www.googleapis.com/auth/gmail.readonly',
    prompt: 'select_account',
    image_aspect_ratio: 'square',
    image_size: 50
  }
end

run App.new
