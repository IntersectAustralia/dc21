#!/usr/bin/env ruby

env = ENV["RAILS_ENV"] ||= "development"

root = File.expand_path(File.dirname(__FILE__))
root = File.dirname(root) until File.exists?(File.join(root, 'config'))
Dir.chdir(root)

require File.join(root, "config", "environment")

$running = true
Signal.trap("TERM") do
  $running = false
end

while($running) do
  exec("bundle exec rake resque:scheduler RAILS_ENV=#{env}")
  Rails.logger.auto_flushing = true
  Rails.logger.info "Resque scheduler running.\n"
end
