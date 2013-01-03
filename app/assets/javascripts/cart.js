$(function () {

// CART MENU
  $('#drop3').click(function (event) {
    var accountmenu = $('#drop3').width() + 24;
    $('#cart-actions').css('width', accountmenu);
  });

  // CART CONTENTS
  $("[id^=add_cart_item]").click(function (event) {
    if (!$(this).hasClass("disabled")) {
      $(this).addClass("disabled");
      $(this).attr('id', "add_cart_item_disabled");
      var cartcount = parseInt ($("#drop3").text().trim().split(" ")[0]) + 1;
        window.cart_size += parseInt($(this).data('file-size'), 10);

      if (cartcount == 1) {
        $("#drop3").html("<b>"+cartcount + " File in Cart</b> <br>" + bytesToSize(window.cart_size) + " <span class=\"caret\"></span>");
      }
      else {
        $("#drop3").html("<b>"+cartcount + " Files in Cart</b> <br>" + bytesToSize(window.cart_size) + " <span class=\"caret\"></span>");
      }
      //  disable 'add all' button if all others have been clicked
      //var all_items = $("a[id^=add_cart_item]").length
      //var used_items = $("a[id^=add_cart_item_disabled]").length
      //if (used_items == all_items) {
     //   $('#add_all_to_cart').addClass("disabled");
      //}
      // enable cart menu dropdown, as it is no longer empty
      $("#drop3").attr("data-toggle", "dropdown");
      $("#notice").slideUp();
    }
    else {
      return false;
    }
  });

  function bytesToSize(bytes) {
    var sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
    if (bytes == 0) return '0 Bytes';
    var i = parseInt(Math.floor(Math.log(bytes) / Math.log(1024)));
    var dec_places =0;
    if (i >= 2) {
      dec_places = 2;
    }
    var num =  (bytes / Math.pow(1024, i)).toFixed(dec_places);
    return num+' ' + sizes[[i]];
  }


  $('#add_all_to_cart').click(function (event) {
    if (!$(this).hasClass("disabled")) {
      if (confirm('Do you really want to add all files to your cart?')) {
        $(this).addClass("disabled");
      }
      else {
        return false;
      }
      $("#notice").slideUp();
    }
    else {
      return false;
    }
  });
});