source $HOME/setup_config
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

  cd $HOME/code_base/
  # Clean up downloaded files
  rm -rf $HOME/code_base/tesseract-ocr* $HOME/code_base/leptonica-1.69*
  echo "$(tput setaf 2)Tesseract installed.$(tput sgr0)"
else
  echo "$(tput setaf 2)Tesseract detected, nothing to do.$(tput sgr0)"
fi

cd $HOME/code_base
git clone git://github.com/IntersectAustralia/dc21.git
cd $HOME/code_base/dc21

# Set up RVM
type -P $HOME/.rvm/scripts/rvm > /dev/null
if [ $? -ne 0 ]; then
  curl -sSL https://rvm.io/mpapis.asc | gpg --import -
  curl -L http://get.rvm.io | bash -s stable --ruby=2.0.0-p481
  status=$?
  if [ $status -eq 0 ]; then
    source $HOME/.rvm/scripts/rvm
    echo '[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"' >> $HOME/.bashrc
  else
    echo "$(tput setaf 1)ERROR $status: RVM install failed. Manually install RVM and rerun the vm_setup script.$(tput sgr0)"
    exit $status;
  fi
fi

source $HOME/.bash_profile
source $HOME/.bashrc

# Update RVM and Ruby to 2.0.0 if needed
rvm list | grep ruby-2.0.0-p481 > /dev/null
if [ $? -ne 0 ]; then
  echo "Installing ruby-2.0.0-p481 as it was not detected"
  rvm get head
  rvm install 2.0.0-p481
  status=$?
  if [ $status -eq 0 ]; then
    echo "$(tput setaf 2)RVM updated and Ruby 2.0.0-p481 installed.$(tput sgr0)"
  else
    echo "$(tput setaf 1)ERROR $status: Ruby 2.0.0-p481 install failed. Manually install Ruby 2.0.0-p481 and rerun the vm_setup script.$(tput sgr0)"
    exit $status;
  fi
fi

cd $HOME/code_base/dc21
git checkout tags/$DC21_TAG
rvm use 2.0.0-p481@dc21app --create

gem install bundler -v 1.9.4
bundle install
status=$?

source $HOME/setup_config
if [ $status -eq 0 ]; then
  cap local server_setup:deploy_config
else
  echo "$(tput setaf 1)ERROR $status: Bundle install failed$(tput sgr0)"
  exit $status;
fi

status=$?
if [ $status -eq 0 ]; then
  if [ "$DC21_UPGRADE" = "true" ]; then
    sudo /etc/init.d/redis_6379 stop
    sudo rm /etc/init.d/redis_6379
    cap local server_setup:gem_install server_setup:passenger resque:setup shared_file:setup server_setup:config:apache deploy:safe
  else
    cap local deploy:first_time
    sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/httpd/ssl/server.key -out /etc/httpd/ssl/server.crt
  fi
else
  echo "$(tput setaf 1)ERROR $status: deploy config set up failed.$(tput sgr0)"
  exit $status;
fi

sudo service httpd restart
cap local deploy:restart

status=$?

if [ $status -eq 0 ]; then
  echo "$(tput setaf 2)DIVER instance installed$(tput sgr0)"
else
  echo "$(tput setaf 1)ERROR $status: The local deploy process failed. Please investigate and try again.$(tput sgr0)"
  exit $status;
fi
