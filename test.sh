#!/bin/bash

# Assumes that you have image purescript-docker:0.11.6 available. To
# see which images are available, run `docker images`  Using
# docker 1.12.3, the following seems to work...

# git clone https://github.com/Risto-Stevcev/purescript-docker
# cd purescript-docker
# git checkout 0.11.6
# docker build --tag purescript-docker:0.11.6 .

if [ ! "$(docker ps -q -f name=purescript-docker)" ]; then
    if [ "$(docker ps -aq -f status=exited -f name=purescript-docker)" ]; then
        # cleanup
        docker rm purescript-docker
    fi
    # run your container
    docker run \
    --name purescript-docker \
    -tiv $(pwd):/home/pureuser purescript-docker:0.11.6 \
    bash -c "npm install; pulp --watch test --runtime ./node_modules/phantomjs-prebuilt/bin/phantomjs"

fi
