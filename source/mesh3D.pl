##_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
## Prefix Is MSH
##_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
use strict;
require '..\PY3D\vector3D.pl';
require '..\PY3D\matrix3D.pl';
require '..\PY3D\vertex3D.pl';


###
## XY平面(2D)のX正領域上に定義された頂点リストを
## Y軸で回転させたメッシュを作成する。
## 始点、終点はY軸上(x要素が0)である必要がある。
## @param1 VECTOR2配列  XY平面上のX正領域頂点座標
## @param2 Deg          Y軸の回転刻み
##
sub MSH_CreateRotationY {
	my ($v2D, $angle) = @_;

	## 頂点を2D->3Dに変換する。
	my ($startVertex, $endVertex);
	my $vertexBuff = VTX_CreateVertexBuffer();
	for (my $i = 0 ; $i <= $#$v2D ; $i++) {
		if ($i == 0) {
			$startVertex = VTX_MakeUnlitVertex( [$v2D->[$i]->[0], $v2D->[$i]->[1], 0], [0, 1,0]);
		} elsif ($i == $#$v2D) {
			$endVertex = VTX_MakeUnlitVertex( [$v2D->[$i]->[0], $v2D->[$i]->[1], 0], [0,-1,0]);
		} else {
			VTX_PushVertex( $vertexBuff, VTX_MakeUnlitVertex( [$v2D->[$i]->[0], $v2D->[$i]->[1], 0],
						[$v2D->[$i-1]->[1]-$v2D->[$i+1]->[1], $v2D->[$i+1]->[0]-$v2D->[$i-1]->[0], 0]));
		}
	}

	## Y軸を中心に回転させる。
	## for (my $cnt = 1 ; 360 > ($angle<0 ? (-1)*$angle*$cnt : $angle*$cnt) ; $cnt++) 
	my $cnt = 1;
	my $transVertexCnt = $#$vertexBuff;
	$angle = $angle < 0 ? $angle*(-1) : $angle;
	for ($cnt = 1 ; 360 > $angle*$cnt ; $cnt++) {
		my $m = MAT_MRotationY(MAT_DegToRad($angle*$cnt));
		for my $i (0..$transVertexCnt) {
			VTX_PushVertex( $vertexBuff, VTX_MakeUnlitVertex(
				VEC_Vec3TransformCoord($vertexBuff->[$i]->{"VECTOR"}, $m),
				VEC_Vec3TransformNormal($vertexBuff->[$i]->{"NORMAL"}, $m)));
		}
	}

	## オブジェクトを閉じる
	for my $i (0..$transVertexCnt) {
		VTX_PushVertex( $vertexBuff, $vertexBuff->[$i]);
	}

	## 上中心点、下中心点を頂点バッファに追加する。
	VTX_UnshiftVertex($vertexBuff,$endVertex);
	VTX_UnshiftVertex($vertexBuff,$startVertex);

	## 頂点バッファ、プリミティブタイプ、オプションを設定する。
	return ($vertexBuff, 'D3DPT_MSH_ROTATIONY', [$transVertexCnt+1, $cnt]);
}


