#!/bin/bash

# Assumes that you have image purescript-docker:0.10.5 available.  To get image...

# git clone github.com/gyeh/purescript-docker
# cd purescript-docker
# git checkout 0.10.5
# docker build --tag purescript-docker:0.10.5 .

if [ ! "$(docker ps -q -f name=purescript-docker)" ]; then
    if [ "$(docker ps -aq -f status=exited -f name=purescript-docker)" ]; then
        # cleanup
        docker rm purescript-docker
    fi
    # run your container
    docker run \
    --name purescript-docker \
    -tiv $(pwd):/home/pureuser/src purescript-docker:0.10.5 \
    bash -c "cd ~/src;npm install; pulp --watch test --runtime ./node_modules/phantomjs-prebuilt/bin/phantomjs"

fi
