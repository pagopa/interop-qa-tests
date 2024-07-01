use read-model;

var dbName=db.getName();
console.log(`Using db ${dbName}.`);

var collections=db.getCollectionNames();
console.log(`Collections found: ${collections}`);

for (let coll of collections) {
    db.getCollection(coll).deleteMany({});
}


exit;