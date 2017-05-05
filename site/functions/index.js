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
      res.send(getTemplate(collect));
    });
  });
});

function arrayFromEntries(collect) {
  var allEntries = collect.entries || {};
  return Object.keys(allEntries).reduce((entries, key) => {
    var entry = allEntries[key];
    if (entry.title || entry.image) {
      entries.push(entry);
    }
    return entries;
  }, []);
}

function getTemplate(collect) {
  var index = collect.template;
  if (index === 1) {
    return template1(collect);
  } else if (index === 2) {
    return template2(collect);
  } else if (index === 3) {
    return template3(collect);
  } else if (index === 4) {
    return template4(collect);
  } else if (index === 5) {
    return template5(collect);
  } else if (index === 6) {
    return template6(collect);
  } else if (index === 7) {
    return template7(collect);
  } else if (index === 8) {
    return template8(collect);
  } else if (index === 9) {
    return template9(collect);
  } else if (index === 10) {
    return template10(collect);
  } else if (index === 11) {
    return template11(collect);
  }
}

function template1(collect) {
  var html = `
    <style type='text/css'>
      h1 {
        text-align:center;
      }
      body {
          background-image: url('http://meryn.ru/rhizome/harlequin.png');
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
        <p style='text-align: center; margin: 0 auto;'>{{{this}}}</p>
        <hr>
      {{else}}
        {{#ifSecond @index}}
          <p style='text-align: left; margin-right: auto;'>{{{this}}}</p>
          <hr>
        {{else}}
          <p style='text-align: right; margin-left: auto;'>{{{this}}}</p>
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

  var entries = arrayFromEntries(collect);
  var links = entries.map((entry) => {
    if (entry.title && entry.image) {
      return `<a href='${entry.image}'>${entry.title}</a>`;
    } else if (entry.title) {
      return entry.title;
    } else if (entry.image) {
      return `<a href='${entry.image}'>untitled</a>`;
    }
    return '';
  });

  return template({ title: collect.title, entries: links });
}

function template2(collect) {
  var html = `
    <style type='text/css'>
      h1 {
        color:#50547a;
      }
      body {
        background-image: url('http://meryn.ru/rhizome/maude_stain_pattern-03-light.gif');
      }
      .solo img {
        max-height: 250px;
        max-width: 300px
      }
      .solo.right {
        text-align: right;
      }
      .solo.left {
        text-align: left;
      }
      .group {
        text-align: center;
      }
      .group img {
        max-height: 300px;
        max-width: 180px;
        margin-right: 10px;
      }
      .group img:last-child {
        margin-right: 0;
      }
    </style>
    <h1>{{title}}</h1>
    <hr>
    {{#if first}}
      <div class='solo left'>
        {{#if first.image}}
          <img src='{{first.image}}' />
        {{/if}}
        {{#if first.title}}
          <p>{{first.title}}</p>
        {{/if}}
      </div>
      <hr>
    {{/if}}
    {{#each rows}}
      <div class='group'>
        {{#if images}}
          {{{images}}}
        {{/if}}
        {{#if titles}}
          <p>{{{titles}}}</p>
        {{/if}}
      </div>
      <hr>
    {{/each}}
    {{#if last}}
      <div class='solo right'>
        {{#if last.image}}
          <img src='{{last.image}}' />
        {{/if}}
        {{#if last.title}}
          <p>{{last.title}}</p>
        {{/if}}
      </div>
    {{/if}}
    <hr>
  `;

  var template = Handlebars.compile(html);

  var formatEntry = function(entry) {
    var html = '';
    if (entry.image) {
      html = html + `<img src='${entry.image}' />`;
    }
    if (entry.title) {
      html = html + `<p>${entry.title}</p>`;
    }
    return html;
  }

  var entries = arrayFromEntries(collect);

  var firstEntry = entries.shift();
  var lastEntry = entries.pop();

  var rows = [];

  for (var i = 0; i < entries.length; i += 1) {
    // pick between 2 and 5 items
    var rowLength = Math.floor(Math.random() * 4) + 2;
    var images = '';
    var titles = '';
    for (var j = 0; j < rowLength; j += 1) {
      var index = i + j;
      if (index >= entries.length) {
        return;
      } else {
        var entry = entries[index];
        if (entry.image) {
          images = images + `<img src='${entry.image}' />`;
        }
        if (entry.title) {
          titles = titles + ' | ' + entry.title;
        }
      }
    }
    rows.push({ images: images, titles:titles });
    i = i + rowLength - 1;
  }

  return template({ title: collect.title, first: firstEntry, last: lastEntry, rows: rows });
}

function template3(collect) {
  var html = `
    <style type='text/css'>
      h1 {
        text-align: center;
      }
      body {
        font-family: 'Times New Roman', Times, serif;
        margin: 8px;
        background-image: url('http://meryn.ru/rhizome/bow-bg2.png');
        text-align: center;
        margin-top: 40px;
      }
      .description {
        max-width: 460px;
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
    <h1>{{title}}</h1>
    {{#if entry.image}}
      <img src='{{entry.image}}'>
    {{/if}}
    {{#if entry.title}}
      <p class='description'>{{entry.title}}</p>
    {{/if}}
    <hr>
  `;

  var template = Handlebars.compile(html);

  var entries = arrayFromEntries(collect);
  var index = Math.floor(Math.random() * entries.length);

  return template({ title: collect.title, entry: entries[index] });
}

function template4(collect) {
  var html = `
    <style type='text/css'>
      h1 {
        text-align: center;
      }
      body {
        font-family: 'Times New Roman', Times, serif;
        margin: 8px;
        background-image: url('http://meryn.ru/rhizome/morphine-bg-light.gif');
      }
      .content {
        max-width: 1000px;
        margin: 20px auto;
        text-align: left;
      }
      .column-group {
        display: inline-block;
        width: 100%;
      }
      .column {
        width: 31%;
        float: left;
        margin: 0 1%;
      }
      .column img {
        max-width: 100%;
      }
    </style>
    <h1>{{title}}</h1>
    <div class='content'>
      {{{content}}}
    </div>
  `;

  var template = Handlebars.compile(html);

  var entries = arrayFromEntries(collect);
  var content = '';

  for (var i = 0; i < entries.length; i += 3) {
    var group = '';
    [i, i + 1, i + 2].forEach((index) => {
      if (index >= entries.length) {
        return;
      }
      var entry = entries[index];
      var image = entry.image ? `<img src='${entry.image}' />` : '';
      var title = entry.title ? `<p>${entry.title}</p>` : '';
      if (image || title) {
        group = group + `<div class='column'>${image}${title}</div>`;
      }
    });
    if (group) {
      content = content + `<div class='column-group'>${group}</div>`;
    }
  }

  return template({ title: collect.title, content: content });
}

function template5(collect) {
  var html = `
    <style type='text/css'>
      h1 {
        text-align: center;
      }
      body {
        font-family: 'Times New Roman', Times, serif;
        margin: 8px;
        background-image: url('http://meryn.ru/rhizome/flag-bg2.gif');
      }
      img {
        max-width: 100%;
        max-height: 150px;
      }
      .container {
        display: inline-flex;
        flex-wrap: wrap;
        width: 100%;
        text-align: center;
        justify-content: center;
      }
      .inner {
        overflow: auto;
        word-wrap: break-word;
        width: 16%;
        padding: 6px;
        border: 4px ridge;
      }
    </style>
    <h1>{{title}}</h1>
    <hr>
    <div class='container'>
      {{#each entries}}
        <div class='inner'>
          {{#if this.title}}
            <p>{{this.title}}</p>
          {{/if}}
          {{#if this.image}}
            <img src='{{this.image}}'>
          {{/if}}
        </div>
      {{/each}}
    </div>
  `;

  var template = Handlebars.compile(html);

  var entries = arrayFromEntries(collect);

  return template({ title: collect.title, entries: entries });
}

function template6(collect) {
  var html = `
    <style type='text/css'>
      h1 {
        text-align: center;
      }
      body {
        font-family: 'Times New Roman', Times, serif;
        margin: 8px;
        background-image: url('http://meryn.ru/rhizome/tulip-bg-light.gif');
      }
      .description {
       color: #9B979F;
       background-color: thistle;
      }
      a {
        text-decoration: none;
        color: inherit;
      }
      img {
        margin-bottom: 8px;
        max-width: 550px;
        max-height: 375px;
      }
    </style>
    <h1>{{title}}</h1>
    <hr>
    <p class='description'>
      {{#if random.image}}
        <a href='{{random.image}}'>
      {{/if}}
      {{random.title}}
      {{#if random.image}}
        </a>
      {{/if}}
    </p>
    <hr>
    {{#each rest}}
      {{#if this.image}}
        <p><img src='{{this.image}}' title='{{this.title}}' alt='{{this.title}}' /></p>
      {{/if}}
    {{/each}}
    <hr>
  `;

  var template = Handlebars.compile(html);

  var entries = arrayFromEntries(collect);
  var index = Math.floor(Math.random() * entries.length);
  var random = entries.splice(index, 1);

  return template({ title: collect.title, random: random, rest: entries });
}

function template7(collect) {
  var html = `
    <style type='text/css'>
      h1 {
        text-align: left;
      }
      body {
        font-family: 'Times New Roman', Times, serif;
        margin: 8px;
        background-image: url('http://meryn.ru/rhizome/patch-bg2.gif');
      }
      img {
        max-width: 600px;
        max-height: 450px;
        min-width: 300px;
        min-height: 225px;
      }
    </style>
    <h1>{{title}}</h1>
    <a href='/'>back</a>
    <hr>
    {{#if entry.image}}
      <img src='{{entry.image}}' title='{{entry.title}}' alt='{{entry.title}}'>
    {{/if}}
    <hr>
    <a href='/'>back</a>
  `;

  var template = Handlebars.compile(html);

  var entries = arrayFromEntries(collect);
  var index = Math.floor(Math.random() * entries.length);

  return template({ title: collect.title, entry: entries[index] });
}

function template8(collect) {
  var html = `
    <style type='text/css'>
      h1 {
        text-align: center;
      }
      body {
        font-family: 'Times New Roman', Times, serif;
        margin: 8px;
        background-image: url('http://meryn.ru/rhizome/ty-bg-light.png');
      }
      .poem {
        background: white;
        color: dimgrey;
        max-width: 600px;
        padding: 10px;
        margin-right:auto
      }
      img {
        max-width: 150px;
        max-height: 150px;
      }
    </style>
    <h1>{{title}}</h1>
    <hr>

    {{#each entries}}
      {{#if this.image}}
        {{#if this.title}}
          <a href='#{{@index}}'>
        {{/if}}
          <img src='{{this.image}}' />
        {{#if this.title}}
          </a>
        {{/if}}
      {{/if}}
    {{/each}}

    {{#each entries}}
      {{#if this.title}}
        <a name='{{@index}}'></a>
        <p class='poem'>
          {{this.title}}
        </p>
      {{/if}}
    {{/each}}
  `;

  var template = Handlebars.compile(html);

  var entries = arrayFromEntries(collect);

  return template({ title: collect.title, entries: entries });
}

function template9(collect) {
  var html = `
    <style type='text/css'>
      h1 {
        text-align: center;
      }
      body {
        font-family: 'Times New Roman', Times, serif;
        margin: 8px;
        background-image: url('http://meryn.ru/rhizome/snowflakes-bg2.gif');
      }
      img {
        max-width: 100%;
        max-height: 200px;
      }
      .container {
        display: inline-flex;
        flex-wrap: wrap;
        margin: 0 auto;
        max-width: 1000px;
        text-align: center;
      }
      .inner {
        overflow: auto;
        word-wrap: break-word;
        max-width: 200px;
        padding: 6px;
        border: 4px ridge;
      }
    </style>
    <h1>{{title}}</h1>
    <hr>
    {{{content}}}
  `;

  var template = Handlebars.compile(html);

  var entries = arrayFromEntries(collect);
  var content = '';

  for (var i = 0; i < entries.length; i += 4) {
    var images = '';
    var titles = '';
    [i, i + 1, i + 2, i + 3].forEach((index) => {
      if (index >= entries.length) {
        return;
      }
      var entry = entries[index];
      var image = entry.image ? `<div class='inner'><img src='${entry.image}' /></div>` : '';
      images = images + image;
      var title = entry.title ? `<p>${entry.title}</p>` : '';
      titles = titles + title;
    });
    if (images) {
      images = '<div class=\'container\'>' + images + '</div>';
    }
    if (images || titles) {
      content = content + images + titles + '<hr>';
    }
  }

  return template({ title: collect.title, content: content });
}

function template10(collect) {
  var html = `
    <style type='text/css'>
      h1 {
        text-align: center;
      }
      body {
        font-family: 'Times New Roman', Times, serif;
        background-image: url('http://meryn.ru/rhizome/rain-bg-lighter.png');
      }
      table {
        max-width: 800px;
        margin: 20px auto;
        text-align: left;
        border-collapse: separate;
        border-spacing: 20px;
      }
      .column {
        margin-right: 30px;
      }
      td {
        padding: 4px 8px;
        background-color: rgba(164,172,185, .8);
      }
      img {
        width: 100%;
      }
      .image {
        max-width: 200px;
        margin: 0 auto;
      }
    </style>
    <h1>{{title}}</h1>
    <table>
      {{{content}}}
    </table>
  `;

  var template = Handlebars.compile(html);

  var formatEntry = (entry, custom) => {
    var image = entry.image ? `<div class='image'><img src='${entry.image}' /></div>` : '';
    var title = entry.title ? `<p>${entry.title}</p>` : '';
    if (image || title) {
      return `<td ${custom}>${image}${title}</td>`
    }
    return '';
  };

  var entries = arrayFromEntries(collect);
  var content = '';

  var rowstartIndex = 1;
  for (var i = 0; i < entries.length; i += 1) {
    var row = '';
    if (i === rowstartIndex) {
      for (i; i < rowstartIndex + 3; i += 1) {
        if (i >= entries.length) {
          continue;
        }
        row = row + formatEntry(entries[i], 'class=\'column\'');
      }
      rowstartIndex = rowstartIndex + 6;
      // we don't want that last increment
      i = i - 1;
    } else {
      row = row + formatEntry(entries[i], 'colspan=\'3\'');
    }
    if (row) {
      content = content + `<tr>${row}</tr>`;
    }
  }

  return template({ title: collect.title, content: content });
}
