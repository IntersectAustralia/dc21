// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require_tree .

// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(function () {

  // datepicker event triggers for dropdowns

  $(document).on('click.dropdown touchstart.dropdown.data-api', '.ui-datepicker, .ui-datepicker-prev, .ui-datepicker-next, .ui-datepicker-current', function (e) { e.stopPropagation() });

  // NOTIFICATIONS

  var alert_div = $('#alert');
  if (alert_div.length > 0) {
    alert_div.slideDown();
    $('#content_wrapper').addClass('notification');
    $('#footer').addClass('notification');

    $("#close_alert").click(function () {
      alert_div.slideUp();
      $('#content_wrapper').removeClass('notification');
      $('#footer').removeClass('notification');
    });
  }

  var notice = $('#notice');
  if (notice.length > 0) {
    notice.slideDown();
    $('#content_wrapper').addClass('notification');
    $('#footer').addClass('notification');

    $("#close_notice").click(function () {
      notice.slideUp();
      $('#content_wrapper').removeClass('notification');
      $('#footer').removeClass('notification');
    });
  }

  // FACETED SEARCH

  $("#drop4, .searchcategory").live("click", function () {
    var facetedsearch = $("#faceted_search").height();
    var contentcontainer = $("#content_container").height();
    if ((facetedsearch + 80) > contentcontainer) {
      $("#content_container").height(facetedsearch +115);
    } else {
      $("#content_container").css("height", "auto");
      facetedsearch = $("#faceted_search").height();
      contentcontainer = $("#content_container").height();
      if ((facetedsearch + 80) > contentcontainer) {
        $("#content_container").height(facetedsearch +115);
      }
    }
  });


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
        $("#drop3").html("<b>"+cartcount + " File in Cart</b> " + "( " + bytesToSize(window.cart_size) + " )" + " <span class=\"caret\"></span>");
      }
      else {
        $("#drop3").html("<b>"+cartcount + " Files in Cart</b> " + "( " + bytesToSize(window.cart_size) + " )" + " <span class=\"caret\"></span>");
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
        $('#all_data_files_form').submit();
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

  // ACCOUNT MENU
  $('#accountmenu_container').hide();
  $('#accountmenu').click(function (event) {
    var accountmenu = $('#accountmenu').width() + 45;
    $('#accountmenu_container').css('width', accountmenu);
    $('#accountmenu_container').slideToggle('normal', function () {
    });
    $('#accountmenu').toggleClass('active');
  });

  $('#accountmenu_container').click(function (event) {
    event.stopPropagation();
  });
  $('#accountmenu').click(function (event) {
    event.stopPropagation();
  });

  $('html').click(function () {
    $('#accountmenu_container').hide();
    $('#accountmenu').removeClass('active');
  });

  // dev info footer
  $('#dev').click(function (event) {
    $('#devinfo').slideToggle('fast', function () {
    });
    $('#footer').toggleClass('active');
    $('#content_wrapper').toggleClass('devinfo');
  });


  // makes any input with attribute datepicker=true have a datepicker
  $('input[datepicker="true"]').datepicker({
    dateFormat:'yy-mm-dd',
    showOn:'both',
    changeMonth:true,
    changeYear:true,
    currentText:'Show current month',
    showButtonPanel:true,
    autoSize:true
  });

});


// SCROLLING HEADER & NOTIFICATIONS
var checkonScroll = true;
$('#notice, #alert').live("click", function () {
  $('#content_wrapper').removeClass('scrollnotification');
  $('#footer').removeClass('scrollnotification');
  checkonScroll = false;
});

$(window).scroll(function (e) {
  var scrollNotifications = 1;
  var scrollHeader = 48.75;
  var scrollNotice = '#notice';
  var scrollAlert = '#alert';
  var scrollHed = '#header';
  $al = $(scrollNotice + "," + scrollAlert);
  $el = $(scrollHed);
  position = $el.position();
  notposition = $al.position();

  if ($(this).scrollTop() > scrollHeader && $el.css('position') != 'fixed') {
    $('#content_wrapper').addClass('scrollheader');
    $('#footer').addClass('scrollheader');
  } else if ((position.top < scrollHeader) && ($el.css('position') != 'relative')) {
    $('#content_wrapper').removeClass('scrollheader');
    $('#footer').removeClass('scrollheader');
  }
  if (!checkonScroll) {
    return;
  }

  if ($('#notice, #alert').length > 0) {
    if ($(this).scrollTop() > scrollNotifications && $al.css('position') != 'fixed') {
      $('#content_wrapper').addClass('scrollnotification');
      $('#footer').addClass('scrollnotification');
    } else if ((notposition.top < scrollNotifications) && ($al.css('position') != 'relative')) {
      $('#content_wrapper').removeClass('scrollnotification');
      $('#footer').removeClass('scrollnotification');
    }
  }
});

