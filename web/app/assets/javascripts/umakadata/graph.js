//= require Chart.min
//= require cytoscape.min

$(document).ready(function() {
  $('#cy').height(window.innerHeight - 150);
  var url = '/api/endpoints/graph/';
  $.getJSON(url, function (data) {
    window.cy = cytoscape({
      container: document.getElementById('cy'),

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
      ],

      elements: data
    });
  });
});
