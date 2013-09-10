/* 
	The MIT License (MIT)

	Copyright (c) 2011 Jason Fill (@jasonfill)
	
	Permission is hereby granted, free of charge, to any person obtaining a copy of this software and 
	associated documentation files (the "Software"), to deal in the Software without restriction, including
	without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
	copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the 
	following conditions:
	
	The above copyright notice and this permission notice shall be included in all copies or substantial 
	portions of the Software.
	
	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT 
	NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
	IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, 
	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE 
	OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
$(function() {
		
		var tab_counter = 0;
		var loadResourceUrl = "";
		
		$( "#options" ).accordion({collapsible:true, autoHeight:false});
		
		// tabs init with a custom tab template and an "add" callback filling in the content
		var $tabs = $( "#workspace-tabs").tabs({
			tabTemplate: "<li><a href='#{href}'>#{label}</a> <span class='ui-icon ui-icon-close'>Remove Tab</span></li>",
			add: function( event, ui ) {
				
				// get the contents of the new panel...
				$.get(loadResourceUrl, function(data) {
				  $( ui.panel ).append( "<p>" + data + "</p>" );
					$tabs.tabs("select", tab_counter);
				});
				
			}
		});
		
		$('.add-tab').click(function(e){
			e.preventDefault();
			var tab_title = $(this).attr('rel');
			loadResourceUrl = $(this).attr('href');
			tab_counter++;
			$tabs.tabs( "add", "#tabs-" + tab_counter, tab_title );
		});
		
		$( "#workspace-tabs span.ui-icon-close" ).live( "click", function() {
			var index = $( "li", $tabs ).index( $( this ).parent() );
			$tabs.tabs( "remove", index );
		});
		
		$('form').live("submit", function(e){
			e.preventDefault();
			var formId = $(this).attr('id');							
			$('#result-' + formId).html('<div class="communicating"><img src="twiliologo-animated.gif" /><h3>Please hold...communicating with Twilio.</h3></div>');
			$('#result-' + formId).show();
			
			var formData = $(this).serialize();
			formData = formData + '&accountsid=' + $('#accountsid').val() + '&authtoken=' + $('#authtoken').val() + '&defaultformat=' + $('#defaultformat').val();
			
			$.post("ProcessRequest.cfm", formData , function(data) {
				 $('#result-' + formId).html(data);
			 });
		});

	});