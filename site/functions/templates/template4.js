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

  return template({ title: title, content: content });
}
