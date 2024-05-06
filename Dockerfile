ARG SYNCREPL_CLIENT_QUALIFIER=:0.95.1
FROM ghcr.io/gwilliam-ucar-edu/syncrepl-client${SYNCREPL_CLIENT_QUALIFIER}

USER root

ARG PACKAGE=ldap-sam-syncd
ARG IMAGE=ghcr.io/ncar/ldap-sam-syncd
ARG IMAGE_VERSION=snapshot
ARG BRANCH=main
ARG PACKAGE_DIR=/usr/local/ldap-sam-syncd

#
# Define the timezone via the TZ build arg.
#
ARG TZ=America/Denver

#
# We define a default non-root user to run the container as. This can be
# used for testing, etc.
#
ARG SAMUSER=sam-tomcat
ARG SAMUSERID=303
ARG SAMGROUP=sam-tomcat
ARG SAMGROUPID=303

ENV TZ=${TZ} \
    PACKAGE=ldap-sam-syncd \
    PACKAGE_DIR=/usr/local/ldap-sam-syncd \
    SAMUSER=${SAMUSER} \
    SAMUSERID=${SAMUSERID} \
    SAMGROUP=${SAMGROUP} \
    SAMGROUPID=${SAMGROUPID} \
    PYTHONPYCACHEPREFIX=/tmp \
    PYTHONPATH=${PACKAGE_DIR}/src

RUN mkdir -p ${PACKAGE_DIR} \
             ${PACKAGE_DIR}/bin \
             ${PACKAGE_DIR}/src \
             ${PACKAGE_DIR}/test

COPY config.ini pip-packages \
              ${PACKAGE_DIR}/
COPY bin      ${PACKAGE_DIR}/bin/
COPY src      ${PACKAGE_DIR}/src
COPY tests    ${PACKAGE_DIR}/tests/
COPY runtests ${PACKAGE_DIR}/

RUN pip install --upgrade pip
RUN while read pkg ; do \
        pip install --root-user-action=ignore ${pkg} ; \
    done < ${PACKAGE_DIR}/pip-packages

WORKDIR ${PACKAGE_DIR}

#
# Set up timezone.
# Set up non-root user.
#
RUN set -e ; \
    rm -f /etc/localtime ; \
    ln -s /usr/share/zoneinfo/${TZ} /etc/localtime ; \
    cp /etc/localtime /usr/local/etc/localtime ; \
    echo "${TZ}" >/usr/local/etc/TZ ; \
    POSIX_TZ=`tr '\000' '\n' </etc/localtime | tail -1 | \
                   sed 's/^\([^,]*\).*/\1    /'` ; \
    echo ${POSIX_TZ} > /usr/local/etc/POSIX_TZ ; \
    addgroup --gid $SAMUSERID $SAMUSER ; \
    adduser --disabled-password \
            --uid $SAMUSERID \
            --gid $SAMGROUPID \
            --gecos "SAM package user" \
            --home /home/$SAMUSER \
            --shell /bin/bash \
            $SAMUSER ; \
    chown -R $SAMUSERID:$SAMGROUPID ${PACKAGE_DIR} ; \
    cd ${PACKAGE_DIR}/bin ; \
    for prog in * ; do \
        ln -s ${PACKAGE_DIR}/bin/${prog} /usr/local/bin/${prog} ; \
    done

USER $SAMUSER

#RUN cd ${PACKAGE_DIR}
#RUN    /usr/local/sweet/bin/gendoc -v >gendoc/.log 2>&1 ; \
#    chown -R $MYSQL_USER:$MYSQL_GROUP gendoc


#CMD [ "python", "/usr/local/ldap-sam-syncd/bin/lsyncd" ]
CMD [ "/bin/bash" ]
