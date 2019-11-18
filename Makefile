SYS := $(shell uname || echo Windows)
ifeq ($(SYS), Windows)
DOCKER = docker
MKDIR = mkdir
CP = xcopy /Y
RUN = run --rm

MONGO_DATA_VOLUME = mongodata
MONGO_INIT_VOLUME = $(PUBLIC)\docker-entrypoint-initdb.d
MONGO_INIT_FILE = Mongo\init.js
HOST_UPLOAD_VOLUME = $(PUBLIC)\upload
else
DOCKER = sudo docker
MKDIR = sudo mkdir -p
CP = sudo cp
RUN = run --rm

MONGO_DATA_VOLUME = /home/mongo/data
MONGO_INIT_VOLUME = /home/mongo/docker-entrypoint-initdb.d
MONGO_INIT_FILE = Mongo/init.js
HOST_UPLOAD_VOLUME = /home/public/upload
endif

BRIDGE_NETWORK = mongo-network

# App config
#APP_URL = https://4sinopaccampaign.isobar.com.tw
#APP_URL = https://10.65.16.97:19007
APP_URL = http://10.65.16.97:19006

# Backend config
BACKEND_SERVER_URL = http://10.65.16.97:14004
BACKEND_FRONT_URL = http://10.65.16.97:14004

# Tag
BACKEND_TAG = 1.1.0
APP_TAG = 1.1.0


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

init-volume:
		@echo
		@echo "Create a volume for Windows"
ifeq ($(SYS), Windows)
		$(DOCKER) volume create $(MONGO_DATA_VOLUME)
endif

run-mongo:
		@echo
		@echo "Start a mongo:3.6-xenial server"
ifeq ($(SYS), Windows)
		if not exist $(MONGO_INIT_VOLUME) $(MKDIR) $(MONGO_INIT_VOLUME)
else
		$(MKDIR) $(MONGO_DATA_VOLUME)
		$(MKDIR) $(MONGO_INIT_VOLUME)
endif
		$(CP)	$(MONGO_INIT_FILE) $(MONGO_INIT_VOLUME)
		$(DOCKER) $(RUN) --name mongo --network $(BRIDGE_NETWORK) -p 27017:27017 -v $(MONGO_DATA_VOLUME):/data/db -v $(MONGO_INIT_VOLUME):/docker-entrypoint-initdb.d mongo:3.6-xenial

run-backend:
		@echo
		@echo "Run a backend server"
ifeq ($(SYS), Windows)
		if not exist $(HOST_UPLOAD_VOLUME) $(MKDIR) $(HOST_UPLOAD_VOLUME)
else
		$(MKDIR) $(HOST_UPLOAD_VOLUME)
endif
		$(DOCKER) $(RUN) --name backend --network $(BRIDGE_NETWORK) -p 14004:14004 -v $(HOST_UPLOAD_VOLUME):/home/Backend/upload -e serverUrl=$(BACKEND_SERVER_URL) -e frontUrl=$(BACKEND_FRONT_URL) docker-nodejs-2019ncku-backend:$(BACKEND_TAG)

run-app:
		@echo
		@echo "Run a app for messenger"
		$(DOCKER) $(RUN) --name app --network $(BRIDGE_NETWORK) -p 19006:19006 -e URL=$(APP_URL) docker-nodejs-2019ncku:$(APP_TAG)
