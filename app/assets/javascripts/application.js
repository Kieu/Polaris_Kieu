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

  window.User = {
    completeProjectLine: function(data) {
      var html, watchs;

      html = "";
      html += "<div class='user_info'><a href=/users/" + data[1] + ">" + data[0] + "</a>" + "</div>";
      
      return html;
    },
    completeProjects: function(el) {
      var hash;

      hash = {
        minChars: 1,
        delay: 50,
        width: 350,
        scroll: true,
        search_type: "user",
        formatItem: function(data, i, total) {
          return User.completeProjectLine(data);
        }
        
      };
      //console.log(hash);
      return $(el).autocomplete("/users/search", hash);
    }
  };