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
        max-width: 200px;
        max-height: 200px;
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
  `);

  return template({ title: title, entries: entries });
}
