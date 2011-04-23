$(function(){
  $("#kumihan").submit(function(e){
    $('#after-kumihan-message').empty().append("<img src=../load.gif /> 送信中...");
    $.get(
      "../view-get",
      $(this).serialize(),
      function(data, status){
        $('#after-kumihan-message')
          .empty().append("success! <a href='" + data + "'>PDF</a>");
      },
      'html'
    );
  });

  $("#iPhone").click(function(e){
    $('#source_url').attr("value", "http://localhost:9393/s-xml33.html");
    $('#display_inch').attr("value", "3.5");
    $('#pixel_longer').attr("value", "480");
    $('#pixel_shorter').attr("value", "320");
    $('#pixel_statusbar_height').attr("value", "20");
    $('#fontsize').attr("value", "9.0");
  });

  $("#iPad").click(function(e){
    $('#display_inch').attr("value", "8.5");
    $('#pixel_longer').attr("value", "1024");
    $('#pixel_shorter').attr("value", "768");
    $('#pixel_statusbar_height').attr("value", "20");
    $('#fontsize').attr("value", "11.0");
  });


});
