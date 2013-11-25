namespace :server_setup do

  task :deploy_config do
    code_base = "/home/#{user}/code_base/dc21"
    p code_base
    if File.directory?(code_base)
      # Update hostnames
      system ("ruby -pi.bak -e \"gsub(/HOSTNAME/, '#{ENV['DC21_HOST'] || web_server}')\" #{code_base}/config/deploy_files/shibboleth/shibboleth2.xml #{code_base}/config/deploy/local.rb #{code_base}/config/shibboleth.yml")
      # Update DB password
      system ("ruby -pi.bak -e \"gsub(/DB_PASSWORD/, '#{ENV['DC21_DB_PWD']}')\" #{code_base}/config/database.yml")
      # Update AAF
      if ENV['DC21_AAF_TEST'].eql?("true")
        system ("ruby -pi.bak -e \"gsub(/AAF_HOST/, 'ds.test.aaf.edu.au')\" #{code_base}/config/deploy_files/shibboleth/shibboleth2.xml")
      else
        system ("ruby -pi.bak -e \"gsub(/AAF_HOST/, 'ds.aaf.edu.au')\" #{code_base}/config/deploy_files/shibboleth/shibboleth2.xml")
      end
    else
      raise "Your system is not set up for local deployment.".red
    end

  end

  task :aaf_install do

    status = capture "#{try_sudo} service shibd status; echo;"
    if status[/unrecognized/]
      run "#{try_sudo} wget http://download.opensuse.org/repositories/security://shibboleth/CentOS_CentOS-6/security:shibboleth.repo -P /etc/yum.repos.d"
      run "#{try_sudo} yum install -y shibboleth"
    else
      puts "    Shibboleth installed already.".green
    end
    #upload configs
    upload "config/deploy_files/shibboleth", "/tmp/", :via => :scp, :recursive => true
    run "#{try_sudo} mv /tmp/shibboleth/* /etc/shibboleth/"

    #set up certificate

    hostname = ENV['DC21_HOST'] || web_server

    run "cd /etc/shibboleth && #{try_sudo} ./keygen.sh -f -h #{hostname} -e https://#{hostname}/shibboleth"
    run "#{try_sudo} chmod 0644 /etc/shibboleth/sp-cert.*"

    # Update AAF
    if ENV['DC21_AAF_TEST'].eql?("true")
      run "#{try_sudo} wget https://ds.test.aaf.edu.au/distribution/metadata/aaf-metadata-cert.pem -O /etc/shibboleth/aaf-metadata-cert.pem"
    else
      run "#{try_sudo} wget https://ds.aaf.edu.au/distribution/metadata/aaf-metadata-cert.pem -O /etc/shibboleth/aaf-metadata-cert.pem"
    end

    sudo "service shibd start"

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
      run "[[ -d /home/#{user}/tmp ]] || #{try_sudo} mkdir -p /home/#{user}/tmp"
      run "#{try_sudo} chown -R #{user}.#{group} /home/#{user}/tmp"

    end

    task :mkdir_db_dumps, :roles => :app do
      run "#{try_sudo} mkdir -p #{shared_path}/db_dumps"
      run "#{try_sudo} chown -R #{user}.#{group} #{shared_path}/db_dumps"
    end
  end

  task :gem_install, :roles => :app do
    run "gem install bundler -v 1.0.20"
  end

  task :passenger, :roles => :app do
    run "gem install passenger -v 3.0.21"
    run "passenger-install-apache2-module -a"
  end

  namespace :config do
    task :apache do

      #copy apache config files
      upload "config/deploy_files/apache", "/tmp/", :via => :scp, :recursive => true
      run "#{try_sudo} mv /tmp/apache/httpd.conf /etc/httpd/conf/httpd.conf"
      run "#{try_sudo} mv /tmp/apache/* /etc/httpd/conf.d/"

      upload "config/httpd", "/tmp/apache_config", :via => :scp, :recursive => true
      run "cd /tmp/apache_config/ && ruby passenger_setup.rb \"#{rvm_ruby_string}\" \"#{current_path}\" \"#{web_server}\" \"#{stage}\""
      src = "/tmp/apache_config/apache_insertion.conf"
      dest = "/etc/httpd/conf.d/rails_#{application}.conf"
      run "cmp -s #{src} #{dest} > /dev/null; [ $? -ne 0 ] && #{try_sudo} cp #{src} #{dest} ; /bin/true"

      #add SSL folders
      run "#{try_sudo} mkdir -p /etc/httpd/ssl"
      run "#{try_sudo} openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/httpd/ssl/server.key -out /etc/httpd/ssl/server.crt"

      sudo "chkconfig httpd on"

    end

    task :cron do
      run 'crontab -l | { cat; echo "0 */4 * * * find /tmp/download_zip* -atime +0 -type f -exec rm -f \'{}\' \; 2>/dev/null"; } | crontab -'
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
