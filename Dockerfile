#author: chris murray
#version: 1.33
#date 20210802

FROM ubuntu:18.04
LABEL maintainer="cmurray@cableone.net"

#update os
RUN apt update --fix-missing
RUN apt upgrade -y

#disable apt prompting
RUN export DEBIAN_FRONTEND=noninteractive

#install packages
RUN apt install -y inetutils-ping mailutils nagios-nrpe-plugin jq
RUN apt update --fix-missing
RUN apt install -y curl expect gnupg2 telnet nano rsyslog ssh

#install powershell
RUN curl -o /etc/apt/sources.list.d/microsoft.list https://packages.microsoft.com/config/ubuntu/18.04/prod.list
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN apt update
RUN apt install -y powershell

RUN pwsh -Command Install-Module -Name VMware.PowerCLI -Force
RUN echo -e "yes\n" | pwsh -Command Set-PowerCLIConfiguration -InvalidCertificateAction Ignore
#copy install packages

#copy install scripts

#run install scripts

#expose ports
#EXPOSE 80/tcp

#create user accounts
#RUN  useradd -m -u 1000 gns3
RUN  useradd -m -u 1000 gns3
RUN  useradd -m -u 5001 sync_nmiaa
RUN  useradd -m -u 5002 sync_nmipa
RUN  useradd -m -u 5003 sync_cytrans-b03
RUN  useradd -m -u 5004 sync_cytrans-b05
RUN  useradd -m -u 5005 sync_cyfun-cs

#entrypoint
COPY ./shared/usr/local/sbin/entrypoint.sh /usr/local/sbin/
ENTRYPOINT /usr/local/sbin/entrypoint.sh
