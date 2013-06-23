function tableResize(){
	//可変対象となるtable
	var className = ".hDivBox";

	//長さをとってくるtable
	var getclassName = ".bDiv";

	//fixさせるテーブルの数
	var num = parseInt($(className).length);
	//セレクタを生成して配列にセット

	//eq関数用の変数
	var j;

	//セルの長さ
	var cell;

	//セルのwidth
	var cellWidth;

	//tableのwidth
	var tableWidth;

	//ループ用
	var i;
	var k;

	//最小サイズ
	var min = 20;

	//テーブルごとにリサイズ処理する
	for(i = 0;i < num;i++){
		cell = "";
		tableWidth = "";
		cellWidth = "";

		cell = parseInt($(className).eq(i).find("tr th").length);

		var userAgent = window.navigator.userAgent.toLowerCase();
				
		for(k = 0;k < cell;k++){
			if($(getclassName).find("tr td").eq(k).css("display") == "none"){
				continue;
			}

			cellWidth = 0;

			//chromeはなぜか1px不明なwidthをとられる
			if(userAgent.indexOf('chrome') != -1){
				cellWidth = 
					$(getclassName).eq(i).find("tr td").eq(k).outerWidth() -
					parseInt($(getclassName).eq(i).find("tr td").eq(k).css("border-left-width")) -
					parseInt($(getclassName).eq(i).find("tr td").eq(k).css("border-right-width")) + 1;
			//safariはouterWidthでborderが取れないのかも
			}else if (userAgent.indexOf('safari') != -1) {
				cellWidth = 
					$(getclassName).eq(i).find("tr td").eq(k).outerWidth();
			//その他
			}else{
				cellWidth = 
					$(getclassName).eq(i).find("tr td").eq(k).outerWidth() -
					parseInt($(getclassName).eq(i).find("tr td").eq(k).css("border-left-width")) -
					parseInt($(getclassName).eq(i).find("tr td").eq(k).css("border-right-width"));
			}

			if(cellWidth < min){
				$(getclassName).eq(i).find("tr td").eq(k).css("width",min)
				cellWidth = min;
			}
			$(className).eq(i).find("tr th").eq(k).css("width",(cellWidth));
		}

		tableWidth = parseInt($(getclassName).eq(i).innerWidth());
		$(className).eq(i).find("table").css("width",'100%');

	}
}