##_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
## Prefix Is MBF
##_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
use strict;

##
## BMPファイルを作成します。
##
sub MBF_PrintToBmp {
	my ($fileName, $cTable) = @_;

	## 画像データのサイズを取得する
	my $height = $#$cTable + 1;
	my $width  = $#{$cTable->[0]} + 1;

	## 出力用のファイルを開く
	open(W_FILE, '>' . $fileName) || return(0);
	binmode(W_FILE);

	## ファイルヘッダー部を出力する
	print W_FILE makeBmpFileHeader($width * $height * 3 + 54);

	## 情報ヘッダー部を出力する
	print W_FILE makeBmpInfoHeader($width, $height);

	## 画像データを出力する
	## 左下から右上に向かって記録される
	for(my $i = 0; $i < $height ; $i++) {
		for(my $j = 0 ; $j < $width ; $j++) {
			print W_FILE $cTable->[$i][$j];
		}
	}

	## ファイルを閉じる
	close(W_FILE);

}


##
## 指定座標に指定の色で点を打つ
## (x,y)とした場合
## 左下(0,0)、右下(width-1,0)、左上(0, height-1)、右上(width-1,height-1)
## となる
##
sub MBF_SetColorData {
	my ($x, $y, $color, $cTable) = @_;

	## 画像データ範囲のチェック
	return(0) if ( $x < 0 || $x > $#{$cTable->[0]} || $y < 0 || $y > $#$cTable );

	## 画像データを記録する
	$cTable->[$y][$x] = $color;
}


##
## BMPのファイルヘッダーを作成します。
## ファイルヘッダーサイズは 14Byte。
##
## @param1 BMPファイルの全サイズ(Byte)
##
sub makeBmpFileHeader {
	my ($fileSizeAll) = @_;

	return pack("aaL3", 'B', 'M', $fileSizeAll, 0, 54);
}

##
## BMPの情報ヘッダーを作成します。
##
## @param1 画像の幅(ピクセル単位)
## @param2 画像の高さ(ピクセル単位)
##
sub makeBmpInfoHeader {
	my($width, $height) = @_;

	return pack("L3S2L6", 40, $width, $height, 1, 24, 0, $width * $height * 3, 11808, 11808, 0, 0);
}


##
## BMPの画像データ部分を作成します。
##
## @param1 赤色の要素(0 ～ 255)
## @param2 緑色の要素(0 ～ 255)
## @param3 青色の要素(0 ～ 255)
##
sub MBF_MakeRgbData {
	my($red, $green, $blue) = @_;

	return pack("CCC", $blue % 256, $green % 256, $red % 256);
}


##
## 新規のカラーテーブルを取得します。
##
sub MBF_GetNewColorTable {
	my($width, $height, $color) = @_;

	## $width*3 は、4で割り切れる必要がある。
	return 0 if (($width * 3) % 4 != 0);

	## データ格納領域の初期化
	my $cTable = [];
	for my $i(0..$height-1) {
		$cTable->[$i] = [];
		for my $j(0..$width-1) {
			$cTable->[$i][$j] = $color;
		}
	}

	return $cTable;
}



##
## カラーテーブルをクリアします。
##
sub MBF_ClearColorTable {
	my($color, $cTable) = @_;
	map { map { $_ = $color } @$_  } @$cTable;
}



##
## 線分を描画する。
## (プレゼンハムのアルゴリズム)
## @param1 x1 線分の始点(X座標)
## @param2 y1 線分の始点(Y座標)
## @param3 x2 線分の終点(X座標)
## @param4 y2 線分の終点(Y座標)
## @param5 color 線分の色
##
sub MBF_DrawLine {
	my ($x1, $y1, $x2, $y2, $color, $cTable) = @_;

	my ($i, $x, $y, $dx, $dy, $addx, $addy);
	my $cnt = 0;

	## ＸＹ方向それぞれの距離を求め
	## addx、addyを決定する
	$dx = $x2 - $x1;
	if ($dx < 0){
		$addx = -1;
		$dx  *= -1;
	} else {
		$addx = 1;
	}

	$dy = $y2 - $y1;
	if ($dy < 0){
		$addy = -1;
		$dy  *= -1;
	} else {
		$addy = 1;
	}

	$x = $x1;
	$y = $y1;

	## ＸＹ方向それぞれの距離を比べる
	## Ｘ方向が長いならＸ方向を基準し、
	## そうでないならＹ方向を基準にする
	if ($dx > $dy){
		## Ｘ方向の距離の方が大きい
		for ($i = 0; $i < $dx; ++$i){
			MBF_SetColorData($x, $y, $color, $cTable);
			$cnt += $dy;
			if ($cnt >= $dx){
				$cnt -= $dx;
				$y   += $addy;
			}
			$x += $addx;
		}
	} else {
		## Ｙ方向の距離の方が大きい
		for ($i = 0; $i < $dy; ++$i){
			MBF_SetColorData($x, $y, $color, $cTable);
			$cnt += $dx;
			if ($cnt >= $dy){
				$cnt -= $dy;
				$x   += $addx;
			}
			$y += $addy;
		}
	}
}

##
## 円を描画する。
## ミッチェナーによる円描画のアルゴリズム
## @param1 xo 円の中心(X座標)
## @param2 yo 円の中心(Y座標)
## @param3 r  円の半径
## @param4 color  円周の色
##
sub MBF_DrawCircle {
	my ($xo, $yo, $r, $color, $cTable) = @_;
	my ($x, $y);

	$x = $r;
    $y = 0;
    while ($x >= $y){
		MBF_SetColorData($xo + $x, $yo + $y, $color, $cTable);
		MBF_SetColorData($xo + $x, $yo - $y, $color, $cTable);
		MBF_SetColorData($xo - $x, $yo + $y, $color, $cTable);
		MBF_SetColorData($xo - $x, $yo - $y, $color, $cTable);
		MBF_SetColorData($xo + $y, $yo + $x, $color, $cTable);
		MBF_SetColorData($xo + $y, $yo - $x, $color, $cTable);
		MBF_SetColorData($xo - $y, $yo + $x, $color, $cTable);
		MBF_SetColorData($xo - $y, $yo - $x, $color, $cTable);

		$r -= ($y << 1) - 1;
		if ($r < 0){
			$r += ($x - 1) << 1;
			$x--;
		}
		$y++;
	}
}

##
## 楕円を描画する
##
## @param1 xo 楕円の中心(X座標)
## @param2 yo 楕円の中心(Y座標)
## @param3 rx X軸方向の半径
## @param4 ry Y軸方向の半径
## @param5 color 円周の色
##
sub MBF_DrawEllipse {
	my ($xo, $yo, $rx, $ry, $color, $cTable) = @_;
	my ($x, $x1, $y, $y1, $r);

	if ($rx > $ry){
		$x = $r = $rx;
		$y = 0;
		while ($x >= $y) {
			$x1 = int($x * $ry / $rx);
			$y1 = int($y * $ry / $rx);
			MBF_SetColorData($xo + $x, $yo + $y1, $color, $cTable);
			MBF_SetColorData($xo + $x, $yo - $y1, $color, $cTable);
			MBF_SetColorData($xo - $x, $yo + $y1, $color, $cTable);
			MBF_SetColorData($xo - $x, $yo - $y1, $color, $cTable);
			MBF_SetColorData($xo + $y, $yo + $x1, $color, $cTable);
			MBF_SetColorData($xo + $y, $yo - $x1, $color, $cTable);
			MBF_SetColorData($xo - $y, $yo + $x1, $color, $cTable);
			MBF_SetColorData($xo - $y, $yo - $x1, $color, $cTable);

			$r -= ($y << 1) - 1;
			if ($r < 0){
				$r += ($x - 1) << 1;
				$x--;
			}
			$y++;
		}
	} else{
		$x = $r = $ry;
		$y = 0;
		while ($x >= $y){
			$x1 = int($x * $rx / $ry);
			$y1 = int($y * $rx / $ry);
			MBF_SetColorData($xo + $x1, $yo + $y, $color, $cTable);
			MBF_SetColorData($xo + $x1, $yo - $y, $color, $cTable);
			MBF_SetColorData($xo - $x1, $yo + $y, $color, $cTable);
			MBF_SetColorData($xo - $x1, $yo - $y, $color, $cTable);
			MBF_SetColorData($xo + $y1, $yo + $x, $color, $cTable);
			MBF_SetColorData($xo + $y1, $yo - $x, $color, $cTable);
			MBF_SetColorData($xo - $y1, $yo + $x, $color, $cTable);
			MBF_SetColorData($xo - $y1, $yo - $x, $color, $cTable);

			$r -= ($y << 1) - 1;
			if ($r < 0){
				$r += ($x - 1) << 1;
				$x--;
			}
			$y++;
		}
	}
}

1;
