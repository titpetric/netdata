FROM debian:jessie

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -qq update \
    && apt-get -qq -y install \
    zlib1g-dev \
    gcc \
    make \
    git \
    autoconf \
    autogen \
    automake \
    pkg-config \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


ADD build.sh /build.sh
ADD run.sh /run.sh
RUN chmod +x /run.sh /build.sh; sync; sleep 1; /build.sh

WORKDIR /

ENTRYPOINT ["/run.sh"]
