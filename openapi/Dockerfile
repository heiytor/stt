FROM node:20.12.2-alpine3.19 AS base

RUN apk add --no-cache curl inotify-tools
COPY openapi/docker-entrypoint /

RUN npm install -g @redocly/cli@1.0.0-beta.100

WORKDIR /openapi

COPY openapi/package*.json ./
RUN npm install

COPY openapi/. ./

ENTRYPOINT ["/docker-entrypoint"]
