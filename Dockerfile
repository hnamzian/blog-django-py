FROM centos/python-38-centos7:latest

USER root

# Install required packages for building mod-wsgi and other dependencies
RUN yum -y update && yum install -y \
    gcc \
    make \
    httpd-devel \
    python38-devel \
    && yum clean all

# Copy the application source code into the container
COPY . /tmp/src

# Move the S2I scripts to the correct location
RUN mv /tmp/src/.s2i/bin /tmp/scripts

# Clean up unnecessary files and set proper permissions
RUN rm -rf /tmp/src/.git* && \
    chown -R 1001 /tmp/src && \
    chgrp -R 0 /tmp/src && \
    chmod -R g+w /tmp/src

# Switch back to non-root user
USER 1001

# Set environment variables required by S2I
ENV S2I_SCRIPTS_PATH=/usr/libexec/s2i \
    S2I_BASH_ENV=/opt/app-root/etc/scl_enable \
    DISABLE_COLLECTSTATIC=1 \
    DISABLE_MIGRATE=1

# Install Python dependencies, including mod-wsgi
RUN pip install --upgrade pip && \
    pip install mod-wsgi

# Run the S2I assemble script
RUN /tmp/scripts/assemble

# Start the application using the S2I run script
CMD [ "/tmp/scripts/run" ]
