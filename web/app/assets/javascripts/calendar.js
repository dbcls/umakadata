$(function(){
  $('#calendar').datepicker({
    autoclose: true,
    startDate: "#{@start_date}",
    endDate: new Date(),
    format: 'yyyy-mm-dd',
    todayHighlight: true
  });
});
