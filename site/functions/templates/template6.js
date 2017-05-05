var Handlebars = require('handlebars');

module.exports = function(title, entries) {
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

  var index = Math.floor(Math.random() * entries.length);
  var random = entries.splice(index, 1);

  return template({ title: title, random: random, rest: entries });
}
