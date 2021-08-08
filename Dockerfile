FROM nginx:mainline-alpine AS build-tools

WORKDIR /usr/share/nginx/html

# Customise static content, and configuration
COPY assets /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf

# Symlink access and error logs to /dev/stdout and /dev/stderr,
# in order to make use of Docker's logging mechanism
RUN mkdir -p /usr/share/nginx/logs && \
    ln -sf /dev/stdout /usr/share/nginx/logs/access.log            && \
    ln -sf /dev/stderr /usr/share/nginx/logs/error.log

# Add entrypoint script
COPY docker-entrypoint.sh /

# Change default stop signal from SIGTERM to SIGQUIT
STOPSIGNAL SIGQUIT

# Expose port
EXPOSE 80

# Define entrypoint and default parameters
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/sbin/nginx", "-g", "daemon off;"]
