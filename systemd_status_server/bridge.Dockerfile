FROM docker.io/library/ubuntu:latest as systemd

ENV container docker

# Enable apt repositories.
RUN sed -i 's/# deb/deb/g' /etc/apt/sources.list

# Enable systemd.
RUN apt-get update ; \
  apt-get install -y systemd systemd-sysv ; \
  apt-get clean ; \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ; \
  cd /lib/systemd/system/sysinit.target.wants/ ; \
  ls | grep -v systemd-tmpfiles-setup | xargs rm -f $1 ; \
  rm -f /lib/systemd/system/multi-user.target.wants/* ; \
  rm -f /etc/systemd/system/*.wants/* ; \
  rm -f /lib/systemd/system/local-fs.target.wants/* ; \
  rm -f /lib/systemd/system/sockets.target.wants/*udev* ; \
  rm -f /lib/systemd/system/sockets.target.wants/*initctl* ; \
  rm -f /lib/systemd/system/basic.target.wants/* ; \
  rm -f /lib/systemd/system/anaconda.target.wants/* ; \
  rm -f /lib/systemd/system/plymouth* ; \
  rm -f /lib/systemd/system/systemd-update-utmp*

# install dart sdk
FROM docker.io/library/dart:stable AS build

WORKDIR /app/systemd_status_client
COPY systemd_status_client/pubspec.* ./

WORKDIR /app/systemd_status_bridge
COPY systemd_status_bridge/pubspec.* ./
RUN dart pub get

WORKDIR /app/systemd_status_client
COPY systemd_status_client .

WORKDIR /app/systemd_status_bridge
COPY systemd_status_bridge .
RUN dart pub get --offline
RUN dart run build_runner build --delete-conflicting-outputs
RUN dart compile exe bin/bridge.dart -o bin/bridge

FROM systemd

COPY --from=build /app/systemd_status_bridge/bin/bridge /app/bin/
COPY systemd_status_bridge/docker/bridge.service /etc/systemd/system/bridge.service
RUN ln -s /etc/systemd/system/bridge.service /etc/systemd/system/multi-user.target.wants/bridge.service
RUN echo 'test-key' > /app/key.txt

VOLUME [ "/sys/fs/cgroup" ]

CMD ["/lib/systemd/systemd"]
