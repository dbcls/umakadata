var scoreData = [
  {
    value: 30,
    color: "#1D2088",
    highlight: "#6356A3",
    label: "Rank A"
  },
  {
    value: 80,
    color: "#00A0E9",
    highlight: "#00B9EF",
    label: "Rank B"
  },
  {
    value: 150,
    color: "#009944",
    highlight: "#3EB37",
    label: "Rank C"
  },
  {
    value: 80,
    color: "#FFF100",
    highlight: "#FFF462",
    label: "Rank D"
  },
  {
    value: 10,
    color: "#E60012",
    highlight: "#FF5A5E",
    label: "Rank E"
  }
];
var aliveData = [
  {
      value: 300,
      color: "#00A0E9",
      highlight: "#00B9EF",
      label: "Alive"
  },
  {
    value: 50,
    color: "#E60012",
    highlight: "#FF5A5E",
    label: "Dead"
  }
];
var avgData = {
  labels: ["2015/05", "2015/06", "2015/07", "2015/08", "2015/09", "2015/10"],
  datasets: [
    {
      label: "Total Score",
      fillColor: "rgba(0, 0, 0, 0.0)",
      strokeColor: "#1D2088",
      data: [65, 59, 80, 81, 56, 55]
    },
    {
      label: "Ontology",
      fillColor: "rgba(0, 0, 0, 0.0)",
      strokeColor: "#00A0E9",
      data: [30, 35, 40, 30, 40, 35]
    },
    {
      label: "Principles",
      fillColor: "rgba(0, 0, 0, 0.0)",
      strokeColor: "#009944",
      data: [70, 80, 70, 100, 80, 85]
    },
  ]
};
$(function() {
  var ontext =
  showPie($("#score")[0].getContext("2d"), scoreData);
  showPie($("#alive")[0].getContext("2d"), aliveData);
  showLine($("#avg")[0].getContext("2d"), avgData);
});
function showPie(context, data) {
  new Chart(context).Pie(data);
}
function showLine(context, data) {
  new Chart(context).Line(data, {
    bezierCurve: false,
  });
}