###
## XY平面(2D)のX正領域上に定義された頂点リストを
## Y軸で回転させたトーラス型のメッシュを作成する。
## 始点と終点を結んだ閉じた図形を回転させ
## @param1 VECTOR2配列  XY平面上のX正領域頂点座標
## @param2 Deg          Y軸の回転刻み
## @param3 テクスチャ座標 [[tu1, tv1],[tu2, tv2],[tu3, tv3]・・・] 
##
sub MSH_CreateTorus {
	my ($v2D, $angle, $texV) = @_;

	## 頂点を2D->3Dに変換する。
	my ($startVertex, $endVertex);
	my $vertexBuff = VTX_CreateVertexBuffer();
	for (my $i = 0 ; $i <= $#$v2D ; $i++) {
		if ($i == 0) {
			VTX_PushVertex( $vertexBuff, VTX_MakeUnlitVertex( [$v2D->[$i]->[0], $v2D->[$i]->[1], 0],
				[$v2D->[$#$v2D]->[1]-$v2D->[$i+1]->[1], $v2D->[$i+1]->[0]-$v2D->[$#$v2D]->[0], 0]));
		} elsif ($i == $#$v2D) {
			VTX_PushVertex( $vertexBuff, VTX_MakeUnlitVertex( [$v2D->[$i]->[0], $v2D->[$i]->[1], 0],
				[$v2D->[$i-1]->[1]-$v2D->[0]->[1], $v2D->[0]->[0]-$v2D->[$i-1]->[0], 0]));
		} else {
			VTX_PushVertex( $vertexBuff, VTX_MakeUnlitVertex( [$v2D->[$i]->[0], $v2D->[$i]->[1], 0],
				[$v2D->[$i-1]->[1]-$v2D->[$i+1]->[1], $v2D->[$i+1]->[0]-$v2D->[$i-1]->[0], 0]));
		}
	}

	## 2Dオブジェクトを閉じる
	VTX_PushVertex( $vertexBuff, VTX_MakeUnlitVertex( [$v2D->[0]->[0], $v2D->[0]->[1], 0],
		[$v2D->[$#$v2D]->[1]-$v2D->[1]->[1], $v2D->[1]->[0]-$v2D->[$#$v2D]->[0], 0]));

	## Y軸を中心に回転させる。
	## for (my $cnt = 1 ; 360 > ($angle<0 ? (-1)*$angle*$cnt : $angle*$cnt) ; $cnt++) 
	my $cnt = 1;
	my $transVertexCnt = $#$vertexBuff;
	$angle = $angle < 0 ? $angle*(-1) : $angle;
	for ($cnt = 1 ; 360 > $angle*$cnt ; $cnt++) {
		my $m = MAT_MRotationY(MAT_DegToRad($angle*$cnt));
		for my $i (0..$transVertexCnt) {
			VTX_PushVertex( $vertexBuff, VTX_MakeUnlitVertex(
				VEC_Vec3TransformCoord($vertexBuff->[$i]->{"VECTOR"}, $m),
				VEC_Vec3TransformNormal($vertexBuff->[$i]->{"NORMAL"}, $m)));
		}
	}

	## オブジェクトを閉じる
	for my $i (0..$transVertexCnt) {
		VTX_PushVertex( $vertexBuff, $vertexBuff->[$i]);
	}

	## テクスチャが存在する場合の頂点作成
	if ($texV) {
		my $indexCounta = 0;
		for( my $i = 0; $i <= $cnt ; $i++) {
			for( my $j = 0; $j <= ($#$v2D+1) ; $j++) {
				my $tpX = $i / $cnt;
				my $tpY = $j / ($#$v2D+1);

				my @texBuff = ();
				map { push(@texBuff, [$tpX * $_->[0], $tpY * $_->[1]]) } @$texV;
				VTX_SetTexUnlitVertex($vertexBuff->[$indexCounta], [@texBuff]);
				$indexCounta++;
			}
		}
	}

	## 頂点バッファ、プリミティブタイプ、オプションを設定する。
	return ($vertexBuff, 'D3DPT_MSH_TORUS', [$cnt, $#$v2D+1]);
}


###
## 原点[0,0,0] を左下とする平面矩形を作成する。
## 頂点法線ベクトルは、全て[0,0,-1]とする。
##
## @param1 VECTOR2   平面矩形の右上頂点座標 (x > 0 かつ y > 0 の点)(Z成分は 0 固定)
## @param2 横分割数  横のポリゴン分割数(整数)
## @param3 縦分割数  縦のポリゴン分割数(整数)
## @param4 テクスチャ座標 [[tu1, tv1],[tu2, tv2],[tu3, tv3]・・・] 
##         各テクスチャステージの平面矩形右上座標
##         ( 平面矩形左下座標は全てのテクスチャステージにおいて [0,0] 固定とする。)
##
sub MSH_CreatePlaneRect {
	my ($trVec, $xPch, $yPch, $texV) = @_;

	my $vertexBuff = VTX_CreateVertexBuffer();
	for( my $i = 0; $i <= $xPch ; $i++) {
		for( my $j = 0; $j <= $yPch ; $j++) {
			my $tpX = $i / $xPch;
			my $tpY = $j / $yPch;

			## テクスチャが存在する場合
			if ($texV) {
				## my $ttY = ($yPch - $j) / $yPch;
				my @texBuff = ();
				## map { push(@texBuff, [$tpX * $_->[0], $ttY * $_->[1]]) } @$texV;
				map { push(@texBuff, [$tpX * $_->[0], $tpY * $_->[1]]) } @$texV;
				VTX_PushVertex( $vertexBuff,
					VTX_MakeUnlitVertex( [$tpX*$trVec->[0], $tpY*$trVec->[1], 0], [0, 0, -1], [@texBuff] ));

			## テクスチャが存在しない場合
			} else {
				VTX_PushVertex( $vertexBuff,
					VTX_MakeUnlitVertex( [$tpX*$trVec->[0], $tpY*$trVec->[1], 0], [0, 0, -1] ));
			}
		}
	}

	## 頂点バッファ、プリミティブタイプ、オプションを設定する。
	return ($vertexBuff, 'D3DPT_MSH_PLANERECT', [$xPch, $yPch]);
}


###
## ２つの頂点バッファの線形補間によるトゥイーニング図形を返す。
## ２つの頂点バッファは以下の４つの条件を満たす必要がある。
##   ①  頂点バッファの頂点数が同じであること。
##   ②  プリミティブタイプが同じであること。
##   ③  オプションが同じであること。
##   ④  テクスチャステージが同一であること。
##
## @param1 頂点バッファ１（開始図形）
## @param2 頂点バッファ２（終了図形）
## @param3 フレーム分割コマ数（１以上の整数）
## @param4 取得図形のインデックス（ [ 0 ～ フレーム分割コマ数 ] の範囲の整数を指定 ）
##        『 0 』を指定した場合は頂点バッファ１を、
##        『フレーム分割コマ数』を指定した場合は頂点バッファ２のデータをそのまま返す。
##
sub MSH_CreateTweening {
	my ($vertexBuff1, $vertexBuff2, $pich, $accessIndex) = @_;

	my $pers1 = $accessIndex / $pich;
	my $pers2 = 1 - $pers1;
	my $vertexBuff = VTX_CreateVertexBuffer();
	for my $i (0..$#$vertexBuff1) {
		## テクスチャが存在する場合
		if ($vertexBuff1->[$i]->{"TEX"}) {
			## テクスチャステージ単位に線形補間を行う。
			my @texBuff = ();
			for my $j (0..$#{$vertexBuff1->[$i]->{"TEX"}}) {
				push(@texBuff, [ $vertexBuff1->[$i]->{"TEX"}->[$j]->[0] * $pers2 +
								 $vertexBuff2->[$i]->{"TEX"}->[$j]->[0] * $pers1,
								 $vertexBuff1->[$i]->{"TEX"}->[$j]->[1] * $pers2 +
								 $vertexBuff2->[$i]->{"TEX"}->[$j]->[1] * $pers1 ]);
			}
			## 線形補間を行う。
			VTX_PushVertex( $vertexBuff, VTX_MakeUnlitVertex(
			[ $vertexBuff1->[$i]->{"VECTOR"}->[0] * $pers2 + $vertexBuff2->[$i]->{"VECTOR"}->[0] * $pers1,
			  $vertexBuff1->[$i]->{"VECTOR"}->[1] * $pers2 + $vertexBuff2->[$i]->{"VECTOR"}->[1] * $pers1,
			  $vertexBuff1->[$i]->{"VECTOR"}->[2] * $pers2 + $vertexBuff2->[$i]->{"VECTOR"}->[2] * $pers1 ],
			[ $vertexBuff1->[$i]->{"NORMAL"}->[0] * $pers2 + $vertexBuff2->[$i]->{"NORMAL"}->[0] * $pers1,
			  $vertexBuff1->[$i]->{"NORMAL"}->[1] * $pers2 + $vertexBuff2->[$i]->{"NORMAL"}->[1] * $pers1,
			  $vertexBuff1->[$i]->{"NORMAL"}->[2] * $pers2 + $vertexBuff2->[$i]->{"NORMAL"}->[2] * $pers1 ],
			[ @texBuff ] ));

		## テクスチャが存在しない場合
		} else {
			## 線形補間を行う。
			VTX_PushVertex( $vertexBuff, VTX_MakeUnlitVertex(
			[ $vertexBuff1->[$i]->{"VECTOR"}->[0] * $pers2 + $vertexBuff2->[$i]->{"VECTOR"}->[0] * $pers1,
			  $vertexBuff1->[$i]->{"VECTOR"}->[1] * $pers2 + $vertexBuff2->[$i]->{"VECTOR"}->[1] * $pers1,
			  $vertexBuff1->[$i]->{"VECTOR"}->[2] * $pers2 + $vertexBuff2->[$i]->{"VECTOR"}->[2] * $pers1 ],
			[ $vertexBuff1->[$i]->{"NORMAL"}->[0] * $pers2 + $vertexBuff2->[$i]->{"NORMAL"}->[0] * $pers1,
			  $vertexBuff1->[$i]->{"NORMAL"}->[1] * $pers2 + $vertexBuff2->[$i]->{"NORMAL"}->[1] * $pers1,
			  $vertexBuff1->[$i]->{"NORMAL"}->[2] * $pers2 + $vertexBuff2->[$i]->{"NORMAL"}->[2] * $pers1 ] ));
		}
	}

	## 頂点バッファを設定する。
	return $vertexBuff;
}


###
## XY平面上のベジェ曲線をＹ軸で回転させたメッシュを作成する。
##
## XY平面(2D)のX正領域上に定義された制御頂点リストから
## ベジェ曲線をXY平面上に描く。
## それを Y軸で回転させたメッシュを作成する。
## 始点、終点はY軸上(x要素が0)である必要がある。
##
## @param1 VECTOR2配列 XY平面上のX正領域頂点座標(ベジェ曲線の制御点配列)
## @param2 曲線分割数  ベジェ曲線の分割数(整数)
## @param3 Deg         Y軸の回転刻み
##
sub MSH_CreateBezierRotationY {
	my ($trVec, $pch, $angle) = @_;

	my $bezierBox = [];
	for(my $i = 0; $i <= $pch; $i++) {

		## 頂点をバッファに入れ替える
		my @vertBuff = @$trVec;
		## 補間割合を求める。
		my $t = $i/$pch;

		## 曲線上の頂点の座標を求める。
		for (1..$#$trVec) {
			for(my $j = 0; $j < $#vertBuff; $j++) {
				## 各頂点要素について補間する
				$vertBuff[$j] = [ $vertBuff[$j]->[0] * (1 - $t) + $vertBuff[$j+1]->[0] * $t,
							  $vertBuff[$j]->[1] * (1 - $t) + $vertBuff[$j+1]->[1] * $t ];
			}
			pop(@vertBuff);
		}

		## 求めた曲線上の点を格納する。
		push(@$bezierBox, $vertBuff[0]);
	}

	return MSH_CreateRotationY($bezierBox, $angle);

}


###
## ベジェ曲線を作成する。
## 4つ以上の制御点からベジェ曲線を描く。
##
## @param1 VECTOR3配列  [[x0,y0,z0],[x1,y1,z1],[x2,y2,z2],[x3,y3,z3]] 制御点
## @param2 曲線分割数  ベジェ曲線の分割数(整数)
##
sub MSH_CreateBezierLine {
	my ($trVec, $pch) = @_;

	my $bezierBox = [];
	for(my $i = 0; $i <= $pch; $i++) {

		## 頂点をバッファに入れ替える
		my @vertBuff = @$trVec;
		## 補間割合を求める。
		my $t = $i/$pch;

		## 曲線上の頂点の座標を求める。
		for (1..$#$trVec) {
			for(my $j = 0; $j < $#vertBuff; $j++) {
				## 各頂点要素について補間する
				$vertBuff[$j] = [ $vertBuff[$j]->[0] * (1 - $t) + $vertBuff[$j+1]->[0] * $t,
								  $vertBuff[$j]->[1] * (1 - $t) + $vertBuff[$j+1]->[1] * $t,
								  $vertBuff[$j]->[2] * (1 - $t) + $vertBuff[$j+1]->[2] * $t ];
			}
			pop(@vertBuff);
		}

		## 求めた曲線上の点を格納する。
		push(@$bezierBox, $vertBuff[0]);
	}

	return $bezierBox;
}


###
## ベジェ曲面を作成する。
##
## 4つ以上のベジェ曲線を連続的な制御点としてベジェ曲面を描く。
##
## @param1 VECTOR3の n X m 行列  [[[x00,y00,z00],[x01,y01,z01],[x02,y02,z02],[x03,y03,z03]],
##								  [[x10,y10,z10],[x11,y11,z11],[x12,y12,z12],[x13,y13,z13]],
##								  [[x20,y20,z20],[x21,y21,z21],[x22,y22,z22],[x23,y23,z23]],
##								  [[x30,y30,z30],[x31,y31,z31],[x32,y32,z32],[x33,y33,z33]]]
##								i行で表されるベジェ曲線を m列分作成する。
##								作成されたm本のベジェ曲線を制御点とするベジェ曲面を作成する。
## @param2 曲線分割数  第１段階で作成するベジェ曲線の分割数(整数)
## @param3 曲線分割数  第２段階で作成するベジェ曲線の分割数(整数)
## @param4 テクスチャ座標 [[tu1, tv1],[tu2, tv2],[tu3, tv3]・・・] 
##         各テクスチャステージの平面矩形右上座標
##         ( 平面矩形左下座標は全てのテクスチャステージにおいて [0,0] 固定とする。)
##
sub MSH_CreateBezierPlane {
	my ($trVec, $xPch, $yPch, $texV) = @_;

	## 第１段階ベジェ曲線を求める。
	my @bezierBox = ();
	for(my $bCnt = 0; $bCnt <= $#$trVec; $bCnt++) {
		$bezierBox[$bCnt] = [];
		for(my $i = 0; $i <= $xPch; $i++) {

			## 頂点をバッファに入れ替える
			my @vertBuff = @{$trVec->[$bCnt]};
			## 補間割合を求める。
			my $t = $i/$xPch;

			## 曲線上の頂点の座標を求める。
			for (1..$#{$trVec->[$bCnt]}) {
				for(my $j = 0; $j < $#vertBuff; $j++) {
					## 各頂点要素について補間する
					$vertBuff[$j] = [ $vertBuff[$j]->[0] * (1 - $t) + $vertBuff[$j+1]->[0] * $t,
									  $vertBuff[$j]->[1] * (1 - $t) + $vertBuff[$j+1]->[1] * $t,
									  $vertBuff[$j]->[2] * (1 - $t) + $vertBuff[$j+1]->[2] * $t];
				}
				pop(@vertBuff);
			}

			## 求めた曲線上の点を格納する。
			push(@{$bezierBox[$bCnt]}, $vertBuff[0]);
		}
	}

	## 第２段階ベジェ曲線を求める
	my @bezier2Box = ();
	my @normalBox = ();
	for(my $b2Cnt = 0; $b2Cnt <= $xPch; $b2Cnt++) {
		for(my $i = 0; $i <= $yPch; $i++) {

			## 頂点をバッファに入れ替える
			my @vertBuff = ();
			map { push(@vertBuff, $_->[$b2Cnt]) } @bezierBox;

			## 補間割合を求める。
			my $t = $i/$yPch;

			## 曲線上の頂点の座標を求める。
			for (1..$#bezierBox) {
				for(my $j = 0; $j < $#vertBuff; $j++) {
					## 各頂点要素について補間する
					$vertBuff[$j] = [ $vertBuff[$j]->[0] * (1 - $t) + $vertBuff[$j+1]->[0] * $t,
									  $vertBuff[$j]->[1] * (1 - $t) + $vertBuff[$j+1]->[1] * $t,
									  $vertBuff[$j]->[2] * (1 - $t) + $vertBuff[$j+1]->[2] * $t];
				}
				pop(@vertBuff);
			}

			## 求めた曲線上の点を格納する。(このとき対応法線ベクトルを初期化しておく)
			push(@bezier2Box, $vertBuff[0]);
			push(@normalBox, [0,0,0]);
		}
	}

	## 各頂点の法線ベクトルを求める
	for (my $i = 0; $i < $xPch; $i++) {
		my $ind1 = 0;
		my $ind2 = $i * ($yPch + 1);
		my $ind3 = $ind2 + $yPch + 1;

		for ( my $j = 0; $j < $yPch * 2; $j++) {
			## プリミティブを取得するためのインデックスを求める。
			$ind1 = $ind2;
			$ind2 = $ind3;
			$ind3 = ( $ind2 < ($i + 1) * ($yPch + 1) ? $ind2 + $yPch + 1 : $ind2 - $yPch );

			## 三角形の法線ベクトルを求める
			my $vAx = $bezier2Box[$ind1]->[0] - $bezier2Box[$ind2]->[0];
			my $vAy = $bezier2Box[$ind1]->[1] - $bezier2Box[$ind2]->[1];
			my $vAz = $bezier2Box[$ind1]->[2] - $bezier2Box[$ind2]->[2];

			my $vBx = $bezier2Box[$ind3]->[0] - $bezier2Box[$ind2]->[0];
			my $vBy = $bezier2Box[$ind3]->[1] - $bezier2Box[$ind2]->[1];
			my $vBz = $bezier2Box[$ind3]->[2] - $bezier2Box[$ind2]->[2];

			## 外積を求める
			my $cVx = $vAy * $vBz - $vAz * $vBy;
			my $cVy = $vAz * $vBx - $vAx * $vBz;
			my $cVz = $vAx * $vBy - $vAy * $vBx;

			## 正規化する
			my $len = sqrt($cVx**2 + $cVy**2 + $cVz**2);
			$cVx = $cVx / $len;
			$cVy = $cVy / $len;
			$cVz = $cVz / $len;

			## 法線ベクトルを三角形の所属する頂点に足しこむ
			if ( $j % 2 == 1 ) {
				$normalBox[$ind1]->[0] += $cVx;
				$normalBox[$ind1]->[1] += $cVy;
				$normalBox[$ind1]->[2] += $cVz;
				$normalBox[$ind2]->[0] += $cVx;
				$normalBox[$ind2]->[1] += $cVy;
				$normalBox[$ind2]->[2] += $cVz;
				$normalBox[$ind3]->[0] += $cVx;
				$normalBox[$ind3]->[1] += $cVy;
				$normalBox[$ind3]->[2] += $cVz;
			} else {
				$normalBox[$ind1]->[0] -= $cVx;
				$normalBox[$ind1]->[1] -= $cVy;
				$normalBox[$ind1]->[2] -= $cVz;
				$normalBox[$ind2]->[0] -= $cVx;
				$normalBox[$ind2]->[1] -= $cVy;
				$normalBox[$ind2]->[2] -= $cVz;
				$normalBox[$ind3]->[0] -= $cVx;
				$normalBox[$ind3]->[1] -= $cVy;
				$normalBox[$ind3]->[2] -= $cVz;
			}

		}
	}

	my $vertexBuff = VTX_CreateVertexBuffer();
	## テクスチャが存在する場合の頂点作成
	if ($texV) {
		my $indexCounta = 0;
		for( my $i = 0; $i <= $xPch ; $i++) {
			for( my $j = 0; $j <= $yPch ; $j++) {
				my $tpX = $i / $xPch;
				my $tpY = $j / $yPch;

				my @texBuff = ();
				map { push(@texBuff, [$tpX * $_->[0], $tpY * $_->[1]]) } @$texV;
				VTX_PushVertex( $vertexBuff,
					VTX_MakeUnlitVertex( $bezier2Box[$indexCounta], $normalBox[$indexCounta], [@texBuff] ));
				$indexCounta++;
			}
		}

	## テクスチャが存在しない場合の頂点作成
	} else {
		for my $i (0..$#bezier2Box) {
			VTX_PushVertex( $vertexBuff, VTX_MakeUnlitVertex( $bezier2Box[$i], $normalBox[$i]));
		}
	}

	## 頂点バッファ、プリミティブタイプ、オプションを設定する。
	return ($vertexBuff, 'D3DPT_MSH_PLANERECT', [$xPch, $yPch]);

}


####
## フラクタルな山岳地形を作成する。
## バッファの数からnを求める。
##
sub MSH_CreateMountains {
	my ($vBuff) = @_;

	## バッファの要素数から現在の n を求める。但し、n=1,2,3,4～
	my $En = $#$vBuff + 1;
	my ($n, $Dn);
	for($n = 1; $n < 100 ; $n++) {
		$Dn = 2**($n-1);
		last if ($En == ($Dn+1)*($Dn+2)/2);
	}

	## これ以上の細分化は不可能なので終了
	return if ($n >= 100);

	## VECTOR格納用配列
	my @wBuff = ();
	for(my $i=0; $i<$Dn ;$i++) {
		for(my $j=0; $j<=$i ;$j++) {
			my $r1 = $i*($i+1)/2+$j;
			my $r2 = ($i+1)*($i+2)/2+$j;
			my $r3 = ($i+1)*($i+2)/2+$j+1;
			my $s1 = $i*(2*$i+1)+2*$j;
			my $s2 = ($i+1)*(2*$i+3)+2*$j;
			my $s3 = ($i+1)*(2*$i+3)+2*$j+2;
			my $s4 = ($i+1)*(2*$i+1)+2*$j;
			my $s5 = ($i+1)*(2*$i+1)+2*$j+1;
			my $s6 = ($i+1)*(2*$i+3)+2*$j+1;
			$wBuff[$s1] = $vBuff->[$r1]->{"VECTOR"};
			$wBuff[$s2] = $vBuff->[$r2]->{"VECTOR"};
			$wBuff[$s3] = $vBuff->[$r3]->{"VECTOR"};

			## 三角形の法線ベクトルを求める。(Y軸に対応)
			my ($nX, $nY, $nZ) = triangleNorm($wBuff[$s1], $wBuff[$s2], $wBuff[$s3]);
			## 三角形の辺を表すベクトルを取得する。(Z軸に対応)
			my $vR1R2 = VEC_Vec3Normalize(VEC_Vec3Subtract($wBuff[$s2], $wBuff[$s1]));
			my $vR2R3 = VEC_Vec3Normalize(VEC_Vec3Subtract($wBuff[$s3], $wBuff[$s2]));
			my $vR3R1 = VEC_Vec3Normalize(VEC_Vec3Subtract($wBuff[$s1], $wBuff[$s3]));
			## 法線ベクトルと辺ベクトルの外積を求める。(X軸に対応)
			my $cR1R2 = VEC_Vec3Normalize(VEC_Vec3Cross([$nX, $nY, $nZ], $vR1R2));
			my $cR2R3 = VEC_Vec3Normalize(VEC_Vec3Cross([$nX, $nY, $nZ], $vR2R3));
			my $cR3R1 = VEC_Vec3Normalize(VEC_Vec3Cross([$nX, $nY, $nZ], $vR3R1));
			## 各辺の中点を求める。
			my $mR1R2 = VEC_Vec3Scale(VEC_Vec3Add($vBuff->[$r1]->{"VECTOR"}, $vBuff->[$r2]->{"VECTOR"}), 0.5);
			my $mR2R3 = VEC_Vec3Scale(VEC_Vec3Add($vBuff->[$r1]->{"VECTOR"}, $vBuff->[$r3]->{"VECTOR"}), 0.5);
			my $mR3R1 = VEC_Vec3Scale(VEC_Vec3Add($vBuff->[$r2]->{"VECTOR"}, $vBuff->[$r3]->{"VECTOR"}), 0.5);
			## 変換行列を求める。
			my $matR1R2 =  [[$cR1R2->[0], $cR1R2->[1], $cR1R2->[2], 0.0], [$nX, $nY, $nZ, 0.0],
							[$vR1R2->[0], $vR1R2->[1], $vR1R2->[2], 0.0], [$mR1R2->[0], $mR1R2->[1], $mR1R2->[2], 1.0]];
			my $matR2R3 =  [[$cR2R3->[0], $cR2R3->[1], $cR2R3->[2], 0.0], [$nX, $nY, $nZ, 0.0],
							[$vR2R3->[0], $vR2R3->[1], $vR2R3->[2], 0.0], [$mR2R3->[0], $mR2R3->[1], $mR2R3->[2], 1.0]];
			my $matR3R1 =  [[$cR3R1->[0], $cR3R1->[1], $cR3R1->[2], 0.0], [$nX, $nY, $nZ, 0.0],
							[$vR3R1->[0], $vR3R1->[1], $vR3R1->[2], 0.0], [$mR3R1->[0], $mR3R1->[1], $mR3R1->[2], 1.0]];
			## 各辺の長さを求める。
			my $lenR1R2 = VEC_Vec3Length(VEC_Vec3Subtract($wBuff[$s2], $wBuff[$s1]));
			my $lenR2R3 = VEC_Vec3Length(VEC_Vec3Subtract($wBuff[$s3], $wBuff[$s2]));
			my $lenR3R1 = VEC_Vec3Length(VEC_Vec3Subtract($wBuff[$s1], $wBuff[$s3]));

			## ランダムな角度を取得する。
			my $jigen = 2.08;
			my $tbt = (($lenR1R2**2)*(2**((-1)*(4/$jigen))-2**((-1)*2)))**(1/2);
			my $rad1 = MAT_DegToRad(rand(360));
			## my $rad1 = MAT_DegToRad(40);
			my $x11 = $tbt * sin($rad1);
			my $y11 = $tbt * cos($rad1);
			my $rad2 = MAT_DegToRad(rand(360));
			## my $rad2 = MAT_DegToRad(40);
			my $x22 = $tbt * sin($rad2);
			my $y22 = $tbt * cos($rad2);
			my $rad3 = MAT_DegToRad(rand(360));
			## my $rad3 = MAT_DegToRad(40);
			my $x33 = $tbt * sin($rad3);
			my $y33 = $tbt * cos($rad3);
			$wBuff[$s4] = VEC_Vec3TransformCoord([$x11,$y11,0], $matR1R2);
			$wBuff[$s5] = VEC_Vec3TransformCoord([$x22,$y22,0], $matR2R3);
			$wBuff[$s6] = VEC_Vec3TransformCoord([$x33,$y33,0], $matR3R1);
		}
	}

	## 法線ベクトル格納用バッファの初期化
	my @wNormBuff = ();
	for(0..$#wBuff){
		push(@wNormBuff, [0,0,0]);
	}

	## 法線ベクトルを求める。
	my $Dn1 = 2*$Dn;
	for(my $i=0; $i<$Dn1 ;$i++) {
		for(my $j=0; $j<=$i ;$j++) {
			my $r1 = $i*($i+1)/2+$j;
			my $r2 = ($i+1)*($i+2)/2+$j;
			my $r3 = ($i+1)*($i+2)/2+$j+1;

			## TriangleBの法線を求める。
			if ($j > 0) {
				my $r4 = $i*($i+1)/2+$j-1;
				my ($nX,$nY,$nZ) = triangleNorm($wBuff[$r4], $wBuff[$r2], $wBuff[$r1]);
				$wNormBuff[$r4]->[0] += $nX;
				$wNormBuff[$r4]->[1] += $nY;
				$wNormBuff[$r4]->[2] += $nZ;
				$wNormBuff[$r2]->[0] += $nX;
				$wNormBuff[$r2]->[1] += $nY;
				$wNormBuff[$r2]->[2] += $nZ;
				$wNormBuff[$r1]->[0] += $nX;
				$wNormBuff[$r1]->[1] += $nY;
				$wNormBuff[$r1]->[2] += $nZ;

			}

			## TriangleAの法線を求める。
			my ($nX,$nY,$nZ) = triangleNorm($wBuff[$r1], $wBuff[$r2], $wBuff[$r3]);
			$wNormBuff[$r1]->[0] += $nX;
			$wNormBuff[$r1]->[1] += $nY;
			$wNormBuff[$r1]->[2] += $nZ;
			$wNormBuff[$r2]->[0] += $nX;
			$wNormBuff[$r2]->[1] += $nY;
			$wNormBuff[$r2]->[2] += $nZ;
			$wNormBuff[$r3]->[0] += $nX;
			$wNormBuff[$r3]->[1] += $nY;
			$wNormBuff[$r3]->[2] += $nZ;

		}
	}

	my $vertexBuff = VTX_CreateVertexBuffer();
	## テクスチャが存在しない場合の頂点作成
	for my $i (0..$#wBuff) {
		VTX_PushVertex( $vertexBuff, VTX_MakeUnlitVertex( $wBuff[$i], $wNormBuff[$i]));
	}

	## 頂点バッファ、プリミティブタイプ、オプションを設定する。
	return ($vertexBuff, 'D3DPT_MSH_MOUNTAINS', [$Dn1]);

}



####
## フラクタルな山岳地形を作成する。
## バッファの数からnを求める。
##
sub MSH_CreateMountainsLast {
	my ($vBuff) = @_;

	## バッファの要素数から現在の n を求める。但し、n=1,2,3,4～
	my $En = $#$vBuff + 1;
	my ($n, $Dn);
	for($n = 1; $n < 100 ; $n++) {
		$Dn = 2**($n-1);
		last if ($En == ($Dn+1)*($Dn+2)/2);
	}

	## これ以上の細分化は不可能なので終了
	return if ($n >= 100);

	## VECTOR格納用配列
	my @wBuff = ();
	for(my $i=0; $i<$Dn ;$i++) {
		for(my $j=0; $j<=$i ;$j++) {
			my $r1 = $i*($i+1)/2+$j;
			my $r2 = ($i+1)*($i+2)/2+$j;
			my $r3 = ($i+1)*($i+2)/2+$j+1;
			my $s1 = $i*(2*$i+1)+2*$j;
			my $s2 = ($i+1)*(2*$i+3)+2*$j;
			my $s3 = ($i+1)*(2*$i+3)+2*$j+2;
			my $s4 = ($i+1)*(2*$i+1)+2*$j;
			my $s5 = ($i+1)*(2*$i+1)+2*$j+1;
			my $s6 = ($i+1)*(2*$i+3)+2*$j+1;
			$wBuff[$s1] = $vBuff->[$r1]->{"VECTOR"};
			$wBuff[$s2] = $vBuff->[$r2]->{"VECTOR"};
			$wBuff[$s3] = $vBuff->[$r3]->{"VECTOR"};

			## 三角形の法線ベクトルを求める。(Y軸に対応)
			my ($nX, $nY, $nZ) = triangleNorm($wBuff[$s1], $wBuff[$s2], $wBuff[$s3]);
			## 三角形の辺を表すベクトルを取得する。(Z軸に対応)
			my $vR1R2 = VEC_Vec3Normalize(VEC_Vec3Subtract($wBuff[$s2], $wBuff[$s1]));
			my $vR2R3 = VEC_Vec3Normalize(VEC_Vec3Subtract($wBuff[$s3], $wBuff[$s2]));
			my $vR3R1 = VEC_Vec3Normalize(VEC_Vec3Subtract($wBuff[$s1], $wBuff[$s3]));
			## 法線ベクトルと辺ベクトルの外積を求める。(X軸に対応)
			my $cR1R2 = VEC_Vec3Normalize(VEC_Vec3Cross([$nX, $nY, $nZ], $vR1R2));
			my $cR2R3 = VEC_Vec3Normalize(VEC_Vec3Cross([$nX, $nY, $nZ], $vR2R3));
			my $cR3R1 = VEC_Vec3Normalize(VEC_Vec3Cross([$nX, $nY, $nZ], $vR3R1));
			## 各辺の中点を求める。
			my $mR1R2 = VEC_Vec3Scale(VEC_Vec3Add($vBuff->[$r1]->{"VECTOR"}, $vBuff->[$r2]->{"VECTOR"}), 0.5);
			my $mR2R3 = VEC_Vec3Scale(VEC_Vec3Add($vBuff->[$r1]->{"VECTOR"}, $vBuff->[$r3]->{"VECTOR"}), 0.5);
			my $mR3R1 = VEC_Vec3Scale(VEC_Vec3Add($vBuff->[$r2]->{"VECTOR"}, $vBuff->[$r3]->{"VECTOR"}), 0.5);
			## 変換行列を求める。
			my $matR1R2 =  [[$cR1R2->[0], $cR1R2->[1], $cR1R2->[2], 0.0], [$nX, $nY, $nZ, 0.0],
							[$vR1R2->[0], $vR1R2->[1], $vR1R2->[2], 0.0], [$mR1R2->[0], $mR1R2->[1], $mR1R2->[2], 1.0]];
			my $matR2R3 =  [[$cR2R3->[0], $cR2R3->[1], $cR2R3->[2], 0.0], [$nX, $nY, $nZ, 0.0],
							[$vR2R3->[0], $vR2R3->[1], $vR2R3->[2], 0.0], [$mR2R3->[0], $mR2R3->[1], $mR2R3->[2], 1.0]];
			my $matR3R1 =  [[$cR3R1->[0], $cR3R1->[1], $cR3R1->[2], 0.0], [$nX, $nY, $nZ, 0.0],
							[$vR3R1->[0], $vR3R1->[1], $vR3R1->[2], 0.0], [$mR3R1->[0], $mR3R1->[1], $mR3R1->[2], 1.0]];
			## 各辺の長さを求める。
			my $lenR1R2 = VEC_Vec3Length(VEC_Vec3Subtract($wBuff[$s2], $wBuff[$s1]));
			my $lenR2R3 = VEC_Vec3Length(VEC_Vec3Subtract($wBuff[$s3], $wBuff[$s2]));
			my $lenR3R1 = VEC_Vec3Length(VEC_Vec3Subtract($wBuff[$s1], $wBuff[$s3]));

			## ランダムな角度を取得する。
			my $jigen = 2.08;
			my $tbt = (($lenR1R2**2)*(2**((-1)*(4/$jigen))-2**((-1)*2)))**(1/2);
			my $rad1 = MAT_DegToRad(rand(360));
			## my $rad1 = MAT_DegToRad(40);
			my $x11 = $tbt * sin($rad1);
			my $y11 = $tbt * cos($rad1);
			my $rad2 = MAT_DegToRad(rand(360));
			## my $rad2 = MAT_DegToRad(40);
			my $x22 = $tbt * sin($rad2);
			my $y22 = $tbt * cos($rad2);
			my $rad3 = MAT_DegToRad(rand(360));
			## my $rad3 = MAT_DegToRad(40);
			my $x33 = $tbt * sin($rad3);
			my $y33 = $tbt * cos($rad3);
			$wBuff[$s4] = VEC_Vec3TransformCoord([$x11,$y11,0], $matR1R2);
			$wBuff[$s5] = VEC_Vec3TransformCoord([$x22,$y22,0], $matR2R3);
			$wBuff[$s6] = VEC_Vec3TransformCoord([$x33,$y33,0], $matR3R1);
		}
	}

	my $primCnt = 0;
	my $vertexBuff = VTX_CreateVertexBuffer();
	## 法線ベクトルを求める。
	my $Dn1 = 2*$Dn;
	for(my $i=0; $i<$Dn1 ;$i++) {
		for(my $j=0; $j<=$i ;$j++) {
			my $r1 = $i*($i+1)/2+$j;
			my $r2 = ($i+1)*($i+2)/2+$j;
			my $r3 = ($i+1)*($i+2)/2+$j+1;

			## TriangleBの法線を求める。
			if ($j > 0) {
				my $r4 = $i*($i+1)/2+$j-1;
				my ($nX,$nY,$nZ) = triangleNorm($wBuff[$r4], $wBuff[$r2], $wBuff[$r1]);
				VTX_PushVertex( $vertexBuff, VTX_MakeUnlitVertex( [@{$wBuff[$r4]}], [$nX, $nY, $nZ]));
				VTX_PushVertex( $vertexBuff, VTX_MakeUnlitVertex( [@{$wBuff[$r2]}], [$nX, $nY, $nZ]));
				VTX_PushVertex( $vertexBuff, VTX_MakeUnlitVertex( [@{$wBuff[$r1]}], [$nX, $nY, $nZ]));
				$primCnt++;
			}

			## TriangleAの法線を求める。
			my ($nX,$nY,$nZ) = triangleNorm($wBuff[$r1], $wBuff[$r2], $wBuff[$r3]);
			VTX_PushVertex( $vertexBuff, VTX_MakeUnlitVertex( [@{$wBuff[$r1]}], [$nX, $nY, $nZ]));
			VTX_PushVertex( $vertexBuff, VTX_MakeUnlitVertex( [@{$wBuff[$r2]}], [$nX, $nY, $nZ]));
			VTX_PushVertex( $vertexBuff, VTX_MakeUnlitVertex( [@{$wBuff[$r3]}], [$nX, $nY, $nZ]));
			$primCnt++;
		}
	}

	return ($vertexBuff, 'D3DPT_TRIANGLELIST' ,$primCnt);
}



####
##
## 三角形ABCの法線ベクトルを求める。
## @param1 VECTOR3 点A
## @param2 VECTOR3 点B
## @param3 VECTOR3 点C
##
sub triangleNorm {
	my ($vA, $vB, $vC) = @_;

	## 三角形の法線ベクトルを求める
	my $vABx = $vC->[0] - $vA->[0];
	my $vABy = $vC->[1] - $vA->[1];
	my $vABz = $vC->[2] - $vA->[2];
	my $vACx = $vB->[0] - $vA->[0];
	my $vACy = $vB->[1] - $vA->[1];
	my $vACz = $vB->[2] - $vA->[2];

	## 外積を求める
	my $vNx = $vABy * $vACz - $vABz * $vACy;
	my $vNy = $vABz * $vACx - $vABx * $vACz;
	my $vNz = $vABx * $vACy - $vABy * $vACx;

	## 正規化する
	my $len = sqrt($vNx**2 + $vNy**2 + $vNz**2);
	return ($vNx/$len, $vNy/$len, $vNz/$len);

}

1;

