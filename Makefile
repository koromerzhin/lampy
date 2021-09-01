include make/general/Makefile
STACK         := lampy
NETWORK       := proxylampy serverlampy
include make/docker/Makefile

SUPPORTED_COMMANDS := linter setbdd
SUPPORTS_MAKE_ARGS := $(findstring $(firstword $(MAKECMDGOALS)), $(SUPPORTED_COMMANDS))
ifneq "$(SUPPORTS_MAKE_ARGS)" ""
  COMMAND_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  $(eval $(COMMAND_ARGS):;@:)
endif

GREEN := \033[0;32m
RED := \033[0;31m
YELLOW := \033[0;33m
NC := \033[0m
NEED := ${GREEN}%-20s${NC}: %s\n
MISSING :=${RED}ARGUMENT missing${NC}\n
ARGUMENTS := make ${PURPLE}%s${NC} ${YELLOW}ARGUMENT${NC}\n

DOCKER_EXECMARIADB := @docker exec $(STACK)_mariadb.1.$$(docker service ps -f 'name=$(STACK)_mariadb' $(STACK)_mariadb -q --no-trunc | head -n1)

install: node_modules ## Installation application
	@make docker create-network
	@make docker deploy

MARIADB_PASSWORD := $(shell more docker-compose.yml | grep MYSQL_ROOT_PASSWORD: | sort --unique | sed -e "s/^.*MYSQL_ROOT_PASSWORD:[[:space:]]//")

define mariadb_newbdd
	@echo -e "mysql -e \"CREATE DATABASE IF NOT EXISTS \`$(2)\`\" -p${MARIADB_PASSWORD}\n"
	$(DOCKER_EXECMARIADB) mysql -e "CREATE DATABASE IF NOT EXISTS \`$(2)\`" -p${MARIADB_PASSWORD}
	@echo -e "mysql -e \"CREATE USER IF NOT EXISTS '${1}'@'%' IDENTIFIED BY '${3}';\" -p${MARIADB_PASSWORD}\n"
	$(DOCKER_EXECMARIADB) mysql -e "CREATE USER IF NOT EXISTS '${1}'@'%' IDENTIFIED BY '${3}';" -p${MARIADB_PASSWORD}
	@echo -e "mysql -e \"GRANT ALL PRIVILEGES ON \`${2}\`.* TO '${1}'@'%';\" -p${MARIADB_PASSWORD}\n"
	$(DOCKER_EXECMARIADB) mysql -e "GRANT ALL PRIVILEGES ON \`${2}\`.* TO '${1}'@'%';" -p${MARIADB_PASSWORD}
endef

linter: ### Scripts Linter
ifeq ($(COMMAND_ARGS),all)
	@make linter readme -i
else ifeq ($(COMMAND_ARGS),readme)
	@npm run linter-markdown README.md
else
	@printf "${MISSING}"
	@echo "---"
	@printf "${ARGUMENTS}" linter
	@echo "---"
	@printf "${NEED}" "all" "Launch all linter"
	@printf "${NEED}" "readme" "linter README.md"
endif

.PHONY: setbdd
setbdd:
ifeq ($(USERNAME),)
	@echo "Variable USERNAME not settings"
else ifeq ($(BDD),)
	@echo "Variable BDD not settings"
else ifeq ($(PASSWORD),)
	@echo "Variable PASSWORD not settings"
else
	$(call mariadb_newbdd,$(USERNAME),$(BDD),$(PASSWORD))
endif