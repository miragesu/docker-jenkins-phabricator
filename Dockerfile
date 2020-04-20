FROM jenkins/jenkins:lts
MAINTAINER Mirage Su <mirage.su@mic.com.tw>

# switch to root, let the entrypoint drop back to jenkins
USER root

# install prerequisite debian packages
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y  --no-install-recommends \
     php7.0 \
     php7.0-curl \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# install arcanist which is the command-line tool for Phabricator
RUN mkdir /phabricator_tool \
  && cd /phabricator_tool \
  && git clone https://github.com/phacility/arcanist.git \
  && ln -s /phabricator_tool/arcanist/bin/arc /usr/bin/arc

# install gosu for a better su+exec command
#ARG GOSU_VERSION=1.12
#RUN dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
# && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch" \
# && chmod +x /usr/local/bin/gosu \
# && gosu nobody true

ARG GOSU_VERSION=1.12
RUN GOSU_SHA=0f25a21cf64e58078057adc78f38705163c1d564a959ff30a891c31917011a54 \
  && dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
  && curl -sSL -o /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch" \
  && chmod +x /usr/local/bin/gosu \
  && echo "$GOSU_SHA  /usr/local/bin/gosu" | sha256sum -c -

# entrypoint is used to update docker gid and revert back to jenkins user
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

