FROM debian:wheezy
MAINTAINER Camil Blanaru <camil@edka.io>

ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8
ENV LANGUAGE C.UTF-8
ENV LC_ALL C.UTF-8
ENV HOME /root

# work directory
WORKDIR /root

# update packages
RUN apt-get update

# dependencies
RUN apt-get install python-pip python-dev build-essential libyaml-dev git -y

#install nginx
RUN apt-get install -y nginx && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# install mkdocs
RUN pip install mkdocs

# Make ssh dir
RUN mkdir /root/.ssh/

#Make static folder
RUN mkdir /var/www

# Copy over private key, and set permissions
ADD id_rsa /root/.ssh/id_rsa

RUN chmod 600 /root/.ssh/id_rsa

# Create known_hosts
RUN touch /root/.ssh/known_hosts
# Add bitbucket key
RUN ssh-keyscan bitbucket.org >> /root/.ssh/known_hosts

# Clone the conf files into the docker container
RUN git clone git@bitbucket.org:camilb/mkdocs.git

RUN cd /root/mkdocs && \
mkdocs build

RUN echo "daemon off;" >> /etc/nginx/nginx.conf
ADD sites-enabled/ /etc/nginx/sites-enabled/
#ADD app/ /app/

EXPOSE 80

CMD ["/usr/sbin/nginx"]
