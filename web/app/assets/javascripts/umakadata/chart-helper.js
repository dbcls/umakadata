function formatDate(label) {
  var clickedDate = new Date(label);
  return ("0" + (clickedDate.getMonth() + 1)).slice(-2) + "/" + ("0" + clickedDate.getDate()).slice(-2);
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
