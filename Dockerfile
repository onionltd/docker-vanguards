FROM alpine:latest

COPY rootfs /

ARG STEM_RELEASE
ARG VANGUARDS_RELEASE

RUN apk add --no-cache git python3 gnupg py-setuptools \
    && gpg --import /usr/local/share/public_keys/* \
    && git clone --branch $STEM_RELEASE --depth 1 https://github.com/torproject/stem \
    && cd stem \
    && git verify-tag $STEM_RELEASE \
    && python3 setup.py install \
    && cd - \
    && git clone --branch $VANGUARDS_RELEASE --depth 1 https://github.com/mikeperry-tor/vanguards /opt/vanguards \
    && cd /opt/vanguards \
    && git verify-tag $VANGUARDS_RELEASE \
    && cd -

RUN addgroup -S -g 107 tor \
    && adduser -S -G tor -u 104 tor

RUN mkdir -p /var/lib/tor/hidden_service \
    && chown tor:tor /var/lib/tor/hidden_service

VOLUME  ["/var/lib/tor/hidden_service/"]

USER tor

WORKDIR /home/tor

ENV CONFIG_FILE=/home/tor/.vanguards.conf

ENTRYPOINT ["python3", "/entrypoint.py"]

CMD python3 /opt/vanguards/src/vanguards.py --config $CONFIG_FILE
