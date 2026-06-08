include srcs/.env

COMPOSE_FILE = srcs/docker-compose.yml
ENV_FILE = srcs/.env
COMPOSE = docker compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE)
SECRETS_DIR = secrets
SECRET_FILES = $(SECRETS_DIR)/db_root_password.txt $(SECRETS_DIR)/db_password.txt $(SECRETS_DIR)/credentials.txt

all: up

init_dirs:
	mkdir -p $(DB_VOLUME_PATH) $(WP_VOLUME_PATH)

check_secrets:
	@for file in $(SECRET_FILES); do \
		if [ ! -f "$$file" ]; then \
			echo "Missing required secret file: $$file" >&2; \
			echo "Create local secret files in ./secrets before running this target." >&2; \
			exit 1; \
		fi; \
		if [ ! -s "$$file" ]; then \
			echo "Secret file must not be empty: $$file" >&2; \
			exit 1; \
		fi; \
	done

up: init_dirs check_secrets
	$(COMPOSE) up --build -d

build: init_dirs
	$(COMPOSE) build

down:
	$(COMPOSE) down

start: check_secrets
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

.PHONY: all init_dirs check_secrets up build down start stop restart logs ps clean fclean re
