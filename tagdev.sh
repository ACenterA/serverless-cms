#!/bin/bash

export $(cat .env | grep COMPOSE_PROJECT_NAME= | grep -v '^#' | head -n 1)
docker tag ${COMPOSE_PROJECT_NAME}_severless-cms-base:latest acentera/dev:severless-cms-base-v0.0.1
docker push acentera/dev:severless-cms-base-v0.0.1
