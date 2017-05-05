var Handlebars = require('handlebars');

module.exports = function(title, entries) {
  var template = Handlebars.compile(`
    <style type='text/css'>
      h1 {
        color:#50547a;
      }
      body {
        background-image: url('http://meryn.ru/rhizome/maude_stain_pattern-03-light.gif');
      }
      .solo img {
        max-height: 300px;
        max-width: 320px
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
        max-width: 320px;
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
          <img src='{{first.image}}' title='{{first.title}}' alt='{{first.title}}' />
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
          <img src='{{last.image}}' last='{{this.title}}' alt='{{last.title}}' />
        {{/if}}
        {{#if last.title}}
          <p>{{last.title}}</p>
        {{/if}}
      </div>
    {{/if}}
    <hr>
  `);

  var formatEntry = function(entry) {
    var html = '';
    if (entry.image) {
      html = html + `<img src='${entry.image}' title='${entry.title}' alt='${entry.title}' />`;
    }
    if (entry.title) {
      html = html + `<p>${entry.title}</p>`;
    }
    return html;
  }

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

  return template({ title: title, first: firstEntry, last: lastEntry, rows: rows });
}
