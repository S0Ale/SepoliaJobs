FROM alpine:latest

RUN apk add --no-cache nodejs npm bash curl

WORKDIR /contract
COPY . /contract

RUN npm install

ENTRYPOINT ["start.sh"]
