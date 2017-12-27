##_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
## Prefix Is RST
##_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
use strict;
require '..\PY3D\matrix3D.pl';

##########################################
##【 TargetSurface の定義 】
##
##  TSurface->[y][x]; (BMPの１ピクセルに対応)
##  TSurfaceは height[Y] が 0 ～ $#TSurface (BMPの高さに一致)
##  TSurfaceは width [X] が 0 ～ $#{TSurface->[0]} (BMPの幅に一致)
##
##【 TargetSurface内 pixelの定義 】
##  pixel = TSurface->[y][x]; とした場合、
##  pixel = [r, g, b, a, z, s] とする。
##  r, g, b, a は color値。
##  z は flot深度バッファ
##  s は flotステンシルバッファ
##
##【 RenderState の定義 】
##
##  以下に設定内容と値を示す。なお、()の説明はデフォルト値を表す
##  RenderState->{"RS_TS_WORLD"} = Matrix ワールド行列 (単位行列)
##  RenderState->{"RS_TS_VIEW"} = Matrix ビュー行列 (単位行列)
##  RenderState->{"RS_TS_PROJECTION"} = Matrix 射影トランスフォーム行列 (単位行列)
##  RenderState->{"RS_TS_TEXTURE"} = [ Texture0, Texture1, Texture2 ・・・] 各テクスチャステージに設定されるTexture (なし)
##  RenderState->{"RS_TSS_ADDRESSU"} = [ mode1, mode2, mode3・・・]  各テクスチャステージのアドレスモードを指定する。
##										'TADDRESS_WRAP'、'TADDRESS_MIRROR'、'TADDRESS_CLAMP' の３つが設定可能。
##  RenderState->{"RS_LIGHT"} = [ Light1, Light2, Light3・・・] ライトオブジェクトの配列 (なし)
##  RenderState->{"RS_AMBIENT"} = [r,g,b,a] 環境光
##  RenderState->{"RS_MATERIAL"} = Material マテリアルオブジェクト (なし)
##  RenderState->{"RS_FOGCOLOR"} = [r,g,b,a] フォグに使用する色
##  RenderState->{"RS_LINE_COLOR"} = [r,g,b,a] GEO_DrawPrimitiveLine()を使用してワイヤーフレームを描画する時の線の色
##  RenderState->{"RS_ALPHABLENDENABLE"} =  αブレンディングを有効にする場合は'TRUE'、無効にする場合は 'FALSE' を指定する。
##  RenderState->{"RS_ZWRITEENABLE"} = 深度バッファへの書き込みを有効にするには、'TRUE'を設定する。'FALSE'の場合は深度比較が実行されるが、深度値はバッファに書き込まれない。 
##########################################


###
## 新規のレンダリングターゲットサーフェスを作成します。
## 深度バッファ・ステンシルバッファ・α値を持ちます。
## ここで作られたレンダリングターゲットサーフェスのサイズは、
## そのままBMPのファイルサイズになります。
##
## @param1 $width  幅
## @param2 $height 高さ
## @param3 $color  デフォルトの塗りつぶし色 [r,g,b,a]
## @return レンダリングターゲットサーフェス
##
sub RST_CreateTargetSurface {
	my($width, $height, $color) = @_;

	## $width*3 は、4で割り切れる必要がある。
	return 0 if (($width * 3) % 4 != 0);

	## データ格納領域の初期化
	my $tSurface = [];
	for my $i(0..$height-1) {
		$tSurface->[$i] = [];
		for my $j(0..$width-1) {
			$tSurface->[$i][$j] = [@$color, 1.0, 1.0];
		}
	}

	return $tSurface;
}


###
## レンダリングターゲットサーフェスのデータをクリアします。
## 深度バッファ・ステンシルバッファ・α値は全て初期値に戻され、
## 指定された色で塗りつぶされます。
##
## @param1 $tSurface レンダリングターゲットサーフェス
## @param2 $color    塗りつぶし色 [r,g,b,a]
## @return レンダリングターゲットサーフェス
##
sub RST_ClearTargetSurface {
	my($tSurface, $color) = @_;

	for my $i(0..$#$tSurface) {
		for my $j(0..$#{$tSurface->[0]}) {
			$tSurface->[$i][$j][0] = $color->[0];
			$tSurface->[$i][$j][1] = $color->[1];
			$tSurface->[$i][$j][2] = $color->[2];
			$tSurface->[$i][$j][3] = $color->[3];
			$tSurface->[$i][$j][4] = 1.0;
			$tSurface->[$i][$j][5] = 1.0;
		}
	}

	return $tSurface;
}


