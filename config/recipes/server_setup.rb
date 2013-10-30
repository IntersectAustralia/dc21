set :rpms, "gcc gcc-c++ patch readline readline-devel zlib zlib-devel libyaml-devel libffi-devel openssl openssl-devel make bzip2 autoconf automake libtool bison httpd httpd-devel apr-devel apr-util-devel mod_ssl mod_xsendfile curl curl-devel openssl openssl-devel tzdata libxml2 libxml2-devel libxslt libxslt-devel sqlite-devel git postgresql-server postgresql postgresql-devel libpq-dev"

# Capistrano hooks
before 'deploy:setup' do
  server_setup.deploy_config
  server_setup.rpm_install
  server_setup.aaf_install
  server_setup.rvm_install
  server_setup.gem_install
  server_setup.passenger
  postgresql.init_db
  resque.setup
end

after 'deploy:setup' do
  server_setup.filesystem.dir_perms
  server_setup.filesystem.mkdir_db_dumps
  server_setup.logging.rotation
  server_setup.config.apache
end

before 'deploy:update' do
  export_proxy
end

namespace :server_setup do

  task :deploy_config do
    require "yaml"

    config = YAML::load_file('config/deploy_config.yml')

    hostname = config['hostname']
    db_password = config['db_password']

    # Update hostnames
    system ("ruby -pi.bak -e \"gsub(/HOSTNAME/, '#{hostname}')\" config/deploy_files/shibboleth/shibboleth2.xml config/deploy/production_local.rb")
    # Update DB password
    system ("ruby -pi.bak -e \"gsub(/DB_PASSWORD/, '#{db_password}')\" config/database.yml")

    booleans = config['booleans']

    # Update AAF
    if booleans['use_test_AAF'].eql?(true)
      system ("ruby -pi.bak -e \"gsub(/AAF_HOST/, 'ds.test.aaf.edu.au')\" config/deploy_files/shibboleth/shibboleth2.xml")
    else
      system ("ruby -pi.bak -e \"gsub(/AAF_HOST/, 'ds.aaf.edu.au')\" config/deploy_files/shibboleth/shibboleth2.xml")
    end

  end

  task :aaf_install do
    run "#{try_sudo} yum install -y #{rpms}"
    #set up certificate
  end

  task :aaf_display_key do
    #show cert or secret token

  end

  after 'deploy:first_time', 'server_setup:aaf_display_key'

  task :rpm_install, :roles => :app do
    run "#{try_sudo} yum install -y #{rpms}"
  end

  task :rvm_install, :roles => :app do
    run "curl -L http://get.rvm.io | bash -s stable --ruby=1.9.2-p290"
    run "source ~/.rvm/scripts/rvm"
    run "rvm use 1.9.2-p290"
    run "rvm gemset create dc21app"
  end

  task :set_proxies do
    unless proxy.nil?
      run "echo 'export http_proxy=\"#{proxy}\"' >> ~#{user}/.bashrc", :shell => bash
      run "echo 'export HTTP_PROXY=$http_proxy' >> ~#{user}/.bashrc", :shell => bash

      run "echo 'echo \'export http_proxy=\"#{proxy}\"\' >> /etc/bashrc' | #{try_sudo} /bin/bash", :shell => bash
      run "echo 'echo \'export HTTP_PROXY=$http_proxy\' >> /etc/bashrc' | #{try_sudo} /bin/bash", :shell => bash

      run "echo 'proxy=\"#{proxy}\"' >> ~#{user}/.curlrc", :shell => bash
      run "echo '---' >> ~#{user}/.gemrc", :shell => bash
      run "echo 'http-proxy: \"#{proxy}\"' >> ~#{user}/.gemrc", :shell => bash
    end
  end

  namespace :filesystem do
    task :dir_perms, :roles => :app do
      run "[[ -d #{data_dir} ]] || #{try_sudo} mkdir -p #{data_dir}"
      run "#{try_sudo} chown -R #{user}.#{group} #{data_dir}"
      run "[[ -d #{aux_data_dir} ]] || #{try_sudo} mkdir -p #{aux_data_dir}"
      run "#{try_sudo} chown -R #{user}.#{group} #{aux_data_dir}"
      run "[[ -d #{rif_cs_dir} ]] || #{try_sudo} mkdir -p #{rif_cs_dir}"
      run "#{try_sudo} chown -R #{user}.#{group} #{rif_cs_dir}"
      run "[[ -d #{unpublished_rif_cs_dir} ]] || #{try_sudo} mkdir -p #{unpublished_rif_cs_dir}"
      run "#{try_sudo} chown -R #{user}.#{group} #{unpublished_rif_cs_dir}"
      run "[[ -d #{archived_dir} ]] || #{try_sudo} mkdir -p #{archived_dir}"
      run "#{try_sudo} chown -R #{user}.#{group} #{archived_dir}"
      run "[[ -d #{deploy_to} ]] || #{try_sudo} mkdir #{deploy_to}"
      run "#{try_sudo} chown -R #{user}.#{group} #{deploy_to}"
      run "#{try_sudo} chmod 0711 #{user_home}"
    end

    task :mkdir_db_dumps, :roles => :app do
      run "#{try_sudo} mkdir -p #{shared_path}/db_dumps"
      run "#{try_sudo} chown -R #{user}.#{group} #{shared_path}/db_dumps"
    end
  end

  task :gem_install, :roles => :app do
    run "gem install bundler -v 1.0.20"
    run "gem install passenger -v 3.0.21"
  end

  task :passenger, :roles => :app do
    run "passenger-install-apache2-module -a"
  end

  namespace :config do
    task :apache do
      run "mkdir -p apache_config"
      upload "config/httpd", "apache_config", :via => :scp, :recursive => true

      run "cd apache_config/httpd && ruby passenger_setup.rb \"#{rvm_ruby_string}\" \"#{current_path}\" \"#{web_server}\" \"#{stage}\""
      src = "apache_config/httpd/apache_insertion.conf"
      dest = "/etc/httpd/conf.d/rails_#{application}.conf"
      run "cmp -s #{src} #{dest} > /dev/null; [ $? -ne 0 ] && #{try_sudo} cp #{src} #{dest} ; /bin/true"
    end
  end

  namespace :logging do
    task :rotation, :roles => :app do
      src = "#{release_path}/config/#{application}.logrotate"
      dest = "/etc/logrotate.d/#{application}"
      run "cmp -s #{src} #{dest} > /dev/null; [ $? -ne 0 ] && #{try_sudo} cp #{src} #{dest}; /bin/true"
      src = "#{release_path}/config/httpd/httpd.logrotate"
      dest = "/etc/logrotate.d/httpd"
      run "cmp -s #{src} #{dest} > /dev/null; [ $? -ne 0 ] && #{try_sudo} cp #{src} #{dest}; /bin/true"
    end
  end
end
