#!/bin/bash

# docs as code using Structurizr
docker run --name struct81 -it --rm -p 8081:8080 \
    -v ${PWD}:/usr/local/structurizr \
    structurizr/lite
    