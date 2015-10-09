$(function() {
  var context = $("#radar")[0].getContext("2d");
  new Chart(context).Radar({
    labels: ["availability", "freshness", "operation", "usefulness", "validity", "performance"],
    datasets: [
      {
          label: "Pathway Commons @Malaga",
          fillColor: "rgba(151,187,205,0.2)",
          strokeColor: "rgba(151,187,205,1)",
          pointColor: "rgba(151,187,205,1)",
          pointStrokeColor: "#fff",
          pointHighlightFill: "#fff",
          pointHighlightStroke: "rgba(220,220,220,1)",
          data: [75, 69, 64, 51, 56, 80]
      },
      {
          label: "Average",
          fillColor: "rgba(220,220,220,0.5)",
          strokeColor: "rgba(220,220,220,1)",
          pointColor: "rgba(220,220,220,1)",
          pointStrokeColor: "#fff",
          pointHighlightFill: "#fff",
          pointHighlightStroke: "rgba(151,187,205,1)",
          data: [58, 48, 40, 69, 50, 45]
      }
  ]
}, {
  scaleOverride: true,
  scaleSteps: 11,
  scaleStepWidth: 10,
  scaleStartValue: 0,
});

});
