DOCKER = sudo docker
MKDIR = sudo mkdir -p
CP = sudo cp
RUN = run --rm
BRIDGE_NETWORK = mongo-network

BACKEND_TAG = 1.0.0
APP_TAG = 1.0.0

MONGO_DATA_VOLUME = /home/mongo/data
MONGO_INIT_VOLUME = /home/mongo/docker-entrypoint-initdb.d
MONGO_INIT_FILE = Mongo/init.js

HOST_UPLOAD_VOLUME = /home/public/upload

save:
		@echo
		@echo "Save all docker images"
		$(DOCKER) save -o 2019ncku-backend.$(BACKEND_TAG).tar docker-nodejs-2019ncku-backend:$(BACKEND_TAG)
		$(DOCKER) save -o 2019ncku-app.$(APP_TAG).tar docker-nodejs-2019ncku:$(APP_TAG)

build-all: app-build backend-build


run-all: RUN += -d
run-all: run-mongo run-backend run-app

app-build:
		@echo
		@echo "Build a app image"
		@echo "cd App"
		@echo "$(DOCKER) build -t docker-nodejs-2019ncku:$(APP_TAG) -f Dockerfile-nodejs-2019ncku ."

backend-build:
		@echo
		@echo "Build a backend image"
		@echo "cd Backend"
		@echo "$(DOCKER) build -t docker-nodejs-2019ncku-backend:$(BACKEND_TAG) -f Dockerfile-nodejs-2019ncku-backend ."
		
init-network:
		@echo
		@echo "Create a bridge network"
		$(DOCKER) network create $(BRIDGE_NETWORK)

run-mongo:
		@echo
		@echo "Start a mongo:3.6-xenial server"
		$(MKDIR) $(MONGO_DATA_VOLUME)
		$(MKDIR) $(MONGO_INIT_VOLUME)
		$(CP)	$(MONGO_INIT_FILE) $(MONGO_INIT_VOLUME)
		$(DOCKER) $(RUN) --name mongo --network $(BRIDGE_NETWORK) -p 27017:27017 -v $(MONGO_DATA_VOLUME):/data/db -v $(MONGO_INIT_VOLUME):/docker-entrypoint-initdb.d mongo:3.6-xenial

run-backend:
		@echo
		@echo "Run a backend server"
		$(MKDIR) $(HOST_UPLOAD_VOLUME)
		$(DOCKER) $(RUN) --name backend --network $(BRIDGE_NETWORK) -p 14004:14004 -v $(HOST_UPLOAD_VOLUME):/home/Backend/upload docker-nodejs-2019ncku-backend:$(BACKEND_TAG)

run-app:
		@echo
		@echo "Run a app for messenger"
		$(DOCKER) $(RUN) --name app --network $(BRIDGE_NETWORK) -p 19006:19006 docker-nodejs-2019ncku:$(APP_TAG)
