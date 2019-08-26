FROM acentera/dev:severless-cms-base-v0.0.1


WORKDIR /data/
ADD hugo /usr/local/bin/hugo
ADD docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod o+rx /usr/local/bin/hugo /usr/local/bin/docker-entrypoint.sh

CMD ["/usr/local/bin/docker-entrypoint.sh"]
