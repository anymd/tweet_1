$(document).ready(function() {

  $.get(location.pathname+'/tweets', function(html) {
    $('.tweets').html(html);
  });


  $.get(location.pathname+'/follower_count', function(html) {
    $('.follower_count').html(html);
  });
  
});
