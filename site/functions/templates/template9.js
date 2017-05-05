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
        background-image: url('http://meryn.ru/rhizome/snowflakes-bg2.gif');
      }
      img {
        max-width: 100%;
        max-height: 200px;
      }
      .container {
        display: inline-flex;
        flex-wrap: wrap;
        margin: 0 auto;
        max-width: 1000px;
        text-align: center;
      }
      .inner {
        overflow: auto;
        word-wrap: break-word;
        max-width: 200px;
        padding: 6px;
        border: 4px ridge;
      }
    </style>
    <h1>{{title}}</h1>
    <hr>
    {{{content}}}
  `;

  var template = Handlebars.compile(html);

  var content = '';
  for (var i = 0; i < entries.length; i += 4) {
    var images = '';
    var titles = '';
    [i, i + 1, i + 2, i + 3].forEach((index) => {
      if (index >= entries.length) {
        return;
      }
      var entry = entries[index];
      var image = entry.image ? `<div class='inner'><img src='${entry.image}' /></div>` : '';
      images = images + image;
      var title = entry.title ? `<p>${entry.title}</p>` : '';
      titles = titles + title;
    });
    if (images) {
      images = '<div class=\'container\'>' + images + '</div>';
    }
    if (images || titles) {
      content = content + images + titles + '<hr>';
    }
  }

  return template({ title: title, content: content });
}
