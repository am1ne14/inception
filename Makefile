include srcs/.env

COMPOSE_FILE = srcs/docker-compose.yml
ENV_FILE = srcs/.env
COMPOSE = docker compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE)

all: up

init_dirs:
	mkdir -p $(DB_VOLUME_PATH) $(WP_VOLUME_PATH)

up: init_dirs
	$(COMPOSE) up --build -d

build: init_dirs
	$(COMPOSE) build

down:
	$(COMPOSE) down

start:
	$(COMPOSE) start

stop:
	$(COMPOSE) stop

restart: down up

logs:
	$(COMPOSE) logs

ps:
	$(COMPOSE) ps

clean:
	$(COMPOSE) down --remove-orphans

fclean:
	$(COMPOSE) down --rmi all --volumes --remove-orphans

re: fclean up

.PHONY: all init_dirs up build down start stop restart logs ps clean fclean re
