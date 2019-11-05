//
// Copyright 2019 isobar. All Rights Reserved.
//
// Set up DB_NAME/DB_USER/DB_PWD
//

let DB_NAME = 'Sinopac_2019ncku';
let DB_USER = 'XX';
let DB_PWD = 'XXXXX';

db = db.getSiblingDB(DB_NAME);

db.createCollection("Error");
db.createCollection("Feed");
db.createCollection("User");

db.createUser({user:DB_USER, pwd:DB_PWD, roles:[{role:"dbOwner", db:DB_NAME}]});

