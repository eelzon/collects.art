var cors = require('cors')({ origin: true });
var functions = require('firebase-functions');
var admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);

// Create and Deploy Your First Cloud Functions
// https://firebase.google.com/docs/functions/write-firebase-functions
exports.template = functions.https.onRequest((req, res) => {
  cors(req, res, () => {
    getValue(`/collects/${req.query.timestamp}`).then(function(collect) {
      getValue(`/templates/template${collect.template}/background`).then(function(background) {
        var template = require(`./templates/template${collect.template}`);
        var entries = arrayFromEntries(collect.entries);
        var html = template(collect.title, entries, background);
        res.send(html);
      });
    });
  });
});

function arrayFromEntries(dict) {
  return Object.keys(dict || {}).reduce((entries, key) => {
    var entry = dict[key];
    if (entry.title || entry.image) {
      entries.push(entry);
    }
    return entries;
  }, []);
}

function getValue(path) {
  return admin.database().ref(path).once('value').then(function(snapshot) {
    return snapshot.exportVal();
  });
}
