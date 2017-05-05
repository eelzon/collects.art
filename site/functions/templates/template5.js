var Handlebars = require('handlebars');

module.exports = function(title, entries) {
  var template = Handlebars.compile(`
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
        max-height: 300px;
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
  `);

  return template({ title: title, entries: entries });
}
