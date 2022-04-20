# ----------------
# Make help script
# ----------------

# Output colors
GREEN  := $(shell tput -Txterm setaf 2)
WHITE  := $(shell tput -Txterm setaf 7)
YELLOW := $(shell tput -Txterm setaf 3)
RESET  := $(shell tput -Txterm sgr0)

PROJECT_ROOT ?= /var/www/html/


#
# Dev Environment settings
#
-include .env

#
# Dev Operations
#

default: up

up: ##@docker Start containers and display status.
	@echo "Starting up containers for $(PROJECT_NAME)..."
	docker-compose up -d --remove-orphans
	docker-compose ps
	@echo "Site at $(PROJECT_BASE_URL)"

build: ##@docker Start containers and display status.
	@echo "Starting up containers for $(PROJECT_NAME)..."
	docker-compose up --build -d --remove-orphans
	docker-compose ps

install: ##@dev-environment Configure development environment.
	make down
	make build
	cp docker-config/parameters.yml html/app/config/parameters.yml
	make fix-permission
	make composer-install
	make create-database
	make update-database

down: stop

fix-permission:
	@docker exec -it  $(PROJECT_NAME)_php-apache chmod 777 -R var/

create-database:
	@docker exec -it  $(PROJECT_NAME)_php-apache bash create-databases.sh -y

update-database:
	@docker exec -it  $(PROJECT_NAME)_php-apache php bin/console doctrine:schema:update --force

stop: ##@docker Stop and remove containers.
	@echo "Stopping containers for $(PROJECT_NAME)..."
	@docker-compose stop

prune: ##@docker Remove containers for project.
	@echo "Removing containers for $(PROJECT_NAME)..."
	@docker-compose down -v

ps: ##@docker List containers.
	@docker ps --filter name='$(PROJECT_NAME)*'

shell-php: ##@docker Shell into the container. Specify container name.
	@docker exec -it $(PROJECT_NAME)_php-apache bash

shell-database: ##@docker Shell into the container. Specify container name.
	@docker exec -it database bash

logs: ##@docker Display log.
	docker-compose logs

composer-update: ##@dev-environment Run composer update.
	docker-compose exec -T php composer update -n --prefer-dist -vvv -d $(PROJECT_ROOT)

composer-install: ##@dev-environment Run composer install
	docker-compose exec -T php composer install -n --prefer-dist -vvv -d $(PROJECT_ROOT)
