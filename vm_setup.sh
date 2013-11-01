status=0
if [ -z "$DC21_TAG" ]; then
  echo "Please define DC21_TAG"
  status=1
fi

if [ -z "$DC21_DB_PWD" ]; then
  echo "Please define DC21_DB_PWD"
  status=1
fi

if [ -z "$DC21_HOST" ]; then
  echo "Please define DC21_HOST"
  status=1
fi

if [ -z "$DC21_AAF_TEST" ]; then
  echo "DC21_AAF_TEST is not defined. Using PRODUCTION AAF Registry."
fi

if [ "$status" -ne 0 ]; then
  exit $status
fi

sudo rpm -Uvh http://mirrors.kernel.org/fedora-epel/6/i386/epel-release-6-8.noarch.rpm http://rpms.famillecollet.com/enterprise/remi-release-6.rpm

sudo yum install -y gcc gcc-c++ patch readline readline-devel zlib zlib-devel libyaml-devel libffi-devel openssl openssl-devel make bzip2 autoconf automake libtool bison httpd httpd-devel apr-devel apr-util-devel mod_ssl mod_xsendfile curl curl-devel openssl openssl-devel tzdata libxml2 libxml2-devel libxslt libxslt-devel sqlite-devel git postgresql-server postgresql postgresql-devel libpq-dev
sudo setenforce 0

mkdir code_base
cd code_base
wget https://github.com/IntersectAustralia/dc21/archive/$DC21_TAG.zip -O ~/code_base/dc21.zip
unzip ~/code_base/dc21.zip
rm ~/code_base/dc21.zip
mv ~/code_base/dc21-$DC21_TAG ~/code_base/dc21
cd ~/code_base/dc21

curl -L http://get.rvm.io | bash -s stable --ruby=1.9.2-p290
source ~/.rvm/scripts/rvm
rvm use 1.9.2-p290
rvm gemset create dc21app
cd .
gem install bundler -v 1.0.20
bundle install

cap production_local deploy:deploy_config
cap production_local deploy:first_time

echo "Please use this to register for AAF"
sudo cat /etc/shibboleth/sp-cert.pem

echo "Please remember to add your SSL certificate and key to /etc/httpd/ssl/server.crt and /etc/httpd/ssl/server.key respectively"
