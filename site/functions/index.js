var functions = require('firebase-functions');
var cors = require('cors')({ origin: true });
var Handlebars = require('handlebars');

// Create and Deploy Your First Cloud Functions
// https://firebase.google.com/docs/functions/write-firebase-functions
exports.template = functions.https.onRequest((req, res) => {
  cors(req, res, () => {
    var collect = JSON.parse(req.body);
    res.send(template3(collect));
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
      p {
        width: 50%;
      }
    </style>
    <h1>{{collect.title}}</h1>
    <hr>
    {{#each collect.entries}}
      {{#ifThird @index}}
        <p style="text-align: center; margin: 0 auto;">{{this.title}}</p>
        <hr>
      {{else}}
        {{#ifSecond @index}}
          <p style="text-align: left; margin-right: auto;">{{this.title}}</p>
          <hr>
        {{else}}
          <p style="text-align: right; margin-left: auto;">{{this.title}}</p>
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

function template3(collect) {
  var html = `
    <style type="text/css">
      h1 {
        text-align: center;
      }

      body {
        font-family: 'Times New Roman', Times, serif;
        margin: 8px;
        background-image: url("http://meryn.ru/rhizome/bow-bg2.png");
        text-align: center;
        margin-top: 40px;
      }

      .description {
        width: 460px;
        margin: 40px auto;
        background-color: rgba(150,135,165,1);
        color: white;
        padding: 10px;
        font-style: italic;
      }

      img {
        max-width: 200px;
        max-height: 250px;
      }
    </style>
    <img src="{{entry.image}}">
    <p class="description">{{entry.title}}</p>
    <hr>
  `;

  var template = Handlebars.compile(html);

  var first = Object.keys(collect.entries || {})[0];

  return template({ entry: collect.entries[first] });
}
