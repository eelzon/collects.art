var functions = require('firebase-functions');
var cors = require('cors')({ origin: true });
var Handlebars = require('handlebars');

// Create and Deploy Your First Cloud Functions
// https://firebase.google.com/docs/functions/write-firebase-functions
exports.template = functions.https.onRequest((req, res) => {
  cors(req, res, () => {
    var collect = JSON.parse(req.body);
    res.send(template1(collect));
  });
});

function template1(collect) {
  var html = `
    <style type="text/css">
      h1 {
        text-align:center;
      }
      body {
          background-image: url("http://meryn.ru/rhizome/harlequin.png");
      }
    </style>
    <h1>{{collect.title}}</h1>
    <hr>
    {{#each collect.entries}}
      {{#ifThird @index}}
        <p style="width: 50%; text-align: center; margin: 0 auto;">{{this.title}}</p>
        <hr>
      {{else}}
        {{#ifSecond @index}}
          <p style="width: 50%; text-align: left; margin-right: auto;">{{this.title}}</p>
          <hr>
        {{else}}
          <p style="width: 50%; text-align: right; margin-left: auto;">{{this.title}}</p>
          <hr>
        {{/ifSecond}}
      {{/ifThird}}
    {{/each}}
  `;

  var template = Handlebars.compile(html);

  Handlebars.registerHelper('ifThird', function (index, options) {
    if ((index + 1) % 3 == 0){
      return options.fn(this);
    } else {
      return options.inverse(this);
    }
  });

  Handlebars.registerHelper('ifSecond', function (index, options) {
    if ((index + 1) % 2 == 0){
      return options.fn(this);
    } else {
      return options.inverse(this);
    }
  });

  return template({ collect });
}
