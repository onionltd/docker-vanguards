FROM alpine:latest

COPY rootfs /

ARG STEM_RELEASE
ARG VANGUARDS_RELEASE

RUN apk add --no-cache git python3 gnupg py-setuptools

RUN gpg --import /usr/local/share/public_keys/*
RUN git clone --branch $STEM_RELEASE --depth 1 https://github.com/torproject/stem
RUN cd stem && git verify-tag $STEM_RELEASE && python3 setup.py install && cd -

RUN git clone --branch $VANGUARDS_RELEASE --depth 1 https://github.com/mikeperry-tor/vanguards /opt/vanguards
RUN cd /opt/vanguards && git verify-tag $VANGUARDS_RELEASE && cd -

RUN addgroup -S -g 107 tor \
    && adduser -S -G tor -u 104 tor

USER tor

WORKDIR /home/tor

ENV CONFIG_FILE=/home/tor/.vanguards.conf

ENTRYPOINT ["python3", "/entrypoint.py"]

CMD python3 /opt/vanguards/src/vanguards.py --config $CONFIG_FILE
