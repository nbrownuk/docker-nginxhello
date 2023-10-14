# syntax=docker/dockerfile:1

FROM alpine:3 AS build-tools

# Install build tools
RUN apk add --no-cache                                                   \
        build-base                                                       \
        gnupg                                                            \
        pcre-dev                                                         \
        wget                                                             \
        zlib-dev                                                         \
        zlib-static

FROM build-tools AS retrieve

# Define build argument for version
ARG VERSION
ENV VERSION ${VERSION:-1.16.1}

# Retrieve and extract Nginx source archive
RUN <<EOF
wget -q http://nginx.org/download/nginx-${VERSION}.tar.gz
wget -q http://nginx.org/download/nginx-${VERSION}.tar.gz.asc
export GNUPGHOME="$(mktemp -d)"
gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys              \
    13C82A63B603576156E30A4EA0EA981B66B0D967
gpg --batch --verify nginx-${VERSION}.tar.gz.asc nginx-${VERSION}.tar.gz
tar xf nginx-${VERSION}.tar.gz
rm -rf "$GNUPGHOME" nginx-${VERSION}.tar.*
EOF

FROM retrieve As build

WORKDIR /nginx-${VERSION}

# Build and install nginx
RUN <<EOF
./configure --with-ld-opt="-static" --with-http_sub_module
make install
strip /usr/local/nginx/sbin/nginx
EOF

FROM alpine:3

WORKDIR /usr/local/nginx/html

# Customise static content, and configuration
COPY --from=build /usr/local/nginx /usr/local/nginx
COPY assets /usr/local/nginx/html/
COPY nginx.conf /usr/local/nginx/conf/

# Symlink access and error logs to /dev/stdout and /dev/stderr,
# in order to make use of Docker's logging mechanism
RUN <<EOF
ln -sf /dev/stdout /usr/local/nginx/logs/access.log
ln -sf /dev/stderr /usr/local/nginx/logs/error.log
EOF

# Add entrypoint script
COPY docker-entrypoint.sh /

# Change default stop signal from SIGTERM to SIGQUIT
STOPSIGNAL SIGQUIT

# Expose port
EXPOSE 80

# Define entrypoint and default parameters
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/local/nginx/sbin/nginx", "-g", "daemon off;"]
