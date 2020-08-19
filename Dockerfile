ARG BUILD_FROM="homeassistant/amd64-base"
FROM $BUILD_FROM

ENV LANG C.UTF-8

# Install Telldus library for TellStick (using same approach as in hassio docker installation)
RUN apk add --no-cache \
        confuse \
        libftdi1 \
        libstdc++ \
        socat \
        usbip-utils \
    && apk add --no-cache --virtual .build-dependencies \
        argp-standalone \
        build-base \
        cmake \
        confuse-dev \
        doxygen \
        gcc \
        git \
        libftdi1-dev \
    && ln -s /usr/include/libftdi1/ftdi.h /usr/include/ftdi.h \
    && mkdir -p /usr/src \
    && cd /usr/src \
    && git clone -b master --depth 1 https://github.com/telldus/telldus \
    && cd telldus/telldus-core \
    && sed -i \
        "/\<sys\/socket.h\>/a \#include \<sys\/select.h\>" \
        common/Socket_unix.cpp \
    && cmake . \
        -DBUILD_LIBTELLDUS-CORE=ON \
        -DBUILD_TDADMIN=OFF \
        -DBUILD_TDTOOL=ON \
        -DGENERATE_MAN=OFF \
        -DFORCE_COMPILE_FROM_TRUNK=ON \
        -DFTDI_LIBRARY=/usr/lib/libftdi1.so \
    && make \
    && make install \
    && apk del .build-dependencies \
    && rm -rf /usr/src/telldus

# Copy data for add-on
COPY data/run.sh /

RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
