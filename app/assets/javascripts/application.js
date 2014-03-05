// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require bootsy
//= require jquery-ui
//= require_tree .
//= require select2
//= require underscore

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

    $("#header").delegate("#close_notice", "click", function(){
      $(this).parent().stop('true');
      $(this).parent().slideUp();
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
  $("[id^=add_cart_item]").on('click', function(){
    if (!$(this).hasClass('disabled')) {
      var id = $(this).attr('data_file');
      var file_size = $(this).attr('file_size');
      $.ajax({
        url: '/cart_items/add_single',
        type: 'post',
        async: false,
        dataType: 'json',
        data: {id: id, file_size: file_size},
        success: function(data){
          if (data.status == '200') {
            var link_identifier = "#add_cart_item_" + id;
            $(link_identifier).addClass("disabled");
            $(link_identifier).attr('id', "add_cart_item_disabled");
            incrementCartCount(file_size);
            renderNotice(data.notice);
            $("#drop3").attr("data-toggle", "dropdown");
          } else if (data.status == '422') {
            renderNotice(data.notice);
          }
        },
        error: function(){
          console.log("Something went wrong");
        }
      });
    }
  });

  function incrementCartCount(file_size){
    var cartCount = parseInt($("#drop3").attr('total_items'));
    cartCount++;
    $("#drop3").attr('total_items', cartCount);
    window.cart_size += parseInt(file_size, 10);
    if (cartCount == 1)
      $("#drop3").html("<b>"+ cartCount + " File in Cart</b> " + "( " + bytesToSize(window.cart_size) + " )" + " <span class=\"caret\"></span>");
    else
      $("#drop3").html("<b>"+ cartCount + " Files in Cart</b> " + "( " + bytesToSize(window.cart_size) + " )" + " <span class=\"caret\"></span>");
  }

  function renderNotice(html){
    var $notice = $("#notice");
    if($notice.length){
      $notice.remove();
    }
    $("#header").prepend(html);
  }

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
    showOn:'button',
    changeMonth:true,
    changeYear:true,
    currentText:'Show current month',
    closeText:'Close',
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
    $('#owner_logo_container').height(20);
  } else if ((position.top < scrollHeader) && ($el.css('position') != 'relative')) {
    $('#content_wrapper').removeClass('scrollheader');
    $('#footer').removeClass('scrollheader');
    $('#owner_logo_container').height(60);
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

