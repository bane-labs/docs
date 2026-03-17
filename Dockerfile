FROM node:10-buster

# Build tools are required by some older GitBook plugins.
# Debian Buster is EOL; switch apt sources to archive mirrors.
RUN sed -i 's|deb.debian.org/debian|archive.debian.org/debian|g' /etc/apt/sources.list \
    && sed -i 's|security.debian.org/debian-security|archive.debian.org/debian-security|g' /etc/apt/sources.list \
    && sed -i '/buster-updates/d' /etc/apt/sources.list \
    && printf 'Acquire::Check-Valid-Until "false";\nAcquire::AllowInsecureRepositories "true";\nAcquire::AllowDowngradeToInsecureRepositories "true";\n' > /etc/apt/apt.conf.d/99archive \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        git \
        python \
        make \
        g++ \
    && rm -rf /var/lib/apt/lists/*

# Use legacy GitBook CLI.
RUN npm install -g gitbook-cli@2.3.2

WORKDIR /srv/book

EXPOSE 4000

# Mount your docs repo to /srv/book when running.
# Fetching at runtime avoids image-build failures from old cli internals.
CMD ["sh", "-lc", "gitbook fetch 3.2.3 && gitbook install && gitbook serve --host 0.0.0.0 --port 4000"]
