FROM node:8-alpine as build
ARG NODE_ENV=production
ENV NODE_ENV=$NODE_ENV

ARG GIT_TAG
ENV GIT_TAG=$GIT_TAG
ARG GIT_HASH
ENV GIT_HASH=$GIT_HASH

RUN apk add python make git g++
RUN npm install -g bower

WORKDIR /usr/src/app

COPY package.json ./
COPY bower.json ./

RUN bower install --allow-root
RUN npm install

COPY ./ ./

RUN npm run build

#

FROM nginx:alpine

COPY --from=build /usr/src/app/public/ /usr/share/nginx/html/

RUN for i in `find /usr/share/nginx/html/ -type f -name '*.js' -o -name '*.css' -o -name '*.html'`; do echo $i; gzip -c -9 $i > $i.gz;  done;

COPY nginx /etc/nginx

#RUN export VERSION=$(cat /usr/share/nginx/html/version); \
#  sh -c "envsubst \"`env | awk -F = '{printf \" \\\\$%s\", $1}'`\" < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf";

EXPOSE 80
