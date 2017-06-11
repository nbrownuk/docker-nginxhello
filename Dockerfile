FROM buildpack-deps:jessie-curl as build

# Define build argument for version
ARG VERSION

# Define variable to use to peg version
ENV VERSION=${VERSION:-1.12.0} \
    GPG_KEY=B0F4253373F8F6F510D42178520A9993A1C052F8

# Install build tools, libraries and utilities
RUN apt-get update                                                   && \
    apt-get install -y --no-install-recommends --no-install-suggests    \
        build-essential                                                 \
        libpcre3-dev                                                    \
        zlib1g-dev

# Retrieve and unpack Nginx source
RUN TMP="$(mktemp -d)" && cd "$TMP"                                  && \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys $GPG_KEY  && \
    wget -q http://nginx.org/download/nginx-${VERSION}.tar.gz        && \
    wget -q http://nginx.org/download/nginx-${VERSION}.tar.gz.asc    && \
    gpg --verify nginx-${VERSION}.tar.gz.asc                         && \
    tar -xf nginx-${VERSION}.tar.gz -C /usr/local/src

# Change working directory for build
WORKDIR /usr/local/src/nginx-${VERSION}

# Build and install nginx binary
RUN ./configure --with-http_sub_module                               && \
    make                                                             && \
    make install

FROM debian:jessie-slim

COPY --from=build /usr/local/nginx /usr/local/nginx
COPY nginx.conf /usr/local/nginx/conf/
COPY index.html /usr/local/nginx/html/
COPY docker-entrypoint.sh /

# Expose port
EXPOSE 80

# Define entrypoint
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/local/nginx/sbin/nginx", "-g", "daemon off;"]
