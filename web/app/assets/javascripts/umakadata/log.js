//= require jquery.treetable

$(document).ready(function() {
  $(".table").treetable({expandable: true});
  var elements = $("tbody").children();
  elements.each(function () {
    if ($(this).attr('class').match(/branch/)) {
      var id = $(this).attr('data-tt-id');
      if (id.match(/^\d+(_\d+){0,1}$/)) {
        $(".table").treetable('expandNode', id);
      }
    }
  });

  var JSON_REGEXP = /.*[\{|\[](.*)\{|\[$/;
  var XML_REGEXP = /.*<\?xml(.*)>/;
  $("tr td:first-child").each(function (i, bodyKey) {
    if (!$(bodyKey).text().match(/body/)) {
      return;
    }
    var formattedText = "";
    var text = "";
    try {
      var bodyValue = $(bodyKey).next();
      text = bodyValue.text();
      text = removeFirstBlankLine(text);
      if (text.match(JSON_REGEXP)) {
        text = text.replace(/\s*([\{|\[|\"|\'|\}\]].*[\n\r|\n|\r])/g, "$1");
        var json = JSON.stringify(JSON.parse(text), null, "    ");
        formattedText = formatText(json);
      } else if (text.match(XML_REGEXP)) {
        text = trimSpacesOfBeginingOfLine(text);
        var parser = new DOMParser();
        var xmlDocument = parser.parseFromString(text, "text/xml");
        if (xmlDocument.getElementsByTagName("parsererror").length === 0) {
          text = new XMLSerializer().serializeToString(xmlDocument);
        }
        formattedText = formatText(text);
      } else {
        text = trimSpacesOfBeginingOfLine(text);
        formattedText = formatText(text);
      }
      bodyValue.empty().append(formattedText);
    } catch (e) {
      text = trimSpacesOfBeginingOfLine(text);
      formattedText = formatText(text);
      bodyValue.empty().append(formattedText);
    }
  });

  function removeFirstBlankLine(text) {
    return text.replace(/\s*[\n\r|\n|\r]/, "");
  }

  function trimSpacesOfBeginingOfLine(text) {
    var length = text.split(/\S/)[0].length;
    var regExp = new RegExp('\\s{' + length + '}(\\S.*[\\n\\r|\\n|\\r])', 'g');
    return text.replace(regExp, "$1");
  }

  function sanitize(text) {
    return text.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;').replace(/'/g, '&#39;');
  }

  function formatText(text) {
    return sanitize(text).replace(/[\n\r|\n|\r]/g, "<br/>").replace(/\t/, "&nbsp;&nbsp;&nbsp;&nbsp;").replace(/\s/g, "&nbsp;")
  }
});
