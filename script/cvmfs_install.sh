#!/bin/bash



# CentOS CVMFS client install
if grep -i 'centos\|redhat' /etc/os-release;then
  sudo yum install -y https://ecsft.cern.ch/dist/cvmfs/cvmfs-release/cvmfs-release-latest.noarch.rpm
  sudo yum install -y cvmfs cvmfs-config-default cvmfs-auto-setup
fi


# Ubuntu CVMFS client instal
if grep -i 'ubuntu\|debian' /etc/os-release;then
  sudo apt-get install -y lsb-release
  wget https://ecsft.cern.ch/dist/cvmfs/cvmfs-release/cvmfs-release-latest_all.deb
  sudo dpkg -i cvmfs-release-latest_all.deb
  rm -f cvmfs-release-latest_all.deb
  sudo apt-get update
  sudo apt-get install -y cvmfs cvmfs-config-default
fi


# Local setup

cvmfs_config setup

mkdir -p /etc/cvmfs/keys/galaxy
cat >/etc/cvmfs/default.local <<fin666
CVMFS_REPOSITORIES="soft.computecanada.ca,ref.mugqic,soft.mugqic,ref.galaxy,soft.galaxy,data.galaxyproject.org"
CVMFS_HTTP_PROXY=DIRECT
CVMFS_USE_GEOAPI=yes
fin666



# Config soft.galaxy
cat >/etc/cvmfs/config.d/soft.galaxy.conf <<fin666
CVMFS_SERVER_URL="http://cvmfs-pub-cceast.genap.ca:8000/cvmfs/@fqrn@;http://cvmfs-pub-europe.genap.ca:8000/cvmfs/@fqrn@;http://cvmfs-pub-ccwest.genap.ca:8000/cvmfs/@fqrn@"
CVMFS_KEYS_DIR=/etc/cvmfs/keys/galaxy
fin666

cat >/etc/cvmfs/keys/galaxy/soft.galaxy.pub <<fin666

-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAsjuMPH0KgQBjq2YZTTWI
mDJJya0QvKYjcEbAMU6C/ET/B3SmTPe5ZWqRbUQrd6vJKOQTkf+O6cHS3agD6Tzp
t1uqMnZMJPtyhICJbTRdU9e8exsKjLXJK7VbpinPMi0ChQQdLpqQtg5EkcxooLSW
cOKjwnth5OBwhaLpzVrdiUhCmb+dBRi787xMLc4csfDzphbcMSOr8Hj/lJP9FVF6
S8pHpjzOO8qOBAgy7QaxBT7xdAGfNziA5/Uf/JheRgP94dWrOVbGm9R1VyZiMbVN
eYeg7skzaff4g64f8Bip9/S/Gex21UKATVaTB/8F3eLpd9CUOp0JIyk69AJYLPqv
iwIDAQAB
-----END PUBLIC KEY-----
fin666



# Config galaxyproject.org


cat >/etc/cvmfs/config.d/data.galaxyproject.org.conf <<fin666
CVMFS_SERVER_URL="http://cvmfs1-tacc0.galaxyproject.org/cvmfs/@fqrn@;http://cvmfs1-iu0.galaxyproject.org/cvmfs/@fqrn@;http://cvmfs1-psu0.galaxyproject.org/cvmfs/@fqrn@;http://galaxy.jrc.ec.europa.eu:8008/cvmfs/@fqrn@;http://cvmfs1-mel0.gvl.org.au/cvmfs/@fqrn@"
CVMFS_KEYS_DIR=/etc/cvmfs/keys/galaxy
fin666


cat >/etc/cvmfs/keys/galaxy/data.galaxyproject.org.pub <<fin666
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA5LHQuKWzcX5iBbCGsXGt
6CRi9+a9cKZG4UlX/lJukEJ+3dSxVDWJs88PSdLk+E25494oU56hB8YeVq+W8AQE
3LWx2K2ruRjEAI2o8sRgs/IbafjZ7cBuERzqj3Tn5qUIBFoKUMWMSIiWTQe2Sfnj
GzfDoswr5TTk7aH/FIXUjLnLGGCOzPtUC244IhHARzu86bWYxQJUw0/kZl5wVGcH
maSgr39h1xPst0Vx1keJ95AH0wqxPbCcyBGtF1L6HQlLidmoIDqcCQpLsGJJEoOs
NVNhhcb66OJHah5ppI1N3cZehdaKyr1XcF9eedwLFTvuiwTn6qMmttT/tHX7rcxT
owIDAQAB
-----END PUBLIC KEY-----
fin666








