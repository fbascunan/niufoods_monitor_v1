require 'sidekiq'
require 'sidekiq-unique-jobs'

Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/1') }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/1') }
end

# Configure unique jobs globally
SidekiqUniqueJobs.configure do |config|
  config.enabled = true
  config.lock_ttl = 30.minutes
  config.lock_timeout = 10.seconds
end 