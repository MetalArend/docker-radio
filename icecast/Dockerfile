FROM ubuntu:trusty
MAINTAINER Bart Reunes

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -y update && \
    apt-get -y install icecast2 python-setuptools gettext && \
    apt-get clean

RUN easy_install supervisor && \
    easy_install supervisor-stdout

ENV ICECAST_SOURCE_PASSWORD hackme
ENV ICECAST_ADMIN_USER admin
ENV ICECAST_ADMIN_PASSWORD hackme
ENV ICECAST_PASSWORD hackmemore
ENV ICECAST_RELAY_PASSWORD hackme
ENV ICECAST_NAME "Icecast on Docker"
ENV ICECAST_DESCRIPTION "Icecast on Docker"

ADD . /container
RUN chmod +x /container/config/start.sh

EXPOSE 8000
CMD ["/container/config/start.sh"]
