FROM alpine:latest

RUN apk add --no-cache nodejs npm bash curl

WORKDIR /app
COPY . /app

RUN npm install

ENTRYPOINT ["node", "main.js"]
