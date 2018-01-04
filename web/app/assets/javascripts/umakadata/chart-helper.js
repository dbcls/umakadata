function formatDate(label) {
  var clickedDate = new Date(label);
  return ("0" + (clickedDate.getUTCMonth() + 1)).slice(-2) + "/" + ("0" + clickedDate.getUTCDate()).slice(-2);
}

function make_scale_options() {
  return {
    scales: {
      yAxes: [{
        ticks: {
          max: 100,
          min: 0
        }
      }]
    }
  }
}
