FROM debian:jessie-slim

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
        wget                                                            \
        zlib1g-dev                                                   && \
                                                                        \
# Retrieve and unpack Nginx source                                      \
    TMP="$(mktemp -d)" && cd "$TMP"                                  && \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys $GPG_KEY  && \
    wget -q http://nginx.org/download/nginx-${VERSION}.tar.gz        && \
    wget -q http://nginx.org/download/nginx-${VERSION}.tar.gz.asc    && \
    gpg --verify nginx-${VERSION}.tar.gz.asc                         && \
    tar -xf nginx-${VERSION}.tar.gz -C /usr/local/src                && \
                                                                        \
# Build Nginx                                                           \
    cd /usr/local/src/nginx-${VERSION}                               && \
    ./configure --with-http_sub_module                               && \
    make                                                             && \
    make install                                                     && \
                                                                        \
# Clean up                                                              \
    apt-get remove --purge -y                                           \
        build-essential                                                 \
        libpcre3-dev                                                    \
        wget                                                            \
        zlib1g-dev                                                   && \
    apt-get autoremove -y                                            && \
    cd /                                                             && \
    rm -rf $TMP/nginx-${VERSION}.tar.gz                                 \
           /var/lib/apt/lists/*                                         \
           /usr/local/src/nginx-${VERSION}

COPY nginx.conf /usr/local/nginx/conf/
COPY index.html /usr/local/nginx/html/
COPY docker-entrypoint.sh /

# Expose port
EXPOSE 80

# Define entrypoint
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/local/nginx/sbin/nginx", "-g", "daemon off;"]
