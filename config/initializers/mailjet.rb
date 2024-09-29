# initializers/mailjet.rb
Mailjet.configure do |config|
  config.api_key = ENV['MAILJET_API_KEY']
  config.secret_key = ENV['MAILJET_SECRET_KEY']
  config.api_version = "v3.1"
  config.default_from = ENV['MAILJET_DEFAULT_MAIL']
end
