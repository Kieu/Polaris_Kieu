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
        scroll: false,
        formatItem: function(data, i, total) {
          return User.completeProjectLine(data);
        }
        
      };
      //console.log(hash);
      return $(el).autocomplete("/users/search", hash);
    }
  };

(function() {
  window.Client = {
    completeProjectLine: function(data) {
      var html, watchs;

      html = "";
      html += "<div class='info'><a href=/clients/edit/" + data[1] + ">" + data[0] + "</a>" + "</div>";
      return html;
    },
    completeProjects: function(el) {
      var hash;

      hash = {
        minChars: 1,
        delay: 50,
        width: 350,
        scroll: false,
        formatItem: function(data, i, total) {
          return Client.completeProjectLine(data);
        }
        
      };
      //console.log(hash);
      return $(el).autocomplete("/clients/search", hash).result(function(e, data, formatted) {
        location.href = "/clients/" + data[1];
        return false;
      });
    }
  };

  $(document).ready(function() {
    return Client.completeProjects(".searchbox input#search_client");
  });

}).call(this);