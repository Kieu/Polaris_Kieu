google.load("feeds", "1");

function initialize() {
	
  var feedurl = "http://www.septeni-holdings.co.jp/cp.xml";
  var feed = new google.feeds.Feed(feedurl);
  feed.setNumEntries(7);
  feed.load(dispfeed);

  function dispfeed(result){
    if (!result.error){
      var container = document.getElementById("feed");
      var htmlstr = "";
      /*htmlstr += '<h2><a href="' + result.feed.link + '">' + result.feed.title + '</a></h2>';
      htmlstr += "<p>" + result.feed.description + "</p>";*/

     htmlstr += "<ul>";
      for (var i = 0; i < result.feed.entries.length; i++) {
        var entry = result.feed.entries[i];
				
				var is_publicities = /publicities/.test(entry.link);
				
        htmlstr += "<li class=" + (is_publicities ? 'txtlist2' : 'txtlist') + ">" + (is_publicities ? "<span class=listset>" : "<a href='" + entry.link + "' target=_blank><span class=listset>");
				
				 var strdate = createDateString(entry.publishedDate);
				  var test = createDateString(entry.author);
					
					var categorie = entry.categories[i];
				 
        htmlstr += "<span class=listdate>" + strdate + "</span>";
				
        htmlstr += '<span class=listtit>' + entry.title + '</span>' + (is_publicities ? '' : '</a>');

       
        htmlstr += "</span></li>"
      }
      htmlstr += "</ul>";

       container.innerHTML = htmlstr;
    }else{
       alert(result.error.code + ":" + result.error.message);
    }
  }
}

function createDateString(publishedDate){
  var pdate = new Date(publishedDate);

  var pday = pdate.getDate();
  var pmonth = pdate.getMonth() + 1;
  var pyear = pdate.getFullYear();
  var phour = pdate.getHours();
  var pminute = pdate.getMinutes();
  var psecond = pdate.getSeconds();
  var strdate = pyear + "/" + pmonth + "/" + pday;

  return strdate;
}

google.setOnLoadCallback(initialize);
