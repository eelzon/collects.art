var functions = require('firebase-functions');
var cors = require('cors')({ origin: true });
var Handlebars = require('handlebars');

// Create and Deploy Your First Cloud Functions
// https://firebase.google.com/docs/functions/write-firebase-functions
exports.template = functions.https.onRequest((req, res) => {
  cors(req, res, () => {
    var collect = JSON.parse(req.body);
    res.send(getTemplate(collect));
  });
});

function getTemplate(collect) {
  switch(collect.template) {
  case 1:
    return template1(collect);
  // case 2:
  //   return template2(collect);
  case 3, 11:
    return template3(collect);
  case 4, 2:
    return template4(collect);
  case 5, 9:
    return template5(collect);
  case 6:
    return template6(collect);
  case 7:
    return template7(collect);
  case 8, 10:
    return template8(collect);
  // case 9:
  //   return template9(collect);
  // case 10:
  //   return template10(collect);
  // case 11:
  //   return template11(collect);
  }
}

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

// function template2(collect) {
//   var html = `

//   `;

//   var template = Handlebars.compile(html);

//   return template({});
// }

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
    [i, i + 1, i + 2, i + 3, i + 4, i + 5].forEach((index) => {
      if (index >= keys.length) {
        return;
      }
      var entry = entries[keys[index]];
      var image = entry.image ? `<img src="${entry.image}" />` : '';
      var title = entry.title || '';
      headers = headers + `<th>${title}</th>`;
      images = images + `<td>${image}</td>`;
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
    <style type="text/css">
      h1 {
        text-align: center;
      }
      body {
        font-family: 'Times New Roman', Times, serif;
        margin: 8px;
        background-image: url("http://meryn.ru/rhizome/tulip-bg-light.gif");
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
    <p class="description">
      {{#if random.image}}
        <a href="{{random.image}}">
      {{/if}}
      {{random.title}}
      {{#if random.image}}
        </a>
      {{/if}}
    </p>
    <hr>
    {{#each rest}}
      {{#if this.image}}
        <p><img src="{{this.image}}" title="{{this.title}}" alt="{{this.title}}" /></p>
      {{/if}}
    {{/each}}
    <hr>
  `;

  var template = Handlebars.compile(html);

  var keys = Object.keys(collect.entries || {});
  var index = Math.floor(Math.random() * keys.length);

  var rest = [];
  var random;
  keys.forEach((key, i) => {
    if (i !== index) {
      rest.push(collect.entries[key]);
    } else {
      random = collect.entries[key];
    }
  });

  return template({ title: collect.title, random: random, rest: rest });
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
    {{#if entry.image}}
      <img src="{{entry.image}}" title="{{entry.title}}" alt="{{entry.title}}">
    {{/if}}
    <hr>
    <a href="/">back</a>
  `;

  var template = Handlebars.compile(html);

  var keys = Object.keys(collect.entries || {});
  var index = Math.floor(Math.random() * keys.length);

  return template({ title: collect.title, entry: collect.entries[keys[index]] });
}

function template8(collect) {
  var html = `
    <style type="text/css">
      h1 {
        text-align: center;
      }
      body {
        font-family: 'Times New Roman', Times, serif;
        margin: 8px;
        background-image: url("http://meryn.ru/rhizome/ty-bg-light.png");
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
          <a href="#{{@index}}">
        {{/if}}
          <img src="{{this.image}}" />
        {{#if this.title}}
          </a>
        {{/if}}
      {{/if}}
    {{/each}}

    {{#each entries}}
      {{#if this.title}}
        <a name="{{@index}}"></a>
        <p class="poem">
          {{this.title}}
        </p>
      {{/if}}
    {{/each}}
  `;

  var template = Handlebars.compile(html);

  return template({ title: collect.title, entries: collect.entries });
}

// function template9(collect) {
//   var html = `

//   `;

//   var template = Handlebars.compile(html);

//   return template({});
// }

// function template10(collect) {
//   var html = `
//     <style type="text/css">
//       h1 {
//         text-align: center;
//         text-transform: uppercase;
//       }
//       body {
//         font-family: 'Times New Roman', Times, serif;
//         margin: 8px;
//         background-image: url("http://meryn.ru/rhizome/rain-bg-lighter.png");
//       }
//       .content {
//         width: 800px;
//         margin: 20px auto;
//         text-align: left;
//       }
//       .column-group {
//         display: inline-block;
//       }
//       .column {
//         width: 230px;
//         float: left;
//         margin: 0 30px 0 0;
//       }
//       .column.last {
//         margin: 0;
//       }
//       .entry {
//         padding: 4px 8px;
//         background-color: rgba(164,172,185, .8);
//       }
//     </style>
//     <h1>{{title}}</h1>
//     <div class="content">
//       {{#each entries}}
//         {{{this}}}
//       {{/each}}
//     </div>
//   `;

//   // <p></p>
//   // <div class="column-group">
//   //   <p class="column"></p>
//   //   <p class="column"></p>
//   //   <p class="column last"></p>
//   // </div>
//   // <p></p>
//   // <p></p>
//   var entries = collect.entries;
//   var keys = Object.keys(entries || {});
//   var content = '';

//   var formatEntry = (entry, customClass) => {
//     var image = entry.image ? `<img src="${entry.image}" />` : '';
//     var title = entry.title ? `<p>${entry.title}</p>` : '';
//     if (image || title) {
//       return `<div class="entry ${customClass}">${image}${title}</div>`
//     }
//     return '';
//   };

//   for (var i = 0; i < keys.length; i += 6) {
//     var group = '';
//     if (i >= keys.length) {
//       return;
//     } else {
//       group = group + formatEntry(entries[keys[i]], '');
//     }
//     [i + 1, i + 2, i + 3].forEach((index) => {
//       if (index >= keys.length) {
//         return;
//       }
//       var entry = entries[keys[index]];
//       group = group + formatEntry(entry, 'column');
//       if (group) {
//         group = group + `<div class="column">${image}${title}</div>`;
//       }
//     });
//     if (group) {
//       content = content + `<div class="column-group">${group}</div>`;
//     }
//   }

//   var template = Handlebars.compile(html);

//   return template({});
// }

// function template11(collect) {
//   var html = `
//     <style type="text/css">
//       body {
//         text-align: center;
//         background-image: url("http://meryn.ru/rhizome/princessrose-bg-light.gif");
//       }
//     </style>
//     <h3><em>{{title}}</em></h3>

//     <p>2</p>
//     <p>4</p>
//     <p>7</p>
//     <p>8</p>
//     <p>11</p>
//     <p>9</p>
//     <p>11</p>
//     <p>8</p>
//     <p>10</p>
//     <p>5</p>
//     <p>3</p>
//     <p>1</p>

//     <p><a href="/">HOME</a></p>
//   `;

//   var template = Handlebars.compile(html);

//   var entries = collect.entries;
//   var keys = Object.keys(entries || {});

//   var links = keys.map((key) => {
//     var entry = entries[key];
//     if (entry.title && entry.image) {
//       return `<a href="${entry.image}">${entry.title}</a>`;
//     } else if (entry.title) {
//       return entry.title;
//     } else if (entry.image) {
//       return `<a href="${entry.image}">untitled</a>`;
//     }
//     return '';
//   });

//   var rows = [2, 4, 7, 8, 11, 9, 11, 8, 10, 5, 3, 1];

//   return template({});
// }
