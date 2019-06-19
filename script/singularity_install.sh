#!/bin/bash

if grep -i 'ubuntu\|debian' /etc/os-release;then
  apt update
  apt install -y singularity-container
fi


if grep -i 'centos\|redhat' /etc/os-release;then
  yum install -y epel-release
  yum install -y singularity
fi



