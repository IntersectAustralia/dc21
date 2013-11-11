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

sudo yum install -y gcc gcc-c++ patch readline readline-devel zlib zlib-devel libyaml-devel unzip libffi-devel openssl openssl-devel make bzip2 autoconf automake libtool bison httpd httpd-devel apr-devel apr-util-devel mod_ssl mod_xsendfile curl curl-devel openssl openssl-devel tzdata libxml2 libxml2-devel libxslt libxslt-devel sqlite-devel git postgresql-server postgresql postgresql-devel libpq-dev
sudo setenforce 0

rm -rf $HOME/code_base
mkdir $HOME/code_base
cd $HOME/code_base
wget https://github.com/IntersectAustralia/dc21/archive/$DC21_TAG.zip -O $HOME/code_base/dc21.zip
unzip $HOME/code_base/dc21.zip
rm $HOME/code_base/dc21.zip
mv $HOME/code_base/dc21-$DC21_TAG $HOME/code_base/dc21
cd $HOME/code_base/dc21

curl -L http://get.rvm.io | bash -s stable --ruby=1.9.2-p290
source $HOME/.rvm/scripts/rvm
echo '[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"' >> $HOME/.bashrc
source $HOME/.bash_profile
source $HOME/.bashrc
cd $HOME/code_base/dc21
rvm use 1.9.2-p290
rvm gemset create dc21app
gem install bundler -v 1.0.20
bundle install

cap production_local server_setup:deploy_config
cap production_local deploy:first_time

echo "Please copy the following certificate to register for AAF"
sudo cat /etc/shibboleth/sp-cert.pem

echo "Please remember to add your SSL certificate and key to /etc/httpd/ssl/server.crt and /etc/httpd/ssl/server.key respectively"
echo "After adding your SSL certificate, run 'sudo service httpd restart'."
