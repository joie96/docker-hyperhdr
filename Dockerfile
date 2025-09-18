FROM debian:trixie-slim

ENV DATA_DIR="/hyperhdr"
ENV UMASK=0000
ENV DATA_PERM=770
ENV UID=99
ENV GID=100
ENV USER="hyperhdr"

RUN  echo "deb http://deb.debian.org/debian trixie contrib non-free non-free-firmware" >> /etc/apt/sources.list && \
	apt-get update && apt-get -y upgrade && \
	apt-get -y install --no-install-recommends wget locales procps curl && \
	touch /etc/locale.gen && \
	echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
	locale-gen && \
	apt-get -y install --reinstall ca-certificates && \
	#HyperHDr
	curl -fsSL https://awawa-dev.github.io/hyperhdr.public.apt.gpg.key | sudo dd of=/usr/share/keyrings/hyperhdr.public.apt.gpg.key && \
	chmod go+r /usr/share/keyrings/hyperhdr.public.apt.gpg.key && \
	echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hyperhdr.public.apt.gpg.key] https://awawa-dev.github.io $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hyperhdr.list > /dev/null && \
	apt update && \
	apt install hyperhdr -y  && \
	#Cleanup
	rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

RUN mkdir $DATA_DIR && \
	useradd -d $DATA_DIR -s /bin/bash $USER && \
	chown -R $USER $DATA_DIR && \
	ulimit -n 2048

ADD /scripts/ /opt/scripts/
RUN chmod -R 770 /opt/scripts/ && \
	chmod -R 770 /mnt && \
	chown -R $UID:$GID /mnt


EXPOSE 8090 8092 19400 19444 19445


#Server Start
ENTRYPOINT ["/opt/scripts/start.sh"]
