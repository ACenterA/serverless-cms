FROM ubuntu:latest

ENV ATOM_VERSION v1.11.2

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
                    git \
                    curl \
                    ca-certificates \
                    libgtk2.0-0 \
                    libxtst6 \
                    libnss3 \
                    libgconf-2-4 \
                    libasound2 \
                    fakeroot \
                    gconf2 \
                    gconf-service \
                    libcap2 \
                    libnotify4 \
                    libxtst6 \
                    libnss3 \
                    gvfs-bin \
                    xdg-utils \
                    python && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    curl -L https://github.com/atom/atom/releases/download/${ATOM_VERSION}/atom-amd64.deb > /tmp/atom.deb && \
    dpkg -i /tmp/atom.deb && \
    rm -f /tmp/atom.deb && \
    useradd -d /home/atom -m atom

RUN apm install project-manager

# install our dependencies and nodejs
# Using Ubuntu
#RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -
RUN curl -sL https://deb.nodesource.com/setup_7.x | bash - && \
    apt-get install -y nodejs python-pip awscli && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ADD docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

USER atom
WORKDIR /data/

CMD ["/usr/local/bin/docker-entrypoint.sh"]
#CMD ["/usr/bin/atom","-f"]