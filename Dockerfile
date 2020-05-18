FROM jenkins/jenkins:2.233
MAINTAINER Mirage Su <mirage.su@mic.com.tw>

#ENV JENKINS_USER admin
#ENV JENKINS_PASS admin

# Skip initial setup
#ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false

# install plugin
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt

# switch to root, let the entrypoint drop back to jenkins
USER root

# install prerequisite debian packages
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y  --no-install-recommends \
     php7.0 php7.0-curl \
     vim \
     locales \
     python3 \
     build-essential libsdl1.2-dev texinfo gawk chrpath diffstat \
     cpio file \
     sudo \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Add sudo privileges to jenkins
RUN chmod +w /etc/sudoers; echo "jenkins   ALL=(ALL)       NOPASSWD:ALL" >> /etc/sudoers; chmod -w /etc/sudoers

# install arcanist which is the command-line tool for Phabricator
RUN mkdir /phabricator_tool \
  && cd /phabricator_tool \
  && git clone https://github.com/phacility/arcanist.git \
  && ln -s /phabricator_tool/arcanist/bin/arc /usr/bin/arc

# install gosu for a better su+exec command
ARG GOSU_VERSION=1.12
RUN GOSU_SHA=0f25a21cf64e58078057adc78f38705163c1d564a959ff30a891c31917011a54 \
  && dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
  && curl -sSL -o /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch" \
  && chmod +x /usr/local/bin/gosu \
  && echo "$GOSU_SHA  /usr/local/bin/gosu" | sha256sum -c -

# Set the locale
RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

# entrypoint is used to update docker gid and revert back to jenkins user
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

