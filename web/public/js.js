$(function(){
  $("#kumihan").submit(function(e){
    $('#after-kumihan-message').empty().append("<img src=../load.gif /> 送信中...");
    $.ajax({
      url: "../view-get",
      type: "GET",
      data: $(this).serialize(),
      success: function(data){
        $('#after-kumihan-message')
          .empty().append("success! <a href='" + data + "'>PDF</a>");
      },
      error: function(xhr, textStatus){
        $('#after-kumihan-message')
          .empty().append("failed..." + xhr.status);
      }    
    });
  });

  $("#iPhone").click(function(e){
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
    $('#fontsize').attr("value", "9.0");
  });
});
