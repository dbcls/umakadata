function showRadar(endpoint_id, evaluation_id) {
  $.getJSON("/endpoints/" + endpoint_id + "/radar", function(json) {
    var data = json['data']
    var avg = json['avg']
    var context = $("#radar")[0].getContext("2d");
    var labels = ["availability", "freshness", "operation", "usefulness", "validity", "performance"]
    new Chart(context).Radar({
      labels: labels,
      datasets: [
        {
            label: "Target",
            fillColor: "rgba(151,187,205,0.2)",
            strokeColor: "rgba(151,187,205,1)",
            pointColor: "rgba(151,187,205,1)",
            pointStrokeColor: "#fff",
            pointHighlightFill: "#fff",
            pointHighlightStroke: "rgba(220,220,220,1)",
            data: data
        },
        {
            label: "Average",
            fillColor: "rgba(220,220,220,0.5)",
            strokeColor: "rgba(220,220,220,1)",
            pointColor: "rgba(220,220,220,1)",
            pointStrokeColor: "#fff",
            pointHighlightFill: "#fff",
            pointHighlightStroke: "rgba(151,187,205,1)",
            data: avg
        }
      ]
    }, {
      scaleOverride: true,
      scaleSteps: 11,
      scaleStepWidth: 10,
      scaleStartValue: 0,
    });

    for (var i = 0; i < 6; ++i) {
      $('#' + labels[i] + '_score').text('(' + data[i] + ')');
      if (data[i] < 20) {
        status = 'poor';
      } else if (data[i] < 40) {
        status = 'below_average'
      } else if (data[i] < 60) {
        status = 'average'
      } else if (data[i] < 80) {
        status = 'good'
      } else {
        status = 'excellent';
      }
      $('.' + labels[i]).addClass(status)
    }
  });
};


function showScoreHistory(endpoint_id) {
  $.getJSON("/endpoints/" + endpoint_id + "/score_history", function(json) {
    var context = document.querySelector("#score_history").getContext("2d");
    var lineChart = new Chart(context).Line(json, {
      datasetFill: false,
      multiTooltipTemplate: '<%= datasetLabel %> - <%= value %>',
      legendTemplate: '<% for (var i=0; i<datasets.length; i++){%><div class="col-xs-2"><span style=\"color:<%=datasets[i].strokeColor%>\">■</span><%if(datasets[i].label){%><%=datasets[i].label%><%}%></div><%}%>',
    });
    $("#line-chart-legend").append(lineChart.generateLegend());
  });
}
