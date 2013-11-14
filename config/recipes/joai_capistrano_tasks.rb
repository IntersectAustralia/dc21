require 'tempfile'

namespace :joai do
  set :catalina_home, "/usr/tomcat6"
  set :webapp_dir, "#{catalina_home}/webapps"
  set :tomcat_conf, "#{catalina_home}/conf"

  set :remote_directory, "/home/dc21/joai"
  set :tomcat_bundle, "tomcat-joai.tar.gz"
  set :tomcat_package, 'apache-tomcat-6.0.35'

  set :tomcat_service, "tomcat"
  set :apache_config, "tomcat_joai.conf"

  set :tomcat_user_file, 'joai/tomcat_users.xml'

  desc 'Copy joai bundle to remote server'
  task :copy do
    run "mkdir -p #{remote_directory}"
    upload("joai/#{tomcat_bundle}", "#{remote_directory}", :via => :scp)
    upload("joai/#{tomcat_service}", "#{remote_directory}", :via => :scp)
    upload("joai/#{apache_config}", "#{remote_directory}", :via => :scp)
  end

  desc "Unpack tomcat and install in usr directory"
  task :tomcat_install do
    sudo "yum -y install java-1.6.0-openjdk java-1.6.0-openjdk-devel"
    run "cd #{remote_directory} && tar xvfz #{tomcat_bundle}"
    run "#{try_sudo} mv #{remote_directory}/#{tomcat_package} #{catalina_home}"
    run "#{try_sudo} mv #{remote_directory}/#{tomcat_service} /etc/init.d"
    run "#{try_sudo} mv #{remote_directory}/#{apache_config} /etc/httpd/conf.d/"
    run "#{try_sudo} chmod 755 /etc/init.d/#{tomcat_service}"
    run "#{try_sudo} chkconfig --add tomcat"
    run "#{try_sudo} chkconfig --level 234 tomcat on"
  end

  desc "configure joai and tomcat password"
  task "joai_user" do
    password = nil
    until password
      first_password = Capistrano::CLI.password_prompt("New jOAI password (at least six alphanumeric characters): ".yellow)
      second_password = Capistrano::CLI.password_prompt("Confirm password: ".yellow)

      if first_password.eql? second_password
        if first_password =~ /^[a-zA-Z0-9]{6,}$/
          password = first_password
        else
          puts "    Wrong password"
        end
      else
        puts "    Passwords don't match".red
      end
    end

    tmp_oai_user_file = Tempfile.new('foo')
    `cat #{tomcat_user_file} | sed 's/---/#{password}/' > #{tmp_oai_user_file.path}`
    upload(tmp_oai_user_file.path, "#{tomcat_conf}/tomcat-users.xml", :via => :scp)

    tmp_oai_user_file.close
    tmp_oai_user_file.unlink
  end

  desc "Fully deploy joai"
  task :setup do
    status = capture "#{try_sudo} service tomcat status; echo;"
    if status[/unrecognized/]
      copy
      tomcat_install
      joai_user
    else
      puts "    Tomcat installed already.".green
    end
    sudo "service tomcat start"
  end
end
