function showRadar(endpoint_id, evaluation_id) {
  $.getJSON("/endpoints/" + endpoint_id + "/radar", function(json) {
    var data = json['data']
    var avg = json['avg']
    var context = $("#radar")
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
    var labels = json['labels'];
    var datasets = json['datasets'];
    var data = {
      labels: labels,
      datasets: [
        {
          label: datasets[0]['label'],
          fill: false,
          backgroundColor: 'rgba(220,220,220,0.2)',
          borderColor: 'rgba(220,220,220,1)',
          pointBorderColor: 'rgba(220,220,220,1)',
          pointBackgroundColor: '#fff',
          data: datasets[0]['data']
        },
        {
          label: datasets[1]['label'],
          fill: false,
          backgroundColor: "rgba(54,162,235,0.2)",
          borderColor: "rgba(54,162,235,1)",
          pointBorderColor: "rgba(54,162,235,1)",
          pointBackgroundColor: "#fff",
          data: datasets[1]['data']
        },
        {
          label: datasets[2]['label'],
          fill: false,
          backgroundColor: "rgba(255,99,132,0.2)",
          borderColor: "rgba(255,99,132,1)",
          pointBorderColor: "rgba(255,99,132,1)",
          pointBackgroundColor: "#fff",
          data: datasets[2]['data']
        },
        {
          label: datasets[3]['label'],
          fill: false,
          backgroundColor: "rgba(255,206,86,0.2)",
          borderColor: "rgba(255,206,86,1)",
          pointBorderColor: "rgba(255,206,86,1)",
          pointBackgroundColor: "#fff",
          data: datasets[3]['data']
        },
        {
          label: datasets[4]['label'],
          fill: false,
          backgroundColor: "rgba(75,192,192,0.2)",
          borderColor: "rgba(75,192,192,1)",
          pointBorderColor: "rgba(75,192,192,1)",
          pointBackgroundColor: "#fff",
          data: datasets[4]['data']
        },
        {
          label: datasets[5]['label'],
          fill: false,
          backgroundColor: "rgba(231,233,237,0.2)",
          borderColor: "rgba(231,233,237,1)",
          pointBorderColor: "rgba(231,233,237,1)",
          pointBackgroundColor: "#fff",
          data: datasets[5]['data']
        }
      ]
    }
    var lineChart = new Chart(context, {
      type: 'line',
      data: data,
      options: {
        scales: {
          yAxes: [
            {
              ticks: {
                max: 110,
                min: 0,
              }
            }
          ]
        },
        datasetFill: false
      }
    });
  });
}
