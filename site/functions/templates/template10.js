var Handlebars = require('handlebars');

module.exports = function(title, entries, background) {
  var template = Handlebars.compile(`
    <style type='text/css'>
      h1 {
        text-align: center;
      }
      body {
        font-family: 'Times New Roman', Times, serif;
        background-image: url('${background}');
      }
      table {
        max-width: 800px;
        margin: 20px auto;
        text-align: left;
        border-collapse: separate;
        border-spacing: 20px;
      }
      .column {
        margin-right: 30px;
      }
      td {
        padding: 4px 8px;
        background-color: rgba(164, 172, 185, .8);
      }
      img {
        width: 100%;
      }
      .image {
        max-width: 400px;
        margin: 0 auto;
      }
    </style>
    <h1>${title}</h1>
    <table>
      {{{content}}}
    </table>
  `);

  var formatEntry = (entry, custom) => {
    var image = entry.image ? `<div class='image'><img src='${entry.image}' /></div>` : '';
    var title = entry.title ? `<p>${entry.title}</p>` : '';
    if (image || title) {
      return `<td ${custom}>${image}${title}</td>`
    }
    return '';
  };

  var content = '';
  var rowstartIndex = 1;
  for (var i = 0; i < entries.length; i += 1) {
    var row = '';
    if (i === rowstartIndex) {
      for (i; i < rowstartIndex + 3; i += 1) {
        if (i >= entries.length) {
          continue;
        }
        row = row + formatEntry(entries[i], 'class=\'column\'');
      }
      rowstartIndex = rowstartIndex + 6;
      // we don't want that last increment
      i = i - 1;
    } else {
      row = row + formatEntry(entries[i], 'colspan=\'3\'');
    }
    if (row) {
      content = content + `<tr>${row}</tr>`;
    }
  }

  return template({ content: content });
}
