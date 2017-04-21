var functions = require('firebase-functions');
var cors = require('cors')({ origin: true });
var Handlebars = require('handlebars');

// Create and Deploy Your First Cloud Functions
// https://firebase.google.com/docs/functions/write-firebase-functions
exports.template = functions.https.onRequest((req, res) => {
  cors(req, res, () => {
    var collect = JSON.parse(req.body);
    var template = collect.template;
    switch(template) {
    case 1:
      res.send(template1(collect));
    case 2:
      res.send(template2(collect));
    case 3:
      res.send(template3(collect));
    case 4:
      res.send(template4(collect));
    case 5:
      res.send(template5(collect));
    case 6:
      res.send(template6(collect));
    case 7:
      res.send(template7(collect));
    case 8:
      res.send(template8(collect));
    case 9:
      res.send(template9(collect));
    case 10:
      res.send(template10(collect));
    case 11:
      res.send(template11(collect));
    }
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
      a {
        text-decoration: none;
        color: black;
      }
    </style>
    <h1>{{title}}</h1>
    <hr>
    {{#each entries}}
      {{#ifThird @index}}
        <p style="text-align: center; margin: 0 auto;">{{{this}}}</p>
        <hr>
      {{else}}
        {{#ifSecond @index}}
          <p style="text-align: left; margin-right: auto;">{{{this}}}</p>
          <hr>
        {{else}}
          <p style="text-align: right; margin-left: auto;">{{{this}}}</p>
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

  var keys = Object.keys(collect.entries || {});
  var links = keys.map((key) => {
    var entry = collect.entries[key];
    if (entry.title && entry.image) {
      return `<a href="${entry.image}">${entry.title}</a>`;
    } else if (entry.title) {
      return entry.title;
    } else if (entry.image) {
      return `<a href="${entry.image}">untitled</a>`;
    }
    return '';
  });

  return template({ title: collect.title, entries: links });
}

function template2(collect) {
  var html = `

  `;

  var template = Handlebars.compile(html);

  return template({});
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
    {{#if entry.image}}
      <img src="{{entry.image}}">
    {{/if}}
    {{#if entry.title}}
      <p class="description">{{entry.title}}</p>
    {{/if}}
    <hr>
  `;

  var template = Handlebars.compile(html);

  var keys = Object.keys(collect.entries || {});
  var index = Math.floor(Math.random() * keys.length);

  return template({ entry: collect.entries[keys[index]] });
}

function template4(collect) {
  var html = `
    <style type="text/css">
      h1 {
        text-align: center;
      }
      body {
        font-family: 'Times New Roman', Times, serif;
        margin: 8px;
        background-image: url("http://meryn.ru/rhizome/morphine-bg-light.gif");
      }
      .content {
        width: 90%;
        margin: 20px auto;
        text-align: left;
      }
      .column-group {
        display: inline-block;
      }
      .column {
        width: 31%;
        float: left;
        margin: 0 1%;
      }
      .column img {
        width: 100%;
      }
    </style>
    <h1>{{title}}</h1>
    <div class="content">
      {{{content}}}
    </div>
  `;

  var template = Handlebars.compile(html);

  var entries = collect.entries;
  var keys = Object.keys(entries || {});
  var content = '';

  for (var i = 0; i < keys.length; i += 3) {
    var group = '';
    // Do your work with array[i], array[i+1]...array[i+N-1]
    [i, i + 1, i + 2].forEach((index) => {
      if (index >= keys.length) {
        return;
      }
      var entry = entries[keys[index]];
      var image = entry.image ? `<img src="${entry.image}" />` : '';
      var title = entry.title ? `<p>${entry.title}</p>` : '';
      if (image || title) {
        group = group + `<div class="column">${image}${title}</div>`;
      }
    });
    if (group) {
      content = content + `<div class="column-group">${group}</div>`;
    }
  }

  return template({ title: collect.title, content: content });
}

function template5(collect) {
  var html = `
  <style type="text/css">
    h1 {
      text-align: center;
    }
    body {
      font-family: 'Times New Roman', Times, serif;
      margin: 8px;
      background-image: url("http://meryn.ru/rhizome/flag-bg2.gif");
    }
    table {
      margin: 0 auto;
      text-align: center;
    }
    table, td, th {
      border-collapse: collapse;
      border: 4px ridge;
    }
    td, th {
      margin:0;
      padding: 6px 6px 1px 6px;
      max-width: 170px;
    }
    img {
      max-width: 150px;
      max-height: 150px;
    }
  </style>
  <h1>{{title}}</h1>
  <hr>
  <table cellspacing="0" cellpadding="0">
    <tbody>
      {{{rows}}}
    </tbody>
  </table>
  `;

  var template = Handlebars.compile(html);

  var entries = collect.entries;
  var keys = Object.keys(entries || {});
  var rows = '';

  for (var i = 0; i < keys.length; i += 6) {
    var headers = '';
    var images = '';
    // Do your work with array[i], array[i+1]...array[i+N-1]
    [i, i + 1, i + 2, i + 3, i + 4, i + 5].forEach((index) => {
      if (index >= keys.length) {
        return;
      }
      var entry = entries[keys[index]];
      var image = entry.image ? `<img src="${entry.image}" />` : '';
      var title = entry.title || '';
      if (title) {
        headers = headers + `<th>${title}</th>`;
      }
      if (image) {
        images = images + `<td>${image}</td>`;
      }
    });
    if (headers) {
      rows = rows + `<tr>${headers}</tr>`;
    }
    if (images) {
      rows = rows + `<tr>${images}</tr>`;
    }
  }

  return template({ title: collect.title, rows: rows });
}

function template6(collect) {
  var html = `

  `;

  var template = Handlebars.compile(html);

  return template({});
}

function template7(collect) {
  var html = `
    <style type="text/css">
      h1 {
        text-align: left;
      }
      body {
        font-family: 'Times New Roman', Times, serif;
        margin: 8px;
        background-image: url("http://meryn.ru/rhizome/patch-bg2.gif");
      }
      img {
        max-width: 600px;
        max-height: 450px;
      }
    </style>
    <h1>{{title}}</h1>
    <a href="/">back</a>
    <hr>
    {{#if image}}
      <img src="{{image}}">
    {{/if}}
    <hr>
    <a href="/">back</a>
  `;

  var template = Handlebars.compile(html);

  var keys = Object.keys(collect.entries || {});
  var index = Math.floor(Math.random() * keys.length);

  return template({ title: collect.title, image: collect.entries[keys[index]].image });
}
