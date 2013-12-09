require 'resque'

set :resque_worker_count, 4

namespace :resque do

  desc "Install and set up Resque"
  task :setup do
    status = capture "#{try_sudo} service redis status; echo;"
    if status[/unrecognized/]
      sudo "yum -y install redis"
      sudo "service redis start"
      sudo "chkconfig redis on"
    else
      puts "    Redis installed already.".green
    end
  end

  desc "Start resque processes"
  task :start, on_error: :continue do
    run "cd #{current_path} && bundle exec rake daemons:start --trace", :env => {'RAILS_ENV' => stage}
  end

  desc "Quit running workers"
  task :stop, on_error: :continue do
    run "cd #{current_path} && bundle exec rake daemons:stop --trace", :env => {'RAILS_ENV' => stage}
  end

  desc "Restart running workers"
  task :restart, on_error: :continue do
    stop
    start
  end

  %w[stop start restart].each do |command|
    after "deploy:#{command}", "resque:#{command}"
  end
end
