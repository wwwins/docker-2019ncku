# docker-2019ncku
Dockfile for my 2019ncku project

## Installation
Install docker

### Setup mongodb user and pwd
```
let DB_NAME = 'Sinopac_2019ncku';
let DB_USER = 'XX';
let DB_PWD = 'XXXXX';
```

### Setup Backend config.js
```
// mongodb
mongoUrl: 'mongodb://XX:XXXXX@mongo:27017/',
mongoDbName: 'Sinopac_2019ncku',
// public URL
serverUrl: 'https://4testbackend.isobar.com.tw',
frontUrl: 'https://4testcampaign.isobar.com.tw',
```

### Setup App .env
```
// public URL
URL = https://4testcampaign.isobar.com.tw
// mongodb
MONGO_URI = mongodb://XX:XXXXX@mongo:27017/Sinopac_2019ncku
```

## Usage
### For the first time
```
make init-network
```
### Startup
```
make run-all
```
### Debug
```
make run-mongo
make run-backend
make run-app
```

