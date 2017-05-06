var Handlebars = require('handlebars');

module.exports = function(title, entries, background) {
  var template = Handlebars.compile(`
    <style type='text/css'>
      h1 {
        text-align: center;
      }
      body {
        font-family: 'Times New Roman', Times, serif;
        margin: 8px;
        background-image: url('${background}');
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
        max-width: 600px;
        max-height: 450px;
        min-width: 300px;
        min-height: 225px;
      }
    </style>
    <h1>${title}</h1>
    {{#if entry.image}}
      <img src='{{entry.image}}'>
    {{/if}}
    {{#if entry.title}}
      <p class='description'>{{entry.title}}</p>
    {{/if}}
    <hr>
  `);

  var index = Math.floor(Math.random() * entries.length);

  return template({ entry: entries[index] });
}
