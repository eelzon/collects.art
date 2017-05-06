var Handlebars = require('handlebars');

module.exports = function(title, entries, background) {
  var template = Handlebars.compile(`
    <style type='text/css'>
      h1 {
        text-align: left;
      }
      body {
        font-family: 'Times New Roman', Times, serif;
        margin: 8px;
        background-image: url('${background}');
      }
      img {
        max-width: 600px;
        max-height: 450px;
        min-width: 300px;
        min-height: 225px;
      }
    </style>
    <h1>${title}</h1>
    <a href='/'>back</a>
    <hr>
    {{#if entry.image}}
      <img src='{{entry.image}}' title='{{entry.title}}' alt='{{entry.title}}'>
    {{/if}}
    <hr>
    <a href='/'>back</a>
  `);

  var index = Math.floor(Math.random() * entries.length);

  return template({ entry: entries[index] });
}
