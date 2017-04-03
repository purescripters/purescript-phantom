#!/bin/bash

# Assumes that you have image purescript-docker:0.11.0 available.  Using
# docker 1.12.3, the following seems to work...

# git clone https://github.com/Risto-Stevcev/purescript-docker
# cd purescript-docker
# git checkout 0.11.0
# docker build --tag purescript-docker:0.11.0 .

if [ ! "$(docker ps -q -f name=purescript-docker)" ]; then
    if [ "$(docker ps -aq -f status=exited -f name=purescript-docker)" ]; then
        # cleanup
        docker rm purescript-docker
    fi
    # run your container
    docker run \
    --name purescript-docker \
    -tiv $(pwd):/home/pureuser purescript-docker:0.11.0 \
    bash -c "npm install; pulp --watch test --runtime ./node_modules/phantomjs-prebuilt/bin/phantomjs"

fi
