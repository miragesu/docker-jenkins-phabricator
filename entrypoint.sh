#!/bin/sh

set -x

chown -R 1000 "$JENKINS_HOME"

if [ "$(id -u)" = "0" ]; then
  # get gid of docker socket file
  SOCK_DOCKER_GID=`ls -ng /var/run/docker.sock | cut -f3 -d' '`

  # get group of docker inside container
  groupadd docker
  CUR_DOCKER_GID=`getent group docker | cut -f3 -d: || true`

  # if they don't match, adjust
  if [ ! -z "$SOCK_DOCKER_GID" -a "$SOCK_DOCKER_GID" != "$CUR_DOCKER_GID" ]; then
    groupmod -g ${SOCK_DOCKER_GID} -o docker
  fi
  if ! groups jenkins | grep -q docker; then
    usermod -aG docker jenkins
  fi
fi

cd /git_spx_plugin
sudo su jenkins setup.sh
exec gosu jenkins /sbin/tini -- /usr/local/bin/jenkins.sh

