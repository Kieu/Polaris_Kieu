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

	//テーブルごとにリサイズ処理する
	for(i = 0;i < num;i++){
		cell = parseInt($(className).eq(i).find("tr th").length);
		
		tableWidth = parseInt($(getclassName).eq(i).innerWidth());
		$(className).eq(i).find("table").css("width",tableWidth -18);
		
		for(k = 0;k < cell;k++){
			cellWidth = 0;
			cellWidth = $(getclassName).eq(i).find("tr td").eq(k).innerWidth();
			$(className).eq(i).find("tr th").eq(k).css("width",cellWidth);
		}
	}
}