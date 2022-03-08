FROM ghcr.io/sdr-enthusiasts/docker-baseimage:python

RUN set -x && \
# define packages needed for installation and general management of the container:
    TEMP_PACKAGES=() && \
    KEPT_PACKAGES=() && \
    KEPT_PIP3_PACKAGES=() && \
    KEPT_PACKAGES+=(procps nano aptitude netcat) && \
    KEPT_PACKAGES+=(nginx) && \
    KEPT_PACKAGES+=(php-fpm) && \
    KEPT_PACKAGES+=(psmisc) && \
    # KEPT_PIP3_PACKAGES+=(apprise) && \ for now, apprise must be installed from its github main branch until the twitter image features have been released
    KEPT_PIP3_PACKAGES+=(setuptools) && \
    TEMP_PACKATES+=(git) && \
#
# Install all these packages:
    apt-get update && \
    apt-get install -o APT::Autoremove::RecommendsImportant=0 -o APT::Autoremove::SuggestsImportant=0 -o Dpkg::Options::="--force-confold" --force-yes -y --no-install-recommends  --no-install-suggests\
        ${KEPT_PACKAGES[@]} \
        ${TEMP_PACKAGES[@]} && \

#
# PIP3 installations:
    pip3 install ${KEPT_PIP3_PACKAGES[@]} && \
#
# Install Apprise:
    git clone --depth 1  https://github.com/caronc/apprise /tmp/apprise && \
    pushd /tmp/apprise/ && \
      python3 ./setup.py install && \
    popd && \

# Clean up apt installations:
    apt-get remove -y ${TEMP_PACKAGES[@]} && \
    apt-get autoremove -o APT::Autoremove::RecommendsImportant=0 -o APT::Autoremove::SuggestsImportant=0 -y && \
    apt-get clean -y && \
    rm -rf /src/* /tmp/* /var/lib/apt/lists/* && \

#
# Do some other stuff
    echo "alias dir=\"ls -alsv\"" >> /root/.bashrc && \
    echo "alias nano=\"nano -l\"" >> /root/.bashrc && \
#
# Fix directory permissions so php (user www-data) can write to it:
    mkdir -p /run/notifier/procs && chmod a=rwx /run/notifier/procs

# Copy the rootfs into place:
#
COPY rootfs/ /
