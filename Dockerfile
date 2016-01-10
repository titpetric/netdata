FROM debian:jessie

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get -qq update
RUN apt-get -qq -y install zlib1g-dev gcc make git autoconf autogen automake pkg-config
RUN apt-get -qq -y install curl

ADD build.sh /build.sh
ADD run.sh /run.sh
RUN chmod +x /run.sh /build.sh

RUN /build.sh

WORKDIR /

ENTRYPOINT ["/run.sh"]