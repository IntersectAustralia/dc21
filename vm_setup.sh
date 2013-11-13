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

#Installs standard RPMs
sudo rpm -Uvh http://mirrors.kernel.org/fedora-epel/6/i386/epel-release-6-8.noarch.rpm http://rpms.famillecollet.com/enterprise/remi-release-6.rpm

sudo yum install -y gcc gcc-c++ patch readline readline-devel zlib zlib-devel libyaml-devel unzip libffi-devel openssl openssl-devel make bzip2 autoconf automake libtool bison httpd httpd-devel apr-devel apr-util-devel mod_ssl mod_xsendfile curl curl-devel openssl openssl-devel tzdata libxml2 libxml2-devel libxslt libxslt-devel sqlite-devel git postgresql-server postgresql postgresql-devel
sudo setenforce 0
sudo service sshd start

rm -rf $HOME/code_base
mkdir $HOME/code_base
cd $HOME/code_base

# Installs Tesseract OCR
type -P tesseract > /dev/null
if [ $? -ne 0 ]; then
  sudo yum -y install libjpeg-devel libpng-devel libtiff-devel zlib-devel
  sudo yum -y install gcc gcc-c++ make
  wget http://www.leptonica.com/source/leptonica-1.69.tar.gz
  wget http://tesseract-ocr.googlecode.com/files/tesseract-ocr-3.02.02.tar.gz
  wget http://tesseract-ocr.googlecode.com/files/tesseract-ocr-3.02.eng.tar.gz
  tar zxvf leptonica-1.69.tar.gz
  tar zxvf tesseract-ocr-3.02.02.tar.gz
  tar zxvf tesseract-ocr-3.02.eng.tar.gz

  cd $HOME/code_base/leptonica-1.69 && ./configure && make && sudo make install

  cd $HOME/code_base/tesseract-ocr/ && ./autogen.sh && ./configure && make && sudo make install && sudo mv $HOME/code_base/tesseract-ocr/tessdata/eng.* /usr/local/share/tessdata/
  sudo ldconfig
fi

cd $HOME/code_base
git clone git://github.com/IntersectAustralia/dc21.git -b new_deploy
cd $HOME/code_base/dc21

# Set up RVM
type -P $HOME/.rvm/scripts/rvm > /dev/null
if [ $? -ne 0 ]; then
  curl -L http://get.rvm.io | bash -s stable --ruby=1.9.2-p290
  source $HOME/.rvm/scripts/rvm
  echo '[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"' >> $HOME/.bashrc
fi

source $HOME/.bash_profile
source $HOME/.bashrc
cd $HOME/code_base/dc21
rvm use 1.9.2-p290
rvm gemset create dc21app
gem install bundler -v 1.0.20
bundle install
status=$?

if [ $status -eq 0 ]; then
  cap production_local server_setup:deploy_config
else
  echo "$(tput setaf 1)ERROR $status: Bundle install failed$(tput sgr0)"
  exit $status;
fi

status=$?
if [ $status -eq 0 ]; then
  cap production_local deploy:first_time
else
  echo "$(tput setaf 1)ERROR $status: deploy config set up failed.$(tput sgr0)"
  exit $status;
fi

status=$?
if [ $status -eq 0 ]; then
  echo "$(tput setaf 3)Please copy the following certificate to register for AAF$(tput sgr0)"
  sudo cat /etc/shibboleth/sp-cert.pem

  echo "$(tput setaf 3)Please remember to add your SSL certificate and key to /etc/httpd/ssl/server.crt and /etc/httpd/ssl/server.key respectively$(tput sgr0)"
  echo "$(tput setaf 3)After adding your SSL certificate, run 'sudo service httpd restart'.$(tput sgr0)"
else
  echo "$(tput setaf 1)ERROR $status: The local deploy process failed. Please investigate and try again.$(tput sgr0)"
  exit $status;
fi


