FROM debian:trixie-slim

ARG HYPERHDR_VERSION=
ARG ARCH=

ENV DATA_DIR="/hyperhdr"
ENV UMASK=0000
ENV DATA_PERM=770
ENV UID=99
ENV GID=100
ENV USER="hyperhdr"

# Installiere Packages
RUN  echo "deb http://deb.debian.org/debian trixie contrib non-free non-free-firmware" >> /etc/apt/sources.list && \
	# Default Stuff
	apt-get update && apt-get -y upgrade && \
	apt-get -y install --no-install-recommends wget locales procps curl && \
	touch /etc/locale.gen && \
	echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
	locale-gen && \
	apt-get -y install --reinstall ca-certificates && \
	# HyperHDR
	wget -qP /tmp "https://github.com/awawa-dev/HyperHDR/releases/download/v${HYPERHDR_VERSION}/HyperHDR-${HYPERHDR_VERSION}-Linux-${ARCH}.deb" && \
	apt-get -y install /tmp/HyperHDR-${HYPERHDR_VERSION}-Linux-${ARCH}.deb && \
	rm /tmp/HyperHDR-${HYPERHDR_VERSION}-Linux-${ARCH}.deb && \
	# Cleanup
	rm -rf /var/lib/apt/lists/*

# Sprache
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Data-dir
RUN mkdir $DATA_DIR && \
	useradd -d $DATA_DIR -s /bin/bash $USER && \
	chown -R $USER $DATA_DIR && \
	ulimit -n 2048

# Scripts
ADD /scripts/ /opt/scripts/
RUN chmod -R 770 /opt/scripts/ && \
	chmod -R 770 /mnt && \
	chown -R $UID:$GID /mnt

# Ports
EXPOSE 8090 8092 19400 19444 19445


#Server Start
ENTRYPOINT ["/opt/scripts/start.sh"]
