require File.expand_path('../boot', __FILE__)

%w(
  action_controller
  action_view
  sprockets
).each do |framework|
  begin
    require "#{framework}/railtie"
  rescue LoadError
  end
end


# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module PsoriasisSolved
  class Application < Rails::Application
    config.time_zone = 'Edinburgh'

    # Do not swallow errors in after_commit/after_rollback callbacks.
    # config.active_record.raise_in_transactional_callbacks = true
  end
end