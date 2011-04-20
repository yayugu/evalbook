$(function(){
  $("#kumihan").submit(function(e){
    $('#after-kumihan-message').empty().append("<img src=../load.gif /> 送信中...");
    $.post(
      "../view-post",
      {'display_inch': $('input[name="display_inch"]').val(),
       'pixel_longer': $('input[name="pixel_longer"]').val(),
       'pixel_shorter': $('input[name="pixel_shorter"]').val(),
       'pixel_statusbar_height': $('input[name="pixel_statusbar_height"]').val(),
       'fontsize': $('input[name="fontsize"]').val(),
       'angle': $('input[name="angle"]:checked').val(),
       'title': $('input[name="title"]').val()
      },
      function(data, status){
        $('#after-kumihan-message')
          .empty().append(data);
      },
      'html'
    );
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
    $('#fontsize').attr("value", "11.0");
  });


});
