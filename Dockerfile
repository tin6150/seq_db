# Dockerfile for creating and host abricate from a git repo
# mostly:
# docker build -f Dockerfile.base .  | tee LOG.Dockerfile-base.txt
# see DevNotes.rst for more build details

# modeled after atlas.git - Hist.Dockerfile.base has historical version of many OS tried and their pitfals. or see git commit 3e1332b

# branch specific settings:

FROM ubuntu:22.04   
## FROM ubuntu:22.04   # dont know what the heck is wrong with ubuntu, no version seems to have working apt-get or apt.  apt tmp down?
#FROM debian:12.5-slim 
# FROM debian:12.5-slim   ## bookworm-slim

# To set ghcr to be public, so docker pull does not get unauthorized, see
# https://www.willvelida.com/posts/pushing-container-images-to-github-container-registry/#making-our-image-publicly-accessible
# but forked code seems to not inherit the public setting, so would need to create a separate container for it from scratch :-/ 
LABEL org.opencontainers.image.source="https://github.com/tin6150/abricate"
LABEL ORIGINAL_AUTHOR="https://github.com/tseemann/abricate"


MAINTAINER Tin (at) BERKELEY.edu
ARG DEBIAN_FRONTEND=noninteractive
#ARG TERM=vt100
ARG TERM=dumb
ARG TZ=PST8PDT 
#https://no-color.org/
ARG NO_COLOR=1


## this stanza below should be disabled when building FROM: r-base:4.1.1
RUN echo  ''  ;\
    touch _TOP_DIR_OF_CONTAINER_  ;\
    echo "This container build as ubuntu  " | tee -a _TOP_DIR_OF_CONTAINER_  ;\
    export TERM=dumb      ;\
    export NO_COLOR=TRUE  ;\
    apt-get update ;\  
    apt-get -y --quiet install git wget ;\
    #--apt-get -y --quiet install r-base ;\
    cd /    ;\
    echo ""  

RUN echo  ''  ;\
    touch _TOP_DIR_OF_CONTAINER_  ;\
    echo "begining docker build process at " | tee -a _TOP_DIR_OF_CONTAINER_  ;\
    date | tee -a       _TOP_DIR_OF_CONTAINER_ ;\
    echo "installing packages via apt"       | tee -a _TOP_DIR_OF_CONTAINER_  ;\
    export TERM=dumb      ;\
    export NO_COLOR=TRUE  ;\
    #apt-get update ;\
    # ubuntu:   # procps provides uptime cmd
    apt-get -y --quiet install git file wget gzip bash less vim procps ;\
    #apt-get -y --quiet install units libudunits2-dev curl r-cran-rcurl libcurl4 libcurl4-openssl-dev libssl-dev r-cran-httr  r-cran-xml r-cran-xml2 libxml2 rio  java-common javacc javacc4  openjdk-8-jre-headless ;\
    #apt-get -y --quiet install openjdk-14-jre-headless   ;\ 
    # gdal cran install fails, cuz no longer libgdal26, but now libgdal28
    # apt-file search gdal-config
    #apt-get -y --quiet install gdal-bin gdal-data libgdal-dev  libgdal28  ;\
    #apt-get -y --quiet install r-cran-rgdal  ;\
    #apt-get -y --quiet install libgeos-dev   ;\
    # default-jdk is what provide javac !   # -version = 11.0.6
    # ref: https://www.digitalocean.com/community/tutorials/how-to-install-java-with-apt-on-ubuntu-18-04
    # update-alternatives --config java --skip-auto # not needed, but could run interactively to change jdk
    #apt-get -y --quiet install default-jdk r-cran-rjava  ;\ 
    #R CMD javareconf  ;\
    # debian calls it libnode-dev (ubuntu call it libv8-dev?)
    #apt-get -y --quiet install libnode-dev libv8-dev ;\
    cd /     ;\
    echo ""  ;\
    #echo '==================================================================' ;\
    #echo "install for rstudio GUI (Qt)"      | tee -a _TOP_DIR_OF_CONTAINER_  ;\
    #date | tee -a      _TOP_DIR_OF_CONTAINER_                                 ;\
    #echo '==================================================================' ;\
    #-- rstudio dont seems to exist in Debian bullseye/sid :/
    #-- apt-get --quiet install rstudio  ;\
    #xx apt-get -y --quiet install r-cran-rstudioapi libqt5gui5 libqt5network5  libqt5webenginewidgets5 qterminal net-tools ;\
    apt-get -y --quiet install apt-file ;\
    ##?? apt-file update ;\
    mkdir -p Downloads &&  cd Downloads ;\
    #xx wget --quiet https://download1.rstudio.org/desktop/bionic/amd64/rstudio-1.2.5033-amd64.deb  -O rstudio4deb10.deb ;\
    #xx apt-get -y --quiet install ./rstudio4deb10.deb     ;\
    cd /    ;\
    echo "Done installing packages. " | tee -a _TOP_DIR_OF_CONTAINER_     ;\
    date | tee -a      _TOP_DIR_OF_CONTAINER_                      ;\
    echo ""


