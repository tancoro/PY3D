##_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
## Prefix Is TEX
##_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
use strict;

###########################################################
##【 テクスチャ[Texture]の定義 】
##
##  tTexture->[0] = [size, width, height]; (テクスチャヘッダー)
##    size   = 24 or 32 (1画素あたりのデータbitサイズ)
##    width  = テクスチャの幅(width 画素)
##    height = テクスチャの高さ(height 画素)
##
##  tTexture->[1][Y][X]; (テクスチャデータ)
##    24ビットフォーマットの場合
##       1Byte目 = Blue
##       2Byte目 = Green
##       3Byte目 = Red
##
##    32ビットフォーマットの場合
##       1Byte目 = Blue
##       2Byte目 = Green
##       3Byte目 = Red
##       4Byte目 = アルファ値
##
###########################################################


###
## ファイルからテクスチャを読み込む
## 24ビットフォーマットBMPの場合はα値は常に１となる。
## 32ビットフォーマットBMPの場合はα値は指定値となる。
##
sub TEX_CreateTextureFromFile {
	my ($sourceFileName) = @_;

	## ファイルから画像データを読み込む
	my ($data, $tTexture);
	open(TEXTURE_HANDLE, $sourceFileName) || return 0;
	binmode(TEXTURE_HANDLE);
	read(TEXTURE_HANDLE, $data, -s TEXTURE_HANDLE);
	close(TEXTURE_HANDLE);

	## ヘッダー情報を取得する。
	my @headerInfo = unpack("aaL3L3S2L6", $data);
	## BMPのデータ部分を取得する。
	substr($data, 0, $headerInfo[4], '');

	## 上から下へのデータ構造の場合は画像が上下左右逆になる（注意）
	$headerInfo[7] *= (-1) if ($headerInfo[7] < 0);
	## 無圧縮方式以外は不可
	return 0 if ($headerInfo[10] != 0);
	## 24ビット、32ビット以外のフォーマットの場合は不可
	return 0 if ($headerInfo[9] < 24);

	## データを取得する。
	my $bCountByte = $headerInfo[9]/8;
	$tTexture->[0] = [$headerInfo[9], $headerInfo[6], $headerInfo[7]];
	for (my $y = 0 ; $y < $headerInfo[7] ; $y++) {
		for (my $x = 0 ; $x < $headerInfo[6] ; $x++) {
			$tTexture->[1][$y][$x] = substr($data, $bCountByte*($headerInfo[6]*$y+$x), $bCountByte );
		}
	}

	return $tTexture;
}


###
## 24bitフォーマットのBMPファイルからテクスチャを読み込む
## この時α値は輝度が大きいほど大きくなる。
## つまり黒色は透明、白色は不透明となる。
##
sub TEX_CreateAlphaTextureFromFile {
	my ($sourceFileName) = @_;

	## ファイルから画像データを読み込む
	my ($data, $tTexture);
	open(TEXTURE_HANDLE, $sourceFileName) || return 0;
	binmode(TEXTURE_HANDLE);
	read(TEXTURE_HANDLE, $data, -s TEXTURE_HANDLE);
	close(TEXTURE_HANDLE);

	## ヘッダー情報を取得する。
	my @headerInfo = unpack("aaL3L3S2L6", $data);
	## BMPのデータ部分を取得する。
	substr($data, 0, $headerInfo[4], '');

	## 上から下へのデータ構造の場合は画像が上下左右逆になる（注意）
	$headerInfo[7] *= (-1) if ($headerInfo[7] < 0);
	## 無圧縮方式以外は不可
	return 0 if ($headerInfo[10] != 0);
	## 24ビット、32ビット以外のフォーマットの場合は不可
	return 0 if ($headerInfo[9] != 24);

	## データを取得する。
	my $bCountByte = $headerInfo[9]/8;
	$tTexture->[0] = [32, $headerInfo[6], $headerInfo[7]];
	for (my $y = 0 ; $y < $headerInfo[7] ; $y++) {
		for (my $x = 0 ; $x < $headerInfo[6] ; $x++) {
			my @colorData = unpack('C3', substr($data, $bCountByte*($headerInfo[6]*$y+$x), $bCountByte ));
			$tTexture->[1][$y][$x] = pack('C4', $colorData[0],$colorData[1],$colorData[2],
										int(($colorData[0]+$colorData[1]+$colorData[2])/3));
		}
	}

	return $tTexture;
}


sub TEX_GetTexColor {
	my ($tTexture, $addressuMode, $texTV) = @_;
	my ($x, $y);

	## AddressuMode --【 TADDRESS_CLAMP 】の場合
	if ($addressuMode eq 'TADDRESS_CLAMP') {

		## テクスチャ座標を [0 ～ height][0 ～ width] の範囲に直す
		$x = int($tTexture->[0][1] * $texTV->[0]);
		$y = int($tTexture->[0][2] * $texTV->[1]);
		$x = 0 if ($x < 0);
		$x = $tTexture->[0][1] - 1 if ($x > $tTexture->[0][1] - 1);
		$y = 0 if ($y < 0);
		$y = $tTexture->[0][2] - 1 if ($y > $tTexture->[0][2] - 1);

	## AddressuMode --【 TADDRESS_WRAP 】の場合
	} elsif ($addressuMode eq 'TADDRESS_WRAP') {

		$x = $tTexture->[0][1] * $texTV->[0];
		$y = $tTexture->[0][2] * $texTV->[1];

		if ($x < 0) {
			$x = (int($x)*(-1) % $tTexture->[0][1] - $tTexture->[0][1] + 1)*(-1);
		} else {
			$x = int($x) % $tTexture->[0][1];
		}

		if ($y < 0) {
			$y = (int($y)*(-1) % $tTexture->[0][2] - $tTexture->[0][2] + 1)*(-1);
		} else {
			$y = int($y) % $tTexture->[0][2];
		}

	## AddressuMode --【 TADDRESS_MIRROR 】の場合
	} else {

		$x = int($tTexture->[0][1] * $texTV->[0]);
		$y = int($tTexture->[0][2] * $texTV->[1]);
		$x *= (-1) if ($x < 0);
		$y *= (-1) if ($y < 0);
		$x = $x % ($tTexture->[0][1] * 2);
		$y = $y % ($tTexture->[0][2] * 2);
		$x = $tTexture->[0][1] * 2 - $x - 1 if ($x >= $tTexture->[0][1]);
		$y = $tTexture->[0][2] * 2 - $y - 1 if ($y >= $tTexture->[0][2]);

	}

	## テクスチャフォーマット 24bit の場合
	## α値は常に１となる。
	if ($tTexture->[0][0] == 24) {
		my @colorData = unpack('C3', $tTexture->[1][$y][$x]);
		return RST_ToColor($colorData[2], $colorData[1], $colorData[0], 0xFF);

	## テクスチャフォーマット 32bit の場合
	} else {
		my @colorData = unpack('C4', $tTexture->[1][$y][$x]);
		return RST_ToColor($colorData[2], $colorData[1], $colorData[0], $colorData[3]);
	}

}

1;
