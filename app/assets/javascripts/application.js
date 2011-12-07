// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require_tree .

document.write('<script src="http://' + (location.host || 'localhost').split(':')[0] + ':35729/livereload.js?snipver=1"></' + 'script>')
// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
//

$(window).load(function() {

  // NOTIFICATIONS //////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////

  $('#accountmenu_container').hide();

  $(function () {
    var alert = $('#alert');
    if (alert.length > 0) {
      alert.slideDown();
      $('#content_wrapper').addClass('notification');
      $('#footer').addClass('notification');

      var alerttimer = window.setTimeout(function() {
        alert.slideUp();
        $('#content_wrapper').removeClass('notification');
        $('#footer').removeClass('notification');
      }, 900000);
      $("#alert").click(function () {
        window.clearTimeout(alerttimer);
        alert.slideUp();
        $('#content_wrapper').removeClass('notification');
        $('#footer').removeClass('notification');
      });
    }
  });

  $(function () {
    var notice = $('#notice');
    if (notice.length > 0) {
      notice.slideDown();
      $('#content_wrapper').addClass('notification');
      $('#footer').addClass('notification');

      var noticetimer = window.setTimeout(function() {
        notice.slideUp();
        $('#content_wrapper').removeClass('notification');
        $('#footer').removeClass('notification');
      }, 9000000);
      $("#notice").click(function () {
        window.clearTimeout(noticetimer);
        notice.slideUp();
        $('#content_wrapper').removeClass('notification');
        $('#footer').removeClass('notification');
      });
    }
  });

  // ACCOUNT MENU ///////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////

  $('#accountmenu').click(function(event) {
    var accountmenu = $('#accountmenu').width() + 45;
    $('#accountmenu_container').css('width', accountmenu );
    $('#accountmenu_container').slideToggle('normal', function() {} );
    $('#accountmenu').toggleClass('active');
  });

  $('#accountmenu_container').click(function(event){
    event.stopPropagation();
  });
  $('#accountmenu').click(function(event){
    event.stopPropagation();
  });

  $('html').click(function() {
    $('#accountmenu_container').hide();
    $('#accountmenu').removeClass('active');
  });

  // DEV FOOTER /////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////

  $('#dev').click(function(event) {
    $('#devinfo').slideToggle('fast', function() {} );
    $('#footer').toggleClass('active');
    $('#content_wrapper').toggleClass('devinfo');
  });

  // SEARCH /////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////


  $('#search').click(function(event) {
    $('.searchcontainer').fadeToggle('normal', function() {} );
    $("#search").animate({width:'toggle'},550);
    $('.searchactions').fadeToggle('normal', function() {} );
    $('#newdataentry').toggleClass('bluebutton');
    $('#newdataentry').toggleClass('whitebutton');
  });
  $('.searchclose').click(function(event) {
    $('.searchcontainer').fadeToggle('normal', function() {} );
    $("#search").animate({width:'toggle'},550);
    $('.searchactions').fadeToggle('normal', function() {} );
    $('#newdataentry').toggleClass('bluebutton');
    $('#newdataentry').toggleClass('whitebutton');
  });

});

// SCROLLING HEAD//ER & NOTIFICATIONS ///////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////

var checkonScroll = true;
$('#notice, #alert').live("click", function() {
  $('#content_wrapper').removeClass('scrollnotification');
  $('#footer').removeClass('scrollnotification');
  checkonScroll = false;
});

$(window).scroll(function(e){
  var scrollNotifications = 1;
  var scrollHeader = 48.75;
  var scrollNotice = '#notice';
  var scrollAlert = '#alert';
  var scrollHed = '#header';
  $al = $(scrollNotice + "," + scrollAlert);
  $el = $(scrollHed);
  position = $el.position();
  notposition = $al.position();

  if ($(this).scrollTop() > scrollHeader && $el.css('position') != 'fixed'){
    $('#content_wrapper').addClass('scrollheader');
    $('#footer').addClass('scrollheader');
  } else if ((position.top < scrollHeader) && ($el.css('position') != 'relative')){
    $('#content_wrapper').removeClass('scrollheader');
    $('#footer').removeClass('scrollheader');
  }
  if (!checkonScroll) {
    return;
  };
  if ($('#notice, #alert').length > 0){
    if ($(this).scrollTop() > scrollNotifications && $al.css('position') != 'fixed'){
      $('#content_wrapper').addClass('scrollnotification');
      $('#footer').addClass('scrollnotification');
    } else if ((notposition.top < scrollNotifications) && ($al.css('position') != 'relative')){
      $('#content_wrapper').removeClass('scrollnotification');
      $('#footer').removeClass('scrollnotification');
    }
  }
});






