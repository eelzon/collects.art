var functions = require('firebase-functions');
var cors = require('cors')({ origin: true });
var Mustache = require('mustache');

// Create and Deploy Your First Cloud Functions
// https://firebase.google.com/docs/functions/write-firebase-functions
exports.template = functions.https.onRequest((req, res) => {
  cors(req, res, () => {
    var collect = JSON.parse(req.body);

    var view = {
      title: collect.title,
      calc: function () {
        return 2 + 4;
      }
    };

    var template = Mustache.render(`
      <h1>{{title}}</h1>
      <!-- template data -->
    `, view);

    Object.keys(collect.entries).forEach((timestamp) => {
      var entry = collect.entries[timestamp];
      template = template + `
        <h4>${entry.title}</h4>
        <div><img src="${entry.image}" /></div>
      `;
    });

    res.send(template);
  });
});
