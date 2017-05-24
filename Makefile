ORG=fasten
NAME=terraforming
CONTAINER=$(ORG)/$(NAME)
SHELL=/bin/bash

all: build

build:
	@mkdir -p ./data &&\
		docker build -t $(CONTAINER) --rm=true .

# run on container and output to host tee
dump: build
	@docker run \
    --user 1001:1001 \
		-v ${PWD}/data:/data:rw \
    -e AWS_ACCESS_KEY_ID=$$AWS_ACCESS_KEY_ID \
    -e AWS_REGION=$$AWS_REGION \
    -e AWS_SECRET_ACCESS_KEY=$$AWS_SECRET_ACCESS_KEY \
    --name $(NAME) -it --rm $(CONTAINER) \
		$(SHELL) export.sh 2>&1 \
		| tee ./data/export.log

test: build
	@docker run \
    --user 1001:1001 \
		-v ${PWD}/data:/data:rw \
		-e AWS_ACCESS_KEY_ID=$$AWS_ACCESS_KEY_ID \
		-e AWS_REGION=$$AWS_REGION \
		-e AWS_SECRET_ACCESS_KEY=$$AWS_SECRET_ACCESS_KEY \
		--name $(NAME) -it --rm $(CONTAINER) $(SHELL)

run:
	@docker run \
		-e AWS_ACCESS_KEY_ID=$$AWS_ACCESS_KEY_ID \
		-e AWS_REGION=$$AWS_REGION \
		-e AWS_SECRET_ACCESS_KEY=$$AWS_SECRET_ACCESS_KEY \
		--name $(NAME) -d $(CONTAINER)
logs:
	@docker logs -f $(NAME)
clean:
	@docker stop $(NAME); docker rm $(NAME)
debug:
	@docker exec -it -u root $(CONTAINER) $(SHELL)
purge:
	@docker rm $$(docker ps -aq); docker rmi $$(docker images -f "dangling=true" -q); docker rmi \
		$(CONTAINER):latest
compose-build:
	@docker-compose build
compose-config:
	@docker-compose config
compose-logs:
	@docker-compose logs -f
compose-run:
	@docker-compose run --service-ports
compose-up:
	@docker-compose up -d --build
compose-up-force:
	@docker-compose up -d --build --force-recreate
compose-down:
	@docker-compose down
compose-clean:	compose-down
	@docker-compose rm -avf
compose-purge:	compose-clean
	@docker-compose down --rmi all
compose-purge-down:
	@docker-compose down --rmi all -v --remove-orphans

