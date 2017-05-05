var Handlebars = require('handlebars');

module.exports = function(title, entries) {
  var template = Handlebars.compile(`
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
  `);

  var index = Math.floor(Math.random() * entries.length);

  return template({ title: title, entry: entries[index] });
}
