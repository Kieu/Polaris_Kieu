// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require_tree .
//= require highcharts
function index_of(haystack, needle) {
    for (var i = 0, l = haystack.length; i < l; ++i) {
        if( haystack[i].value === needle ) {
           return i;   
        }
    }
    return -1;
}

function reloadFlex(obj, urlAction, id, current_active, cname, maxlength) {
	$(obj)
    .flexOptions({
        url: urlAction,
        newp: 1
    }).flexReload();
    $(current_active).removeClass('active');
    $(id).addClass('active');
    var txt = '';
    if ($(id).text().length > maxlength)
    	txt = $(id).text().substring(0, maxlength) + '...';
    else
    	txt = $(id).text();
    $(cname).text(txt);
    
}
function ajaxCommon(urlAction, id, current_active, cname,arr_inner) {
    //location.href = urlAction;
    //return;
    if (prevent == true){
    	$("#change").click(function(){
			var array_inner = arr_inner.split(',');
    		$("#dvloader").css('display','');
    		$.ajax({
        		type: "GET",
        		url: urlAction,
        		dataType: "html"
    		}).done(function( data  ) {
            	for (i=0;i<array_inner.length;i++){
            		var inner_data = $(data).find(array_inner[i]);
            		$(array_inner[i]).html(inner_data.children());
            	}
            	$("#dvloader").css('display','none');
				$('input#keywords').quicksearch('div#clients_list tr', {
	        		"selector": "a.client_name"
				});
				$('input#keywords').quicksearch('div#promotions_list tr', {
					"selector": "a.promotion_name"
				});
				$(current_active).removeClass('active');
    			$(id).addClass('active');
        	});
        	prevent = false;
        	$('#prevent_change').colorbox.close();
        	$("#popup_prevent").remove();
		});
		$("#cancel_change").click(function(){
			$('#prevent_change').colorbox.close();
		});
		$.colorbox({
			width: "30%",
			inline: true,
			escKey: false,
			overlayClose: false,
			href: "#prevent_change",
		})
    }else{
    	var array_inner = arr_inner.split(',');
    		$("#dvloader").css('display','');
    		$.ajax({
        		type: "GET",
        		url: urlAction,
        		dataType: "html"
    		}).done(function( data  ) {
            	for (i=0;i<array_inner.length;i++){
            		var inner_data = $(data).find(array_inner[i]);
            		$(array_inner[i]).html(inner_data.children());
            	}
            	$("#dvloader").css('display','none');
				$('input#keywords').quicksearch('div#clients_list tr', {
	        		"selector": "a.client_name"
				});
				$('input#keywords').quicksearch('div#promotions_list tr', {
					"selector": "a.promotion_name"
				});
				$(current_active).removeClass('active');
    			$(id).addClass('active');
        	});
    }
}
