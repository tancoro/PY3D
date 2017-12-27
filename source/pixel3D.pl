##_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
## Prefix Is PXL
##_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
use strict;
require '..\PY3D\vertex3D.pl';
require '..\PY3D\texture3D.pl';

###
## ピクセルシェーダーを実行する。
## ピクセルストリームから座標、色、深度バッファ、ステンシルバッファを
## レンダリングターゲットサーフェスに書き込みます。
##
sub PXL_PixelShader {
	my ($tSurface, $rs, $pixelStream) = @_;

	for my $i (0..$#$pixelStream) {
		my $x = $pixelStream->[$i]->{"VECTOR"}->[0];
		my $y = $pixelStream->[$i]->{"VECTOR"}->[1];

		## レンダリングターゲットサーフェス内の点か判定する。
		next if ( $x < 0 || $x > $#{$tSurface->[0]} || $y < 0 || $y > $#$tSurface );
		## Zテスト判定を行う。
		if ($tSurface->[$y][$x][4] > $pixelStream->[$i]->{"Z"} && 0 < $pixelStream->[$i]->{"Z"}) {

			## ディフェーズ色を設定する。
			my $texelR = $pixelStream->[$i]->{'DIFFUSE'}->[0];
			my $texelG = $pixelStream->[$i]->{'DIFFUSE'}->[1];
			my $texelB = $pixelStream->[$i]->{'DIFFUSE'}->[2];
			my $texelA = $pixelStream->[$i]->{'DIFFUSE'}->[3];

			## テクスチャ色の合成を行う。
			for my $texStage (0..$#{$pixelStream->[$i]->{'TEX'}}) {
				my $tC = TEX_GetTexColor($rs->{'RS_TS_TEXTURE'}->[$texStage], $rs->{'RS_TSS_ADDRESSU'}->[$texStage],
										$pixelStream->[$i]->{'TEX'}->[$texStage]);
				$texelR *= $tC->[0];
				$texelG *= $tC->[1];
				$texelB *= $tC->[2];
				$texelA *= $tC->[3];
			}

			## スペキュラ色の合成を行う。
			$texelR += $pixelStream->[$i]->{'SPECULAR'}->[0];
			$texelG += $pixelStream->[$i]->{'SPECULAR'}->[1];
			$texelB += $pixelStream->[$i]->{'SPECULAR'}->[2];
			## $texelA += $pixelStream->[$i]->{'SPECULAR'}->[3];
			## 頂点のスペキュラ色のアルファ成分にはフォグ係数が格納されている。


			## αブレンディングが有効な場合
			if ($rs->{'RS_ALPHABLENDENABLE'} eq 'TRUE') {
				$tSurface->[$y][$x][0] = $texelR * $texelA + $tSurface->[$y][$x][0] * (1 - $texelA);
				$tSurface->[$y][$x][1] = $texelG * $texelA + $tSurface->[$y][$x][1] * (1 - $texelA);
				$tSurface->[$y][$x][2] = $texelB * $texelA + $tSurface->[$y][$x][2] * (1 - $texelA);
				$tSurface->[$y][$x][3] = $texelA * $texelA + $tSurface->[$y][$x][3] * (1 - $texelA);
			## αブレンディングが無効な場合
			} else {
				$tSurface->[$y][$x][0] = $texelR;
				$tSurface->[$y][$x][1] = $texelG;
				$tSurface->[$y][$x][2] = $texelB;
				$tSurface->[$y][$x][3] = $texelA;
			}

			## Z値、ステンシルバッファ値の更新を行う。
			$tSurface->[$y][$x][4] = $pixelStream->[$i]->{"Z"} if ($rs->{'RS_ZWRITEENABLE'} eq 'TRUE');
			$tSurface->[$y][$x][5] = 0;

			## フォグ効果のテスト用に追加 Start
			if ($rs->{"RS_FOGCOLOR"}) {
				## フォグ境界値
				my $dife = 0.95;
				if ($tSurface->[$y][$x][4] > $dife) {
					my $f = ( $tSurface->[$y][$x][4] - $dife )/(1 - $dife);

					$tSurface->[$y][$x][0] =  $tSurface->[$y][$x][0] * (1 - $f) + $rs->{"RS_FOGCOLOR"}->[0] * $f;
					$tSurface->[$y][$x][1] =  $tSurface->[$y][$x][1] * (1 - $f) + $rs->{"RS_FOGCOLOR"}->[1] * $f;
					$tSurface->[$y][$x][2] =  $tSurface->[$y][$x][2] * (1 - $f) + $rs->{"RS_FOGCOLOR"}->[2] * $f;
					$tSurface->[$y][$x][3] =  $tSurface->[$y][$x][3] * (1 - $f) + $rs->{"RS_FOGCOLOR"}->[3] * $f;
				}
			}
			## フォグ効果のテスト用に追加 End
		}
	}
}


##
## 線分を描画する。
## @param1 tSurface レンダリングターゲットサーフェス
## @param2 color 線分の色
## @param3 x1 線分の始点(X座標)
## @param4 y1 線分の始点(Y座標)
## @param5 x2 線分の終点(X座標)
## @param6 y2 線分の終点(Y座標)
##
sub PXL_PixelShaderLine {
	my ($tSurface, $color, $x1, $y1, $x2, $y2) = @_;

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
			## 色の更新を行う。
			$tSurface->[$y][$x][0] = $color->[0];
			$tSurface->[$y][$x][1] = $color->[1];
			$tSurface->[$y][$x][2] = $color->[2];
			$tSurface->[$y][$x][3] = $color->[3];
			$tSurface->[$y][$x][4] = 0;
			$tSurface->[$y][$x][5] = 0;
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
			## 色の更新を行う。
			$tSurface->[$y][$x][0] = $color->[0];
			$tSurface->[$y][$x][1] = $color->[1];
			$tSurface->[$y][$x][2] = $color->[2];
			$tSurface->[$y][$x][3] = $color->[3];
			$tSurface->[$y][$x][4] = 0;
			$tSurface->[$y][$x][5] = 0;
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
## 頂点データを三角形内部の全てのピクセルについて補間する
##
## この頂点フォーマットは VEWPORTVERTEXとする。
## 　　スクリーン座標 Vertex->{"VECTOR"} = [x, y];
## 　　Z バッファ深度 Vertex->{"Z"} = z;
## 　　同次の逆数     Vertex->{"RHW"} = rhw;
## 　　ディフェーズ色 Vertex->{"DIFFUSE"} = [r,g,b,a];
## 　　スペキュラ色   Vertex->{"SPECULAR"} = [r,g,b,a];
## 　　テクスチャ座標 Vertex->{"TEX"} = [[tu1, tv1],[tu2, tv2],[tu3, tv3]...];
##
## @param1 vA 三角形の点A (Vertex)
## @param2 vB 三角形の点B (Vertex)
## @param3 vC 三角形の点C (Vertex)
##
sub PXL_VertexToPixel {
	my ($vA, $vB, $vC) = @_;

	## X,Y成分についてそれぞれ昇順にソートし走査の範囲を求める
	my @xSortArray = sort {$a <=> $b;} ($vA->{"VECTOR"}->[0], $vB->{"VECTOR"}->[0], $vC->{"VECTOR"}->[0]);
	my @ySortArray = sort {$a <=> $b;} ($vA->{"VECTOR"}->[1], $vB->{"VECTOR"}->[1], $vC->{"VECTOR"}->[1]);
	my ($xStartPos, $xEndPos, $yStartPos, $yEndPos) = ( lookUpLineStartPos($xSortArray[0]),
														lookUpLineEndPos($xSortArray[2]),
														lookUpLineStartPos($ySortArray[0]),
														lookUpLineEndPos($ySortArray[2]));
	## 三角形の外積を求める
	my $primBata = traiangleCros($vA->{"VECTOR"}, $vB->{"VECTOR"}, $vC->{"VECTOR"});

	## 走査を開始する
	my $pixelStream = VTX_CreateVertexBuffer();
	for my $yLine ($yStartPos..$yEndPos) {
		for my $xLine ($xStartPos..$xEndPos) {

			my $bataC = traiangleCros( [$xLine,$yLine], $vA->{"VECTOR"}, $vB->{"VECTOR"});
			my $bataA = traiangleCros( [$xLine,$yLine], $vB->{"VECTOR"}, $vC->{"VECTOR"});
			my $bataB = traiangleCros( [$xLine,$yLine], $vC->{"VECTOR"}, $vA->{"VECTOR"});

			## 三角形の内部判定OKの場合はピクセル単位に線形補間を行う
			if (($bataA >= 0 && $bataB >= 0 && $bataC >= 0) ||
				($bataA <= 0 && $bataB <= 0 && $bataC <= 0)) {
				my $menA 		= $bataA/$primBata;
				my $menB		= $bataB/$primBata;
				my $menC		= $bataC/$primBata;
				my $hZ			= $menA*$vA->{"Z"} + $menB*$vB->{"Z"} + $menC*$vC->{"Z"};
				my $hRHW		= $menA*$vA->{"RHW"} + $menB*$vB->{"RHW"} + $menC*$vC->{"RHW"};
				my $hDIFFUSE_R	= $menA*$vA->{"DIFFUSE"}->[0] + $menB*$vB->{"DIFFUSE"}->[0] + $menC*$vC->{"DIFFUSE"}->[0];
				my $hDIFFUSE_G	= $menA*$vA->{"DIFFUSE"}->[1] + $menB*$vB->{"DIFFUSE"}->[1] + $menC*$vC->{"DIFFUSE"}->[1];
				my $hDIFFUSE_B	= $menA*$vA->{"DIFFUSE"}->[2] + $menB*$vB->{"DIFFUSE"}->[2] + $menC*$vC->{"DIFFUSE"}->[2];
				my $hDIFFUSE_A	= $menA*$vA->{"DIFFUSE"}->[3] + $menB*$vB->{"DIFFUSE"}->[3] + $menC*$vC->{"DIFFUSE"}->[3];
				my $hSPECULAR_R	= $menA*$vA->{"SPECULAR"}->[0] + $menB*$vB->{"SPECULAR"}->[0] + $menC*$vC->{"SPECULAR"}->[0];
				my $hSPECULAR_G	= $menA*$vA->{"SPECULAR"}->[1] + $menB*$vB->{"SPECULAR"}->[1] + $menC*$vC->{"SPECULAR"}->[1];
				my $hSPECULAR_B	= $menA*$vA->{"SPECULAR"}->[2] + $menB*$vB->{"SPECULAR"}->[2] + $menC*$vC->{"SPECULAR"}->[2];
				my $hSPECULAR_A	= $menA*$vA->{"SPECULAR"}->[3] + $menB*$vB->{"SPECULAR"}->[3] + $menC*$vC->{"SPECULAR"}->[3];
				my $tex = [];
				for my $index (0..$#{$vA->{'TEX'}}) {
						push(@$tex, [	$menA*$vA->{'TEX'}->[$index]->[0]+
										$menB*$vB->{'TEX'}->[$index]->[0]+
										$menC*$vC->{'TEX'}->[$index]->[0],
										$menA*$vA->{'TEX'}->[$index]->[1]+
										$menB*$vB->{'TEX'}->[$index]->[1]+
										$menC*$vC->{'TEX'}->[$index]->[1]]);
				}

				VTX_PushVertex($pixelStream, VTX_MakeVewportVertex( [$xLine, $yLine], $hZ, $hRHW, 
								[$hDIFFUSE_R, $hDIFFUSE_G, $hDIFFUSE_B, $hDIFFUSE_A],
								[$hSPECULAR_R, $hSPECULAR_G, $hSPECULAR_B, $hSPECULAR_A], $tex));
			}
		}
	}

	return $pixelStream;
}


##
## 走査の開始位置を求める
## @param1 開始点（浮動小数）
##
sub lookUpLineStartPos {
	my ($flotVal) = @_;

	if ( $flotVal >0 ) {
		if (int($flotVal) == $flotVal) {
			return $flotVal;
		} else {
			return int($flotVal)+1;
		}
	} else {
		return int($flotVal);
	}

}

##
## 走査の終了位置を求める
## @param1 終了点（浮動小数）
##
sub lookUpLineEndPos {
	my ($flotVal) = @_;

	if ( $flotVal >0 ) {
		return int($flotVal);
	} else {
		if (int($flotVal) == $flotVal) {
			return $flotVal;
		} else {
			return int($flotVal)-1;
		}
	}

}


##
## 三角形ABCの外積のZ成分を返す。
## 以下のように計算を行う。
## (ベクトルAB) X (ベクトルAC)
## 戻り値は、Z成分の値。
##
## @param1 vA 三角形の点A [x,y]
## @param2 vB 三角形の点B [x,y]
## @param3 vC 三角形の点C [x,y]
##
sub traiangleCros {
	my ($vA, $vB, $vC) = @_;
	return ($vB->[0] - $vA->[0])*($vC->[1] - $vA->[1]) - ($vB->[1] - $vA->[1])*($vC->[0] - $vA->[0]);
}

1;
