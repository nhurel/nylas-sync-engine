FROM ubuntu:precise
MAINTAINER nathan@hurel.me
RUN apt-get update && apt-get -y install python-software-properties\ 
		   git \
                   mercurial \
                   wget \
                   supervisor \
                   mysql-client \
                   python \
                   python-dev \
                   python-pip \
                   python-setuptools \
                   build-essential \
                   libmysqlclient-dev \
                   gcc \
                   g++ \
                   libzmq-dev \
                   libxml2-dev \
                   libxslt-dev \
                   lib32z1-dev \
                   libffi-dev \
                   pkg-config \
                   python-lxml \
                   tmux \
                   curl \
                   tnef \
                   stow

RUN mkdir -p /tmp/build
WORKDIR /tmp/build
ENV LIBSODIUM_VER=1.0.0

RUN curl -L -O https://github.com/jedisct1/libsodium/releases/download/${LIBSODIUM_VER}/libsodium-${LIBSODIUM_VER}.tar.gz
RUN echo 'ced1fe3d2066953fea94f307a92f8ae41bf0643739a44309cbe43aa881dbc9a5 *libsodium-1.0.0.tar.gz' | sha256sum -c || exit 1
RUN tar -xzf libsodium-${LIBSODIUM_VER}.tar.gz
WORKDIR /tmp/build/libsodium-1.0.0
RUN ./configure --prefix=/usr/local/stow/libsodium-${LIBSODIUM_VER} &&\ 
                  make -j4 &&\ 
                  rm -rf /usr/local/stow/libsodium-${LIBSODIUM_VER} &&\ 
                  mkdir -p /usr/local/stow/libsodium-${LIBSODIUM_VER} &&\ 
                  make install &&\ 
                  stow -d /usr/local/stow -R libsodium-${LIBSODIUM_VER} &&\ 
                  ldconfig
WORKDIR /tmp/build
RUN rm -rf libsodium-${LIBSODIUM_VER} libsodium-${LIBSODIUM_VER}.tar.gz &&\ 
     pip install 'pip>=1.5.6' 'setuptools>=5.3' && hash pip && pip install 'pip>=1.5.6' 'setuptools>=5.3' tox &&\ 
     rm -rf /usr/lib/python2.7/dist-packages/setuptools.egg-info 

WORKDIR /opt
RUN git clone https://github.com/nylas/sync-engine.git && rm -rf /opt/sync-engine/.git
WORKDIR /opt/sync-engine
RUN find . -name \*.pyc -delete &&\ 
    pip install -r requirements.txt && pip install -e . && \ 
    useradd inbox && \ 
    mkdir -p /etc/inboxapp 
ADD config.json /etc/inboxapp/
ADD secrets.yml /etc/inboxapp/
RUN chmod 0644 /etc/inboxapp/config.json && chmod 0600 /etc/inboxapp/secrets.yml && chown -R inbox /etc/inboxapp
RUN apt-get -y autoremove && apt-get clean &&\ 
    mkdir -p /var/lib/inboxapp/parts && mkdir -p /var/log/inboxapp && chown inbox /var/log/inboxapp &&\ 
    chown -R inbox /opt/sync-engine
USER inbox
WORKDIR /opt/sync-engine/
CMD /opt/sync-engine/bin/inbox-start
