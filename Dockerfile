FROM eafxx/alpine-base
LABEL maintainer="https://github.com/elmerfdz"
ARG VERSION
RUN apk --no-cache add curl jq libsass wget tzdata libsass
RUN curl -L -s https://assets.statping.com/sass -o /usr/local/bin/sass && \
    chmod +x /usr/local/bin/sass
ENV IS_DOCKER=true
ENV STATPING_DIR=/app
ENV PORT=8080
WORKDIR /app

RUN mkdir -p /install  && \
    VERSION=$(curl -s https://api.github.com/repos/hunterlong/statping/releases/latest | jq -r ".tag_name") && \
    wget https://github.com/hunterlong/statping/releases/download/$VERSION/statping-linux-alpine.tar.gz -P "/install" -q --show-progress && \
    tar -xvzf /install/statping-linux-alpine.tar.gz && \
    chmod +x statping && \
    mv statping /usr/local/bin/statping 

COPY root/ /

VOLUME /app
EXPOSE $PORT

HEALTHCHECK --interval=60s --timeout=10s --retries=3 CMD curl -s "http://localhost:$PORT/health" | jq -r -e ".online==true"