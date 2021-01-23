FROM alpine as binary
ARG VERSION

ENV FILENAME bitcoin-$VERSION-x86_64-linux-gnu.tar.gz
ENV DOWNLOAD_URL https://bitcoin.org/bin/bitcoin-core-$VERSION/${FILENAME}

RUN echo "URL=" ${DOWNLOAD_URL}

RUN apk update \
  && apk --no-cache add wget bash ca-certificates

RUN wget  --progress=bar:force:noscroll ${DOWNLOAD_URL} -O /bitcoin.tar.gz

RUN tar zxvf /bitcoin.tar.gz && mv /bitcoin-* /bitcoin

FROM alpine AS final

ARG GLIBC_VERSION=2.30-r0

RUN apk update \
  && apk --no-cache add wget bash ca-certificates \
  && wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
  && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk \
  && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk \
  && apk --no-cache add glibc-${GLIBC_VERSION}.apk \
  && apk --no-cache add glibc-bin-${GLIBC_VERSION}.apk \
  && rm -rf /glibc-${GLIBC_VERSION}.apk \
  && rm -rf /glibc-bin-${GLIBC_VERSION}.apk \
  && mkdir /root/.bitcoin \
  && apk del wget ca-certificates

COPY --from=binary /bitcoin/bin/bitcoind /usr/local/bin/

ADD ./bin/docker_entrypoint.sh /usr/local/bin/docker_entrypoint.sh
RUN chmod a+x /usr/local/bin/docker_entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker_entrypoint.sh"]
