sudo yum install -y gcc gcc-c++ patch readline readline-devel zlib zlib-devel libyaml-devel libffi-devel openssl openssl-devel make bzip2 autoconf automake libtool bison httpd httpd-devel apr-devel apr-util-devel mod_ssl mod_xsendfile curl curl-devel openssl openssl-devel tzdata libxml2 libxml2-devel libxslt libxslt-devel sqlite-devel git postgresql-server postgresql postgresql-devel libpq-dev

mkdir code_base && cd code_base
wget https://github.com/IntersectAustralia/dc21/archive/new_deploy.zip -O master.zip
unzip master.zip && mv dc21-new_deploy dc21-master && cd dc21-master

curl -L http://get.rvm.io | bash -s stable --ruby=1.9.2-p290
source ~/.rvm/scripts/rvm
rvm use 1.9.2-p290
rvm gemset create dc21app
cd .
gem install bundler -v 1.0.20
bundle install

cap production_local deploy:first_time
