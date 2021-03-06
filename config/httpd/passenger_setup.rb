gem_set = ARGV.shift
current_path = ARGV.shift
hostname = ARGV.shift
environment = ARGV.shift

gem_home = ENV['GEM_HOME']

version = "4.0.45"

apache_string = <<EOF
LoadModule passenger_module #{gem_home}/gems/passenger-#{version}/buildout/apache2/mod_passenger.so
   <IfModule mod_passenger.c>
     PassengerRoot #{gem_home}/gems/passenger-#{version}
     PassengerDefaultRuby #{gem_home}/wrappers/ruby
   </IfModule>

<VirtualHost *:80>
    ServerName #{hostname}
     Redirect permanent / https://#{hostname}/
</VirtualHost>

<VirtualHost *:443>
    ServerName #{hostname}
    RailsEnv #{environment}
    DocumentRoot #{current_path}/public

    XSendFile on
    XSendFilePath /tmp
    XSendFilePath /data/dc21-data

    <Directory #{current_path}/public>
         AllowOverride all
         Options -MultiViews
    </Directory>

    SSLEngine on

    ErrorLog logs/ssl_error_log
    CustomLog logs/ssl_access_log combined
    CustomLog logs/ssl_request_log \
          "%t %h %{SSL_PROTOCOL}x %{SSL_CIPHER}x 636f4ebbf2a79889b02804364ae277836ade24bfquot;%r636f4ebbf2a79889b02804364ae277836ade24bfquot; %b"
    LogLevel warn

    SetEnvIf User-Agent ".*MSIE.*" \
         nokeepalive ssl-unclean-shutdown \
         downgrade-1.0 force-response-1.0

    SSLProtocol all -SSLv2
    SSLHonorCipherOrder On
    SSLCipherSuite ALL:!aNull:!ADH:!eNULL:!LOW:!SSLv2:!EXPORT:!EXP:RC4+RSA:+HIGH:+MEDIUM
    SSLCertificateFile /etc/httpd/ssl/server.crt
    SSLCertificateKeyFile /etc/httpd/ssl/server.key

</VirtualHost>

EOF

out = File.new("apache_insertion.conf", "w")
out.write(apache_string)
out.close
