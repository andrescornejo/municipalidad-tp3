// /* Open */
// function openNav() {
//     document.getElementById("myNav").style.height = "100%";
//   }
  
//   /* Close */
//   function closeNav() {
//     document.getElementById("myNav").style.height = "0%";
//   }
   
//   $('.datepicker').datepicker({
//     format: 'yyyy/mm/dd',
//     startDate: '-1m',
//     autoclose: true,
// });

// $(window).load(function(){   
//   $("#jtCreate").show();
//   $("#jtUpdate").hide();
//   $("#jtDelete").hide(); 
// })

$("#dropCreate").click(function () {
  $("#jtCreate").show();
  $("#jtUpdate").hide();
  $("#jtDelete").hide();
});
$("#dropUpdate").click(function () {
  $("#jtCreate").hide();
  $("#jtUpdate").show();
  $("#jtDelete").hide();
});
$("#dropDelete").click(function () {
  $("#jtCreate").hide();
  $("#jtUpdate").hide();
  $("#jtDelete").show();
});

var setCreate = function () {
  var currentUseCase = document.getElementById('currentUseCase');
  currentUseCase.value = 'Create';
}
var setUpdate = function () {
  var currentUseCase = document.getElementById('currentUseCase');
  currentUseCase.value = 'Update';
}
var setDelete = function () {
  var currentUseCase = document.getElementById('currentUseCase');
  currentUseCase.value = 'Delete';
}