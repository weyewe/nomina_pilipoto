$(document).ready(function(){

/*  $.getJSON('http://api.twitter.com/1/statuses/user_timeline/fresh_creations.json?count=2&callback=?', function(tweets){
    $("div#tweets_right").html(format_twitter(tweets, 'right', '2'));
    $("div#tweets_footer").html(format_twitter(tweets, 'footer', '1'));
  }); */
	
	$('div#box_close').click(function(){
		$(this).parent().stop(true, true).animate({top: '-59px'});
		$('div#wrapper').animate({top: '-30px'});
		$('body').css('background-position', '0px -30px');
	});


	$('div#menu ul li a').hover(
		function(){
			$(this).stop(true, true).animate({color: '#0d8dbd'});
		},
		function(){
			$(this).stop(true, true).animate({color: '#fff'});
		}
	);
	
	$('div#menu ul li.parent').hover(
		function(){
			$(this).css('border-bottom', '2px solid #0d8dbd');
		},
		function(){
			$(this).css('border-bottom', '0px');
		}
	);	

	$('div#menu ul li ul li a').hover(
		function(){
			$(this).stop(true, true).animate({color: '#0d8dbd'});
		},
		function(){
			$(this).stop(true, true).animate({color: '#444'});
		}
	);		
	
	$('div.readmore a, div.visit a').hover(
		function(){
			$(this).stop(true, true).animate({color: '#000', backgroundColor: '#f3d900'});
		},
		function(){
			$(this).stop(true, true).animate({color: '#fff', backgroundColor: '#000'});
		}
	);	
	
	$('input.submit').hover(
		function(){
			$(this).stop(true, true).animate({color: '#000', backgroundColor: '#f3d900'});
		},
		function(){
			$(this).stop(true, true).animate({color: '#fff', backgroundColor: '#000'});
		}
	);
	
	$('div.recent_work').hover(
		function () {
			$(this).find('div.recent_work_overlay').stop(true, true).fadeIn(500);
		},
		function () {
			$(this).find('div.recent_work_overlay').stop(true, true).fadeOut(500);
		}
	);
	
	$('div.recent_work_overlay').click(function(){
		$(this).prev('a').click();
	});	
	
	$('div.recent_work.only').hover(
		function () {
			$(this).find('div.recent_work_overlay_only').stop(true, true).fadeIn(500);
		},
		function () {
			$(this).find('div.recent_work_overlay_only').stop(true, true).fadeOut(500);
		}
	);
	
	$('div.recent_work_overlay_only').click(function(){
		$(this).prev('a').click();
	});
	
	$('#slider').anythingSlider({
	  // Appearance
	  width               : null,      // Override the default CSS width
	  height              : null,      // Override the default CSS height
	  resizeContents      : false,      // If true, solitary images/objects in the panel will expand to fit the viewport

	  // Navigation
	  startPanel          : 1,         // This sets the initial panel
	  hashTags            : false,      // Should links change the hashtag in the URL?
	  buildArrows         : true,      // If true, builds the forwards and backwards buttons
	  buildNavigation     : false,      // If true, buildsa list of anchor links to link to each panel
	  navigationFormatter : null,      // Details at the top of the file on this use (advanced use)
	  forwardText         : "&raquo;", // Link text used to move the slider forward (hidden by CSS, replaced with arrow image)
	  backText            : "&laquo;", // Link text used to move the slider back (hidden by CSS, replace with arrow image)

	  // Slideshow options
	  autoPlay            : false,      // This turns off the entire slideshow FUNCTIONALY, not just if it starts running or not
	  startStopped        : false,     // If autoPlay is on, this can force it to start stopped
	  pauseOnHover        : true,      // If true & the slideshow is active, the slideshow will pause on hover
	  resumeOnVideoEnd    : true,      // If true & the slideshow is active & a youtube video is playing, it will pause the autoplay until the video has completed
	  stopAtEnd           : false,     // If true & the slideshow is active, the slideshow will stop on the last page
	  playRtl             : false,     // If true, the slideshow will move right-to-left
	  startText           : "Start",   // Start button text
	  stopText            : "Stop",    // Stop button text
	  delay               : 3000,      // How long between slideshow transitions in AutoPlay mode (in milliseconds)
	  animationTime       : 600,       // How long the slideshow transition takes (in milliseconds)
	  easing              : "swing",    // Anything other than "linear" or "swing" requires the easing plugin
	  buildStartStop   : false
	});		

	$("li.slide1").filter(':not(.cloned)').find('a').colorbox({rel:'group1'});
	$("li.slide2").filter(':not(.cloned)').find('a').colorbox({rel:'group2'});
	$("li.slide3").filter(':not(.cloned)').find('a').colorbox({rel:'group3'});	

	jQuery('ul.sf-menu').superfish({ 
		delay:       1000,                            // one second delay on mouseout 
		animation:   {opacity:'show',height:'show'},  // fade-in and slide-down animation 
		speed:       'fast',                          // faster animation speed 
		autoArrows:  false,                           // disable generation of arrow mark-up 
		dropShadows: true                            // disable drop shadows 
	}); 
	
});