
if Rails.env.development?
  ENV['PUBLISHABLE_KEY'] = "pk_wLJXPbCWbzbWqjFCbvANNQ7cY2HaE"
  ENV['SECRET_KEY'] = "sk_UwOPeoexW4SG2vXxG75VPff9jnW5D"
end

Rails.configuration.stripe = {
  :publishable_key => ENV['PUBLISHABLE_KEY'],
  :secret_key      => ENV['SECRET_KEY']
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]