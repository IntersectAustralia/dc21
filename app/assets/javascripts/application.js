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

//LiveReload is causing 30s delays on windows machines. disabled until this can be unbroken
//document.write('<script src="http://' + (location.host || 'localhost').split(':')[0] + ':35729/livereload.js?snipver=1"></' + 'script>')

// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
//

$(window).load(function() {

  var hidden_selects = true;

  // NOTIFICATIONS //////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////


  $('#accountmenu_container').hide();

  $(function () {
    var alert = $('#alert');
    if (alert.length > 0) {
      alert.slideDown();
      $('#content_wrapper').addClass('notification');
      $('#footer').addClass('notification');

//      var alerttimer = window.setTimeout(function() {
//        alert.slideUp();
//        $('#content_wrapper').removeClass('notification');
//        $('#footer').removeClass('notification');
//      }, 10000);
      $("#close_alert").click(function () {
//        window.clearTimeout(alerttimer);
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

//      var noticetimer = window.setTimeout(function() {
//        notice.slideUp();
//        $('#content_wrapper').removeClass('notification');
//        $('#footer').removeClass('notification');
//      }, 10000);
      $("#close_notice").click(function () {
//        window.clearTimeout(noticetimer);
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

  // SEARCH TOGGLE //////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////

  $('#searchtoggle').click(function(event) {
    $('.facetedsearch').toggleClass('search');
    return false;
  });

  $('#searchtoggle').click(function(event) {
    $('#exploredata').toggleClass('search');
    $('.exploredata').toggleClass('search');
    $('.email').toggle();
  });

  // FACETED SEARCH /////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////

  //$('.date').hide();
  //$('.time').hide();
  //$('.facility').hide();
  //$('.variable').hide();
    
  $('#date').click(function(event) {
    $('.date').slideToggle();
    $(this).toggleClass('current');
  });

  $('#time').click(function(event) {
    $('.time').slideToggle();
    $(this).toggleClass('current');
  });

  $('#facility').click(function(event) {
    $('.facility').slideToggle();
    $(this).toggleClass('current');
  });

  $('#variable').click(function(event) {
    $('.variable').slideToggle();
    $(this).toggleClass('current');
  });



  // DOWNLOAD MULTIPLE TOGGLE ///////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////
  
  $('#downloadtoggle').click(function(event) {
    if (hidden_selects == true) {
      hidden_selects = false;
      $('.select').show();
      display_actions();
    } else {
      hidden_selects = true;
      $('.select').hide();
      $('#download_actions').hide();
    }
    return false;
  });

  // SHOW DOWNLOAD BUTTONS ON SELECTION ////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////
  $('input:checkbox', '#exploredata').click(function () {
    display_actions();
  });


  $('input[datepicker="true"]').datepicker({
    dateFormat: 'yy-mm-dd',
    showOn: 'both',
    changeMonth: true,
    changeYear: true,
    currentText: 'Today',
    showButtonPanel: true,
    autoSize: true
  });

});

  // SELECT ALL / NONE - DOWNLOAD MULTIPLE //////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////

function display_actions() {
  var buttonsChecked = $('#exploredata').find('input:checkbox:checked');
  if (buttonsChecked.length) {
    $('#download_actions').show();
  } else {
    $('#download_actions').hide();
  }
}

function selectToggle(checked, form) {
     var dataForm = document.forms[form];
     for( var i=0; i < dataForm.length; i++ ) { 
          if(checked) {
               dataForm.elements[i].checked = "";
               $('#download_actions').hide();
          }
          else {
               dataForm.elements[i].checked = "checked";
               $('#download_actions').show();

          }
     }
}

  // SCROLLING HEADER & NOTIFICATIONS ///////////////////////////////////////////
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


