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

		$(className).eq(i).find("table").css("width",'100%');

	}
}