RUN echo ''  ;\
    echo '==================================================================' ;\
    apt-get -y --quiet install git git-all  ;\
    test -d /opt/gitrepo            || mkdir -p /opt/gitrepo             ;\
    test -d /opt/gitrepo/container  || mkdir -p /opt/gitrepo/container   ;\
    #cd      /opt/gitrepo/container  ;\
    #git clone https://github.com/tin6150/abricate.git                    ;\
    #cd abricate ;\
    #git checkout jgrg ;\
    # git pull ;\
    #git log --oneline --graph --decorate | tee /opt/gitrepo/container/git.lol.OUT.TXT  ;\
    cd / ;\
    echo ""

# add some marker of how Docker was build.
#COPY Dockerfile* /opt/gitrepo/container/
COPY .           /opt/gitrepo/container/

RUN echo ''  ;\
    echo '==================================================================' ;\
    cd    /opt/gitrepo/container/   ;\
    #git  checkout jgrg ;\
    git   branch | tee /opt/gitrepo/container/git.branch.OUT.TXT  ;\
    git   log --oneline --graph --decorate | tee /opt/gitrepo/container/git.lol.OUT.TXT  ;\
    cd    /   ;\
    echo  ""


RUN  cd / \
  && touch _TOP_DIR_OF_CONTAINER_  \
  && echo  "--------" >> _TOP_DIR_OF_CONTAINER_   \
  && TZ=PST8PDT date  >> _TOP_DIR_OF_CONTAINER_   \
  && echo  "Dockerfile      2024.0312"   >> _TOP_DIR_OF_CONTAINER_   \
  && echo  "Grand Finale for Dockerfile"

ENV DBG_APP_VER  "Dockerfile 2024.0312"
ENV DBG_DOCKERFILE Dockerfile__base

ENV TZ America/Los_Angeles 
# ENV TZ likely changed/overwritten by container's /etc/csh.cshrc
# ENV does overwrite parent def of ENV, so can rewrite them as fit.
ENV TEST_DOCKER_ENV     this_env_will_be_avail_when_container_is_run_or_exec
ENV TEST_DOCKER_ENV_2   Can_use_ADD_to_make_ENV_avail_in_build_process
ENV TEST_DOCKER_ENV_REF https://vsupalov.com/docker-arg-env-variable-guide/#setting-env-values

ENV TEST_DOCKER_ENV_YEQ1="Dockerfile ENV assignment as foo=bar, yes use of ="
ENV TEST_DOCKER_ENV_NEQ1 "Dockerfile ENV assignment as foo bar, no  use of =, both seems to work"


# unsure how to append/add to PATH?  likely have to manually rewrite the whole ENV var
#ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/conda/bin
# above is PATH in :integrationU where R 4.1.1 on Debian 11  works on Ubuntu 16.04 path
# below PATH doesn't help resolve Rscript /main.R not finding R problem, but it should not hurt.
#-- ENV PATH=/usr/lib/R/bin/exec:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
#-- unset path to ensure it didn't make Rscript behave worse cuz somehow "test" got masked/lost


ENTRYPOINT [ "/bin/bash" ]


# vim: shiftwidth=4 tabstop=4 formatoptions-=cro nolist nu syntax=on
