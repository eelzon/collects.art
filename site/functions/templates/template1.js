var Handlebars = require('handlebars');

module.exports = function(title, entries) {
  var template = Handlebars.compile(`
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
  `);

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

  return template({ title: title, entries: links });
}
