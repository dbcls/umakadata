$(function() {
  $("#cy").height(window.innerHeight - 150);
  var url = "/api/endpoints/graph/"
  $.getJSON(url, function(data) {
    var cy = window.cy = cytoscape({
      container: document.getElementById('cy'),

      layout: {
        name: 'cose',
        idealEdgeLength: 100,
        nodeOverlap: 20
      },

      style: [
        {
          selector: 'node',
          style: {
            content: "data(name)"
          }
        },
        {
          selector: 'edge',
          style: {
            'width': 3,
            'line-color': '#ccc'
          }
        },
        {
          selector: 'edge',
          css: {
            'target-arrow-shape': 'triangle',
            'curve-style': 'bezier'
          }
        }
      ],

      elements: data

    });
  });

});
