FROM ghcr.io/cirruslabs/flutter as flutter

WORKDIR /app

ARG EMULATOR_HOST=""

ENV ENV_EMULATOR_HOST $EMULATOR_HOST

COPY /app ./

RUN flutter pub get

RUN flutter build web --release --dart-define=EMULATOR_HOST=$ENV_EMULATOR_HOST --no-tree-shake-icons

# --

FROM node:alpine as functions

WORKDIR /app

COPY ./functions /app/functions

WORKDIR /app/functions

RUN npm install

RUN npm run build

# --

FROM node:alpine

WORKDIR /app

COPY ./.firebaserc ./

COPY ./firebase.json ./

COPY ./storage.rules ./

COPY --from=flutter /app/build/web ./app/build/web

COPY --from=functions /app/functions ./functions

RUN apk --no-cache add curl

RUN apk update && apk add openjdk11

RUN npm i -g firebase-tools

VOLUME [ "/app/data" ]
 
EXPOSE 3000 4000 4400 4500 5000 5001 8001 8080 8085 9000 9099 9199

CMD ["firebase", "emulators:start"]

#  --import ./app/data --export-on-exit ./app/data

