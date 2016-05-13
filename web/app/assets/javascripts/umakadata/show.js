function showRadar(endpoint_id, evaluation_id) {
  $.getJSON("/endpoints/" + endpoint_id + "/radar", function(json) {
    var data = json['data']
    var avg = json['avg']
    var context = $("#radar")[0].getContext('2d');
    var labels = ["availability", "freshness", "operation", "usefulness", "validity", "performance"]
    new Chart(context, {
      type: 'radar',
      data: {
        labels: labels,
        datasets: [
          {
              label: "Target",
              backgroundColor: "rgba(151,187,205,0.2)",
              borderColor: "rgba(151,187,205,1)",
              pointBorderColor: "rgba(151,187,205,1)",
              pointBackgroundColor: "#fff",
              data: data
          },
          {
              label: "Average",
              backgroundColor: "rgba(220,220,220,0.5)",
              borderColor: "rgba(220,220,220,1)",
              pointBorderColor: "rgba(220,220,220,1)",
              pointBackgroundColor: "#fff",
              data: avg
          }
        ]
      },
      options: {
        responsive: true,
      }
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
    var context = $("#score_history");
    var lineChart = new Chart(context, {
      type: 'line',
      data: json,
      options: {
        datasetFill: false
      }
    });
  });
}
