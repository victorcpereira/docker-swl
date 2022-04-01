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
	make composer-install
	@docker exec -it  $(PROJECT_NAME)_php-apache bash create-databases.sh


#import-db: ##@dev-environment Import locally cached copy of `database.sql` to project dir.
#	@echo "Dropping old database for $(PROJECT_NAME)..."
#	docker exec --workdir $(WORKDIR) $(shell docker ps --filter name='$(PROJECT_NAME)_php' --format "{{ .ID }}") drush sql-drop -y
#	@echo "Importing database for $(PROJECT_NAME)..."
#	pv build/db/*.sql | docker exec -i $(PROJECT_NAME)_mariadb mysql -u$(DB_USER) -p$(DB_PASSWORD) $(DB_NAME)

#prep-site: ##@docker Prepare website.
#	make cim
#	make updb
#	make cr

down: stop

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
