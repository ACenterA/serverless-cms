#
# Docker image build and upload.
#
# == usage ==
#
#   - Launch Dev environment
#     make [dev]
#

export OS_TYPE
include .env
export USER

OS_TYPE := undef

GID := $(shell id -g)
UID := $(shell id -u)
USER := $(shell whoami)

DockerComposeFiles = -f docker-compose.yml
ifdef OS
   RM = del /Q
   FixPath = $(subst /,\,$1)
   OS_TYPE := win
else
   ifeq ($(shell uname -s), Linux)
      RM = rm -f
      OS_TYPE := linux
      FixPath = $1
   else ifeq ($(shell uname -s), Darwin)
      RM = rm -f
      OS_TYPE := mac
      FixPath = $1
   endif
endif


#OS_TYPE := $$(bash ./dev/scripts/os_type.sh)
#RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))

help:
	@printf '======================================================\n'
	@printf '====                Info                          === \n'
	@printf '======================================================\n'
	@printf '\n'
	@printf '[OS] ${OS_TYPE}\n'
	@printf '\n'
	@printf '======================================================\n'
	@printf '====                Setup                         === \n'
	@printf '======================================================\n'
	@printf '\n'
	@printf '[CMD] make setup\n'
	@printf '\n'
	@printf '======================================================\n'
	@printf '====                Application                   === \n'
	@printf '======================================================\n'
	@printf '\n'
	@printf '[>] To Launch Development Environment \n'
	@printf '[CMD] make dev\n'
	@printf '\n'
	@printf '\n'
	@printf '======================================================\n'

reset: down
	@docker volume prune

setup:
	@bash ./setup.sh

prog: # ...
	# ...

.PHONY: logs
logs:
	docker-compose logs -f $(RUN_ARGS)

exec:
	docker-compose exec $(RUN_ARGS)

build:
	docker-compose $(call DockerComposeFiles) build


# Launch local developmentt using Docker and the MySQL dockerized
build:
	@printf '[>] Building the docker containers\n'
	@echo docker-compose -f docker-compose.yml build --build-arg USER=${USER} --build-arg UID=$(UID) --build-arg GID=$(GID) --build-arg PASSWORD=${PASSWORD} --build-arg OS_TYPE=${OS_TYPE}
	docker-compose -f docker-compose.yml build --build-arg USER=${USER} --build-arg UID=$(UID) --build-arg GID=$(GID) --build-arg PASSWORD=${PASSWORD} --build-arg OS_TYPE=${OS_TYPE}

dev: build
	@printf '[>] Provisioning the docker containers\n'
	@docker-compose -f docker-compose.yml up -d
