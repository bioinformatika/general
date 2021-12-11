FROM centos:7.7.1908

ENV PATH "/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/bin"

# Install common YUM dependency packages
RUN set -ex \
    && yum makecache fast \
    && yum -y update \
    && yum -y install epel-release \
    && yum -y install \
        autoconf \
        bash-completion \
        bzip2 \
        bzip2-devel \
        curl \
        file \
        iproute \
        gcc \
        gcc-c++ \
        gdbm-devel \
        git \
        glibc-devel \
        gmp-devel \
        libffi-devel \
        libGL-devel \
        libX11-devel \
        make \
        mariadb-server \
        mariadb-devel \
        munge \
        munge-devel \
        ncurses-devel \
        openssl-devel \
        openssl-libs \
        perl \
        pkconfig \
        psmisc \
        readline-devel \
        sqlite-devel \
        tcl-devel \
        tix-devel \
        tk \
        tk-devel \
        supervisor \
        wget \
        vim-enhanced \
        xz-devel \
        zlib-devel \
    && yum clean all \
    && rm -rf /var/cache/yum

COPY files/install-python.sh /tmp

# UPGRADE PIP
#RUN pip install --upgrade pip

# Install Python versions
#ARG PYTHON_VERSIONS="2.7 3.5 3.6 3.7 3.8"
#RUN set -ex \
#    && for version in ${PYTHON_VERSIONS}; do /tmp/install-python.sh "$version"; done \
#    && rm -f /tmp/install-python.sh

# Compile, build and install Slurm from Git source
ARG SLURM_TAG=slurm-19-05-4-1
RUN set -ex \
    && git clone https://github.com/SchedMD/slurm.git \
    && pushd slurm \
    && git checkout tags/$SLURM_TAG \
    && ./configure --enable-debug --enable-front-end --prefix=/usr \
       --sysconfdir=/etc/slurm --with-mysql_config=/usr/bin \
       --libdir=/usr/lib64 \
    && make install \
    && install -D -m644 etc/cgroup.conf.example /etc/slurm/cgroup.conf.example \
    && install -D -m644 etc/slurm.conf.example /etc/slurm/slurm.conf.example \
    && install -D -m644 etc/slurmdbd.conf.example /etc/slurm/slurmdbd.conf.example \
    && install -D -m644 contribs/slurm_completion_help/slurm_completion.sh /etc/profile.d/slurm_completion.sh \
    && popd \
    && rm -rf slurm \
    && groupadd -r slurm  \
    && useradd -r -g slurm slurm \
    && mkdir /etc/sysconfig/slurm \
        /var/spool/slurmd \
        /var/run/slurmd \
        /var/lib/slurmd \
        /var/log/slurm \
    && chown slurm:root /var/spool/slurmd \
        /var/run/slurmd \
        /var/lib/slurmd \
        /var/log/slurm \
    && /sbin/create-munge-key

# Set Vim and Git defaults
RUN set -ex \
    && echo "syntax on"           >> $HOME/.vimrc \
    && echo "set tabstop=4"       >> $HOME/.vimrc \
    && echo "set softtabstop=4"   >> $HOME/.vimrc \
    && echo "set shiftwidth=4"    >> $HOME/.vimrc \
    && echo "set expandtab"       >> $HOME/.vimrc \
    && echo "set autoindent"      >> $HOME/.vimrc \
    && echo "set fileformat=unix" >> $HOME/.vimrc \
    && echo "set encoding=utf-8"  >> $HOME/.vimrc \
    && git config --global color.ui auto \
    && git config --global push.default simple

# Install CONDA
RUN curl -sSL https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -o /tmp/miniconda.sh \
    && bash /tmp/miniconda.sh -bfp /usr/local/ \
    && rm -rf /tmp/miniconda.sh \
    && conda install -y python=3 \
    && conda update conda \
    && conda clean --all --yes

# Copy Slurm configuration files into the container
COPY files/slurm/slurm.conf /etc/slurm/slurm.conf
COPY files/slurm/gres.conf /etc/slurm/gres.conf
COPY files/slurm/slurmdbd.conf /etc/slurm/slurmdbd.conf
COPY files/supervisord.conf /etc/

# Mark externally mounted volumes
VOLUME ["/var/lib/mysql", "/var/lib/slurmd", "/var/spool/slurmd", "/var/log/slurm"]

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

# Add Tini
ARG TINI_VERSION=v0.18.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /sbin/tini
RUN chmod +x /sbin/tini

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/docker-entrypoint.sh"]
CMD ["/bin/bash"]

RUN mkdir /data /config

ENV PATH=$PATH:/opt/conda/bin
ENV PATH=$PATH:/home/root/bin
ENV HOME=/home/root

RUN mkdir /home/root
RUN mkdir /home/root/bin

RUN conda config --add channels r
RUN conda config --add channels bioconda

RUN conda upgrade conda

VOLUME ["/data", "/config"]

WORKDIR /data
USER root

RUN mkdir -p /deployments

# JAVA_APP_DIR is used by run-java.sh for finding the binaries
ENV JAVA_APP_DIR=/deployments \
    JAVA_MAJOR_VERSION=8
# /dev/urandom is used as random source, which is prefectly safe
# according to http://www.2uo.de/myths-about-urandom/
RUN yum install -y \
       java-1.8.0-openjdk \ 
       ava-1.8.0-openjdk-devel \ 
    && echo "securerandom.source=file:/dev/urandom" >> /usr/lib/jvm/jre/lib/security/java.security \
    && yum clean all
ENV JAVA_HOME /etc/alternatives/jre






