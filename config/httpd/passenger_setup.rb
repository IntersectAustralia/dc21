gem_set = ARGV.shift
current_path = ARGV.shift
hostname = ARGV.shift
environment = ARGV.shift

gem_home = ENV['GEM_HOME']
rvm_home = ENV['rvm_path']

dep = Gem::Dependency.new('passenger', Gem::Requirement.default)
specs = Gem.source_index.search dep

version  = specs.first.version.version
wrapper_path = rvm_home + "/wrappers/" + gem_set




apache_string = <<EOF
LoadModule passenger_module #{gem_home}/gems/passenger-#{version}/ext/apache2/mod_passenger.so
PassengerRoot #{gem_home}/gems/passenger-#{version}
PassengerRuby #{wrapper_path}/ruby
PassengerTempDir #{current_path}/tmp/pids

<VirtualHost #{environment.eql?('production') ? hostname : '*'}:80>
    ServerName #{hostname}
    RailsEnv #{environment}
    DocumentRoot #{current_path}/public

    XSendFile on
    XSendFilePath /tmp
    <Directory #{current_path}/public>
         AllowOverride all
         Options -MultiViews
    </Directory>

</VirtualHost>

EOF

out = File.new("apache_insertion.conf", "w")
out.write(apache_string)
out.close