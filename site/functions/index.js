var functions = require('firebase-functions');
var cors = require('cors')({ origin: true });
var Handlebars = require('handlebars');

var admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);

// Create and Deploy Your First Cloud Functions
// https://firebase.google.com/docs/functions/write-firebase-functions
exports.template = functions.https.onRequest((req, res) => {
  cors(req, res, () => {
    admin.database().ref('/collects/' + req.query.timestamp).once('value').then(function(snapshot) {
      var collect = snapshot.exportVal();
      var html = getTemplate(collect);
      res.send(html);
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

function getTemplate(collect) {
  var templates = [
    require('./templates/template1'),
    require('./templates/template2'),
    require('./templates/template3'),
    require('./templates/template4'),
    require('./templates/template5'),
    require('./templates/template6'),
    require('./templates/template7'),
    require('./templates/template8'),
    require('./templates/template9'),
    require('./templates/template10')
  ]
  var entries = arrayFromEntries(collect.entries);
  return templates[collect.template - 1](collect.title, entries);
}
