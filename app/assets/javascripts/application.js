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

  // NOTIFICATIONS

  var alert = $('#alert');
  if (alert.length > 0) {
    alert.slideDown();
    $('#content_wrapper').addClass('notification');
    $('#footer').addClass('notification');

    $("#close_alert").click(function () {
      alert.slideUp();
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


  // CART CONTENTS
  $("[id^=add_to_cart]").click(function (event) {
    $(this).off('click');
    $(this).attr('disabled', 'disabled');
    var cartcount = parseInt($("#drop3").text().trim().split(" ")[0]) + 1
      if (cartcount == 1) {
        $("#drop3").text(cartcount + " File in Cart");
      }
      else {
        $("#drop3").text(cartcount + " Files in Cart");
      }
  });

  //diable cart buttons unless there is something in the cart
    $('a[id^=cart_]').click(function (event) {
      var cartcount = parseInt($("#drop3").text().trim().split(" ")[0])
      if(cartcount == 0) {
        event.preventDefault();
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
    currentText:'Today',
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
  ;
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