###
## レンダリングターゲットサーフェスの
## 深度バッファを指定値でクリアします。
##
## @param1 $tSurface レンダリングターゲットサーフェス
## @param2 $zValue   深度バッファ値
## @return レンダリングターゲットサーフェス
##
sub RST_ClearZInTargetSurface {
	my($tSurface, $zValue) = @_;

	for my $i(0..$#$tSurface) {
		for my $j(0..$#{$tSurface->[0]}) {
			$tSurface->[$i][$j][4] = $zValue;
		}
	}

	return $tSurface;
}


###
## レンダリングターゲットサーフェスのデータをBMPファイルに出力します。
##
## @param1 レンダリングターゲットサーフェス
## @param2 BMPファイル名
##
sub RST_PrintOutToBmp {
	my ($tSurface, $fileName) = @_;

	## 画像データのサイズを取得する
	my $height = $#$tSurface + 1;
	my $width  = $#{$tSurface->[0]} + 1;

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
			my $red = $tSurface->[$i][$j][0];
			my $gre = $tSurface->[$i][$j][1];
			my $bru = $tSurface->[$i][$j][2];
			print W_FILE makeRgbData($red, $gre, $bru);
		}
	}

	## ファイルを閉じる
	close(W_FILE);

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
## @param1 赤色の要素(0 ～ 1.0)
## @param2 緑色の要素(0 ～ 1.0)
## @param3 青色の要素(0 ～ 1.0)
##
sub makeRgbData {
	my($red, $green, $blue) = @_;
	$red *= 255; $green *= 255; $blue *= 255;
	$red = 0 if ($red < 0); $red = 255 if ($red > 255);
	$green = 0 if ($green < 0); $green = 255 if ($green > 255);
	$blue = 0 if ($blue < 0); $blue = 255 if ($blue > 255);
	return pack("CCC", $blue % 256, $green % 256, $red % 256);
}


###
## 新規のレンダリングステートオブジェクトを作成します。
## 各種計算方法・描画方法を設定するために使用します。
##
## @return 新規のレンダリングステートオブジェクト
##
sub RST_CreateRenderState {
	my $rs = {};

	$rs->{'RS_TS_WORLD'} = MAT_MIdentity();
	$rs->{'RS_TS_VIEW'} = MAT_MIdentity();
	$rs->{'RS_TS_PROJECTION'} = MAT_MIdentity();
	## $rs->{'RS_TS_TEXTURE'}
	## $rs->{'RS_TSS_ADDRESSU'}
	## $rs->{'RS_LIGHT'}
	## $rs->{'RS_MATERIAL'}
	## $rs->{'RS_FOGCOLOR'}
	$rs->{'RS_AMBIENT'} = RST_ToColor(0x00, 0x00, 0x00, 0x00);
	$rs->{'RS_LINE_COLOR'} = RST_ToColor(0xFF,0xFF,0xFF,0xFF);
	$rs->{'RS_ALPHABLENDENABLE'} = 'FALSE';
	$rs->{'RS_ZWRITEENABLE'} = 'TRUE';

	return $rs;
}


###
## レンダリングステートを設定する。
##
## @param1 レンダリングステートオブジェクト
## @param2 項目
## @param3 項目に対する設定値
##
sub RST_SetRenderState {
	my ($rso ,$stateType, $value) = @_;
	$rso->{$stateType} = $value;
}


###
## レンダリングステートを取得する。
##
## @param1 レンダリングステートオブジェクト
## @param2 項目
##
sub RST_GetRenderState {
	my ($rso ,$stateType) = @_;
	return $rso->{$stateType};
}


###
## 255 ～ 0 のCOLOR値を
## 1.0 ～ 0 の範囲にトランスポートします。
##
sub RST_ToColor {
	my ($r, $g, $b, $a) = @_;
	my $redf = $r / 255;
	my $gref = $g / 255;
	my $bluf = $b / 255;
	my $alff = $a / 255;

	$redf = 0 if ($redf < 0); $redf = 1.0 if ($redf > 1.0);
	$gref = 0 if ($gref < 0); $gref = 1.0 if ($gref > 1.0);
	$bluf = 0 if ($bluf < 0); $bluf = 1.0 if ($bluf > 1.0);
	$alff = 0 if ($alff < 0); $alff = 1.0 if ($alff > 1.0);

	return [$redf, $gref, $bluf, $alff];
}

1;
