FROM alpine:latest

RUN apk add --no-cache caddy bash curl

WORKDIR /web
COPY . /web

ENTRYPOINT ["./start-webserver.sh"]
