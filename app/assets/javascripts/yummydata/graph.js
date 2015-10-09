$(function() {
  $("#cy").height('500');
  var cy = cytoscape({
    container: document.getElementById('cy'),
    style: [
      {
        selector: 'node',
        style: {
          content: "data(name)"
        }
      }
    ],
    ready: function(){
      cy.add([
        { group: "nodes", data: { id: "n0", name: "Pathway Commons @Malaga" }, position: { x: 300, y: 200 } },
        { group: "nodes", data: { id: "n1", name: "Linked Life Data" }, position: { x: 600, y: 200 } },
        { group: "nodes", data: { id: "n2", name: "National Center for Biomedical Ontologies" }, position: { x: 300, y: 100 } },
        { group: "nodes", data: { id: "n3", name: "Allie" }, position: { x: 100, y: 300 } },
        { group: "nodes", data: { id: "n4", name: "HCLS DERI" }, position: { x: 300, y: 300 } },
        { group: "nodes", data: { id: "n5", name: "DrugBank @FU Berlin" }, position: { x: 600, y: 100 } },
        { group: "edges", data: { id: "e0", source: "n0", target: "n1" } },
        { group: "edges", data: { id: "e1", source: "n0", target: "n2" } },
        { group: "edges", data: { id: "e2", source: "n3", target: "n4" } },
        { group: "edges", data: { id: "e3", source: "n1", target: "n5" } },
        { group: "edges", data: { id: "e4", source: "n4", target: "n0" } },
      ]);
    }
  });
});
