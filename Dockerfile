FROM node:14-alpine AS development

#Install package
#RUN apk add --no-cache alpine-sdk && \
#    apk add libffi-dev openssl-dev && \
#    apk add --no-cache python build-base linux-headers

RUN apk add --no-cache libffi-dev openssl-dev python build-base \
        && rm -rf /var/cache/apk/*

RUN mkdir -p /app
WORKDIR /app

COPY package.json ./
COPY yarn.lock ./
RUN yarn --production
RUN yarn
ADD ./ /app

ENV DOCKERIZE_VERSION v0.6.1
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz

RUN yarn build


FROM node:14-alpine AS production


RUN mkdir -p /app
WORKDIR /app

COPY --from=development /app /app

ENV PORT 4000
ENV HOST 0.0.0.0

ENV DOCKERIZE_VERSION v0.6.1
RUN tar -C /usr/local/bin -xzvf dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz

ENTRYPOINT ["yarn", "start:prod"]
