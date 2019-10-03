import cytoscape from 'cytoscape'

import '../../stylesheets/endpoint'

$(function () {
  let $cy = $('#cy');

  $.ajax({
    type: 'GET',
    dataType: 'json',
    contentType: 'application/json; charset=UTF-8',
    url: Routes.endpoint_graph_path(),
    timeout: 10000 // 10 sec
  }).done(function (json, textStatus, jqXHR) {
    window.cy = cytoscape({
      elements: json,
      container: $cy,
      boxSelectionEnabled: false,
      autounselectify: true,
      layout: {
        name: 'cose',
        nodeOverlap: 400,
        fit: true
      },
      style: [
        {
          selector: 'node',
          css: {
            'content': "data(name)",
            'height': '200',
            'width': '200',
            'text-valign': 'center',
            'text-halign': 'center'
          }
        },
        {
          selector: 'edge',
          css: {
            'width': 3,
            'line-color': '#ccc',
            'target-arrow-shape': 'triangle',
            'curve-style': 'bezier'
          }
        }
      ]
    });
  }).fail(function (jqXHR, textStatus, errorThrown) {
    window.alert(`${textStatus}: ${jqXHR.status} ${errorThrown}`);
  });
});
