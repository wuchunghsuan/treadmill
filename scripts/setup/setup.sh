#!/usr/bin/zsh

sudo yum -y update
sudo yum -y install java wget git

#treadmill services deps
sudo yum -y install ipset iptables bridge-utils libcgroup-tools lvm2*

# treadmill build deps
sudo yum -y group install "Development Tools"
sudo yum -y install python-devel ntp krb5-server krb5-libs krb5-devel
sudo yum -y install epel-release
sudo yum -y install mercurial openssl-devel

# pip
curl "https://bootstrap.pypa.io/get-pip.py" | sudo python
sudo pip install -r requirements.txt

# docker-compose
curl -L https://github.com/docker/compose/releases/download/1.12.0/docker-compose-`uname -s`-`uname -m` > docker-compose
sudo mv docker-compose > /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# s6
if [[ ! -d /home/vagrant/skalibs/.git ]]
	then
		git clone git://git.skarnet.org/skalibs
		cd skalibs && ./configure && make && sudo make install && cd -
fi

if [[ ! -d /home/vagrant/execline/.git ]]
	then
		git clone git://git.skarnet.org/execline
		cd execline && ./configure && make && sudo make install && cd -
fi

if [[ ! -d /home/vagrant/s6/.git ]]
	then
		git clone https://github.com/skarnet/s6.git
		cd s6 && ./configure && make && sudo make install && sudo mv s6-* /usr/local/bin && cd -
fi

sudo yum -y install docker
sudo groupadd docker
sudo usermod -aG docker $USER

# To mock proid.
sudo useradd mock-user

cat /home/vagrant/treadmill-scheduler/.env/init.sh >> /home/vagrant/.zshrc

# Defaults  env_keep += "TREADMILL_DNS_DOMAIN"
# Defaults  env_keep += "TREADMILL_LDAP"
# Defaults  env_keep += "TREADMILL_LDAP_SEARCH_BASE"
# Defaults  env_keep += "TREADMILL_ENV"
# Defaults  env_keep += "TREADMILL_PROID"
# Defaults  env_keep += "TREADMILL_CELL"
# Defaults  env_keep += "TREADMILL_EXE_WHITELIST"
# Defaults  env_keep += "TREADMILL_WHITELIST"
RED='\033[0;31m'
NC='\033[0m' # No Color
echo "${RED}Notice: ${NC} visudo to set environment variables in root user:"
echo "Defaults  env_keep += \"TREADMILL_DNS_DOMAIN\"
Defaults  env_keep += \"TREADMILL_LDAP\"
Defaults  env_keep += \"TREADMILL_LDAP_SEARCH_BASE\"
Defaults  env_keep += \"TREADMILL_ENV\"
Defaults  env_keep += \"TREADMILL_PROID\"
Defaults  env_keep += \"TREADMILL_CELL\"
Defaults  env_keep += \"TREADMILL_EXE_WHITELIST\"
Defaults  env_keep += \"TREADMILL_WHITELIST\""
echo "${RED}Notice: ${NC} Set the number of CPUs in virtualbox UI to 4 or more."
echo "${RED}Notice: ${NC} re-ssh to allow normal user to use docker."