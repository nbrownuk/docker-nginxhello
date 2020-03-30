FROM alpine:3 AS build-tools

# Install build tools
RUN apk add --no-cache --virtual .build-deps                         \
        build-base                                                   \
        gnupg                                                        \
        pcre-dev                                                     \
        wget                                                         \
        zlib-dev                                                     \
        zlib-static

FROM build-tools AS retrieve

# Define build argument for version
ARG VERSION
ENV VERSION ${VERSION:-1.16.1}

# Retrieve and verify Nginx source
RUN wget -q http://nginx.org/download/nginx-${VERSION}.tar.gz     && \
    wget -q http://nginx.org/download/nginx-${VERSION}.tar.gz.asc && \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys           \
        B0F4253373F8F6F510D42178520A9993A1C052F8                  && \
    gpg --verify nginx-${VERSION}.tar.gz.asc

# Extract archive
RUN tar xf nginx-${VERSION}.tar.gz

FROM retrieve As build

WORKDIR /nginx-${VERSION}

# Build and install nginx
RUN ./configure                                                      \
        --with-ld-opt="-static"                                      \
        --with-http_sub_module                                    && \
    make install                                                  && \
    strip /usr/local/nginx/sbin/nginx

FROM alpine:3

WORKDIR /usr/local/nginx/html

# Customise static content, and configuration
COPY --from=build /usr/local/nginx /usr/local/nginx
COPY assets /usr/local/nginx/html/
COPY nginx.conf /usr/local/nginx/conf/

# Symlink access and error logs to /dev/stdout and /dev/stderr,
# in order to make use of Docker's logging mechanism
RUN ln -sf /dev/stdout /usr/local/nginx/logs/access.log            && \
    ln -sf /dev/stderr /usr/local/nginx/logs/error.log

# Add entrypoint script
COPY docker-entrypoint.sh /

# Change default stop signal from SIGTERM to SIGQUIT
STOPSIGNAL SIGQUIT

# Expose port
EXPOSE 80

# Define entrypoint and default parameters
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/local/nginx/sbin/nginx", "-g", "daemon off;"]
