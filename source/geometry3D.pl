##_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
## Prefix Is GEO
##_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
use strict;
require '..\PY3D\vector3D.pl';
require '..\PY3D\matrix3D.pl';
require '..\PY3D\pixel3D.pl';
require '..\PY3D\vertex3D.pl';


#######################################################################
## (1) ポリゴンの頂点データを読み込む
##
## (2) ポリゴンの頂点データに対して頂点シェーダを実行
##
## (3) クリッピング、Ｗ除算、ビューポート変換などを行う
##
## (4) 頂点データをポリゴン内部の全てのピクセルについて補間
##
## (5) ポリゴン内部の全てのピクセルデータについてピクセルシェーダを実行し、色を計算
##
## (6) フォグブレンド、アルファテスト、ステンシルテスト、デプステスト、アルファブレンディングなどを行う
##
## (7) レンダリングターゲットサーフェスに色を書き込む 
##
#######################################################################


###
## レンダリングを行う。
##
## @param1 レンダリングターゲットサーフェス
## @param2 レンダリングステートオブジェクト
## @param3 プリミティブタイプ
## @param4 頂点バッファ
## @param5 オプション（プリミティブタイプにより用途は異なる）
##
sub GEO_DrawPrimitive {
	my ($tSurface, $rs, $primitiveType, $vertexBuffer, $primitiveOption) = @_;

	## ライティング・トランスフォームを行う。
	my $vertexStream = GEO_PipeLine($vertexBuffer, $rs);

	## ビューポート変換行列を作成する。
	my $width2  = $#{$tSurface->[0]}/2;
	my $height2 = $#$tSurface/2;
	my $matTranceformVP = MAT_MMultiply(MAT_MScaling($width2, $height2, 1),
										MAT_MTranslate($width2, $height2, 0));

	## 三角形リストの場合
	if ($primitiveType eq 'D3DPT_TRIANGLELIST') {
		for ( my $i = 0; $i < $primitiveOption; $i++) {

			## プリミティブを取得するためのインデックスを求める。
			my $ind1 = 0 + 3 * $i;
			my $ind2 = 1 + 3 * $i;
			my $ind3 = 2 + 3 * $i;

			## クリッピング判定を行う。
			next if (GEO_IsClipping($vertexStream->[$ind1],
									$vertexStream->[$ind2],
									$vertexStream->[$ind3]));

			## ビューポート変換・Ｗ除算を行う。
			## ピクセル補間を行い、レンダリングターゲットサーフェスに対して書き込む。
			PXL_PixelShader($tSurface, $rs, PXL_VertexToPixel( GEO_ScaleToViewPort($matTranceformVP,
									$vertexStream->[$ind1], $vertexStream->[$ind2], $vertexStream->[$ind3])));
		}

	## 三角形ストリップの場合
	} elsif ($primitiveType eq 'D3DPT_TRIANGLESTRIP') {
		for ( my $i = 0; $i < $primitiveOption; $i++) {

			## プリミティブを取得するためのインデックスを求める。
			my $ind1 = 0 + $i;
			my $ind2 = 1 + $i;
			my $ind3 = 2 + $i;

			## クリッピング判定を行う。
			next if (GEO_IsClipping($vertexStream->[$ind1],
									$vertexStream->[$ind2],
									$vertexStream->[$ind3]));

			## ビューポート変換・Ｗ除算を行う。
			## ピクセル補間を行い、レンダリングターゲットサーフェスに対して書き込む。
			PXL_PixelShader($tSurface, $rs, PXL_VertexToPixel( GEO_ScaleToViewPort($matTranceformVP,
									$vertexStream->[$ind1], $vertexStream->[$ind2], $vertexStream->[$ind3])));

		}

	## Ｙ軸回転メッシュの場合(MSH_CreateRotationYによって作成された場合)
	} elsif ($primitiveType eq 'D3DPT_MSH_ROTATIONY') {

		my $transVertexCnt = $primitiveOption->[0];
		my $vertexListCnt = $primitiveOption->[1];

		for my $listNum (1..$vertexListCnt) {
			my $startIndPos = 2 + ($listNum - 1)*$transVertexCnt;
			my $ind1 = 0; my $ind2 = 0; my $ind3 = $startIndPos;

			for(my $primN = 0 ; $primN < $transVertexCnt*2; $primN++) {
				## 頂点バッファのインデックスを求める
				$ind1 = $ind2;
				$ind2 = $ind3;
				$ind3 = ($ind2 < $startIndPos + $transVertexCnt ?
					 		$ind2 + $transVertexCnt : $ind2 - $transVertexCnt + 1);
				$ind3 = 1 if ($primN == $transVertexCnt*2-1);

				## クリッピング判定を行う。
				next if (GEO_IsClipping($vertexStream->[$ind1],
										$vertexStream->[$ind2],
										$vertexStream->[$ind3]));

				## ビューポート変換・Ｗ除算を行う。
				## ピクセル補間を行い、レンダリングターゲットサーフェスに対して書き込む。
				PXL_PixelShader($tSurface, $rs, PXL_VertexToPixel( GEO_ScaleToViewPort($matTranceformVP,
									$vertexStream->[$ind1], $vertexStream->[$ind2], $vertexStream->[$ind3])));
			}
		}

	## Ｙ軸回転トーラス型メッシュの場合(MSH_CreateTorusによって作成された場合)
	} elsif ($primitiveType eq 'D3DPT_MSH_TORUS') {

		for (my $i = 0; $i < $primitiveOption->[0]; $i++) {
			my $ind1 = 0;
			my $ind2 = $i * ($primitiveOption->[1] + 1);
			my $ind3 = $ind2 + $primitiveOption->[1] + 1;

			for ( my $j = 0; $j < $primitiveOption->[1] * 2; $j++) {

				## プリミティブを取得するためのインデックスを求める。
				$ind1 = $ind2;
				$ind2 = $ind3;
				$ind3 = ( $ind2 < ($i + 1) * ($primitiveOption->[1] + 1) ?
											$ind2 + $primitiveOption->[1] + 1 : $ind2 - $primitiveOption->[1] );

				## クリッピング判定を行う。
				next if (GEO_IsClipping($vertexStream->[$ind1],
										$vertexStream->[$ind2],
										$vertexStream->[$ind3]));

				## ビューポート変換・Ｗ除算を行う。
				## ピクセル補間を行い、レンダリングターゲットサーフェスに対して書き込む。
				PXL_PixelShader($tSurface, $rs, PXL_VertexToPixel( GEO_ScaleToViewPort($matTranceformVP,
										$vertexStream->[$ind1], $vertexStream->[$ind2], $vertexStream->[$ind3])));

			}
		}

	## 平面矩形メッシュの場合(MSH_CreatePlaneRectによって作成された場合)
	} elsif ($primitiveType eq 'D3DPT_MSH_PLANERECT') {

		for (my $i = 0; $i < $primitiveOption->[0]; $i++) {
			my $ind1 = 0;
			my $ind2 = $i * ($primitiveOption->[1] + 1);
			my $ind3 = $ind2 + $primitiveOption->[1] + 1;

			for ( my $j = 0; $j < $primitiveOption->[1] * 2; $j++) {

				## プリミティブを取得するためのインデックスを求める。
				$ind1 = $ind2;
				$ind2 = $ind3;
				$ind3 = ( $ind2 < ($i + 1) * ($primitiveOption->[1] + 1) ?
											$ind2 + $primitiveOption->[1] + 1 : $ind2 - $primitiveOption->[1] );

				## クリッピング判定を行う。
				next if (GEO_IsClipping($vertexStream->[$ind1],
										$vertexStream->[$ind2],
										$vertexStream->[$ind3]));

				## ビューポート変換・Ｗ除算を行う。
				## ピクセル補間を行い、レンダリングターゲットサーフェスに対して書き込む。
				PXL_PixelShader($tSurface, $rs, PXL_VertexToPixel( GEO_ScaleToViewPort($matTranceformVP,
										$vertexStream->[$ind1], $vertexStream->[$ind2], $vertexStream->[$ind3])));

			}
		}

	## 山岳地形フラクタルメッシュの場合(MSH_CreateMountainsによって作成された場合)
	} elsif ($primitiveType eq 'D3DPT_MSH_MOUNTAINS') {
		for (my $i = 0; $i < $primitiveOption->[0]; $i++) {
			for ( my $j = 0; $j <= $i; $j++) {
				my $r1 = $i*($i+1)/2+$j;
				my $r2 = ($i+1)*($i+2)/2+$j;
				my $r3 = ($i+1)*($i+2)/2+$j+1;

				## TriangleBの描画
				if ($j > 0) {
					my $r4 = $i*($i+1)/2+$j-1;
					## クリッピング判定を行う。
					next if (GEO_IsClipping($vertexStream->[$r4],
											$vertexStream->[$r2],
											$vertexStream->[$r1]));

					## ビューポート変換・Ｗ除算を行う。
					## ピクセル補間を行い、レンダリングターゲットサーフェスに対して書き込む。
					PXL_PixelShader($tSurface, $rs, PXL_VertexToPixel( GEO_ScaleToViewPort($matTranceformVP,
										$vertexStream->[$r4], $vertexStream->[$r2], $vertexStream->[$r1])));
				}

				## TriangleAの描画
				## クリッピング判定を行う。
				next if (GEO_IsClipping($vertexStream->[$r1],
										$vertexStream->[$r2],
										$vertexStream->[$r3]));

				## ビューポート変換・Ｗ除算を行う。
				## ピクセル補間を行い、レンダリングターゲットサーフェスに対して書き込む。
				PXL_PixelShader($tSurface, $rs, PXL_VertexToPixel( GEO_ScaleToViewPort($matTranceformVP,
									$vertexStream->[$r1], $vertexStream->[$r2], $vertexStream->[$r3])));
			}
		}
	}

}


###
## ワイヤーフレームとしてレンダリングを行う。
##
## @param1 レンダリングターゲットサーフェス
## @param2 レンダリングステートオブジェクト
## @param3 プリミティブタイプ
## @param4 頂点バッファ
## @param5 オプション（プリミティブタイプにより用途は異なる）
##
sub GEO_DrawPrimitiveLine {
	my ($tSurface, $rs, $primitiveType, $vertexBuffer, $primitiveOption) = @_;

	## ビューポート変換行列を作成する。
	my $width2  = $#{$tSurface->[0]}/2;
	my $height2 = $#$tSurface/2;
	my $matTranceformVP = MAT_MMultiply(MAT_MScaling($width2, $height2, 1),
										MAT_MTranslate($width2, $height2, 0));

	## ワールド X ビュー X 射影 X ビューポート変換 を求める。
	my $matWVPV = MAT_MMultiply( $rs->{"RS_TS_WORLD"},
								 $rs->{"RS_TS_VIEW"},
								 $rs->{"RS_TS_PROJECTION"},
								 $matTranceformVP);

	## ビューポート変換を行う。
	my @linesVer = map { VEC_Vec3TransformCoord($_->{"VECTOR"}, $matWVPV) } @$vertexBuffer;

	## 三角形リストの場合
	if ($primitiveType eq 'D3DPT_TRIANGLELIST') {
		for ( my $i = 0; $i < $primitiveOption; $i++) {

			## プリミティブを取得するためのインデックスを求める。
			my $ind1 = 0 + 3 * $i;
			my $ind2 = 1 + 3 * $i;
			my $ind3 = 2 + 3 * $i;

			## クリッピング判定を行う。
			next if ($linesVer[$ind1]->[2] < 0 || $linesVer[$ind1]->[2] > 1 ||
					 $linesVer[$ind2]->[2] < 0 || $linesVer[$ind2]->[2] > 1 ||
					 $linesVer[$ind3]->[2] < 0 || $linesVer[$ind3]->[2] > 1 ||
					 $linesVer[$ind1]->[0] < 0 || $linesVer[$ind1]->[0] > $#{$tSurface->[0]} ||
					 $linesVer[$ind2]->[0] < 0 || $linesVer[$ind2]->[0] > $#{$tSurface->[0]} ||
					 $linesVer[$ind3]->[0] < 0 || $linesVer[$ind3]->[0] > $#{$tSurface->[0]} ||
					 $linesVer[$ind1]->[1] < 0 || $linesVer[$ind1]->[1] > $#$tSurface ||
					 $linesVer[$ind2]->[1] < 0 || $linesVer[$ind2]->[1] > $#$tSurface ||
					 $linesVer[$ind3]->[1] < 0 || $linesVer[$ind3]->[1] > $#$tSurface);

			## 三角形を描画する。
			PXL_PixelShaderLine($tSurface, $rs->{"RS_LINE_COLOR"},
								$linesVer[$ind1]->[0], $linesVer[$ind1]->[1],
								$linesVer[$ind2]->[0], $linesVer[$ind2]->[1]);
			PXL_PixelShaderLine($tSurface, $rs->{"RS_LINE_COLOR"},
								$linesVer[$ind2]->[0], $linesVer[$ind2]->[1],
								$linesVer[$ind3]->[0], $linesVer[$ind3]->[1]);
			PXL_PixelShaderLine($tSurface, $rs->{"RS_LINE_COLOR"},
								$linesVer[$ind3]->[0], $linesVer[$ind3]->[1],
								$linesVer[$ind1]->[0], $linesVer[$ind1]->[1]);
		}

	## 三角形ストリップの場合
	} elsif ($primitiveType eq 'D3DPT_TRIANGLESTRIP') {
		for ( my $i = 0; $i < $primitiveOption; $i++) {

			## プリミティブを取得するためのインデックスを求める。
			my $ind1 = 0 + $i;
			my $ind2 = 1 + $i;
			my $ind3 = 2 + $i;

			## クリッピング判定を行う。
			next if ($linesVer[$ind1]->[2] < 0 || $linesVer[$ind1]->[2] > 1 ||
					 $linesVer[$ind2]->[2] < 0 || $linesVer[$ind2]->[2] > 1 ||
					 $linesVer[$ind3]->[2] < 0 || $linesVer[$ind3]->[2] > 1 ||
					 $linesVer[$ind1]->[0] < 0 || $linesVer[$ind1]->[0] > $#{$tSurface->[0]} ||
					 $linesVer[$ind2]->[0] < 0 || $linesVer[$ind2]->[0] > $#{$tSurface->[0]} ||
					 $linesVer[$ind3]->[0] < 0 || $linesVer[$ind3]->[0] > $#{$tSurface->[0]} ||
					 $linesVer[$ind1]->[1] < 0 || $linesVer[$ind1]->[1] > $#$tSurface ||
					 $linesVer[$ind2]->[1] < 0 || $linesVer[$ind2]->[1] > $#$tSurface ||
					 $linesVer[$ind3]->[1] < 0 || $linesVer[$ind3]->[1] > $#$tSurface);

			## 三角形を描画する。
			PXL_PixelShaderLine($tSurface, $rs->{"RS_LINE_COLOR"},
								$linesVer[$ind1]->[0], $linesVer[$ind1]->[1],
								$linesVer[$ind2]->[0], $linesVer[$ind2]->[1]);
			PXL_PixelShaderLine($tSurface, $rs->{"RS_LINE_COLOR"},
								$linesVer[$ind2]->[0], $linesVer[$ind2]->[1],
								$linesVer[$ind3]->[0], $linesVer[$ind3]->[1]);
			PXL_PixelShaderLine($tSurface, $rs->{"RS_LINE_COLOR"},
								$linesVer[$ind3]->[0], $linesVer[$ind3]->[1],
								$linesVer[$ind1]->[0], $linesVer[$ind1]->[1]);

		}

	## Ｙ軸回転メッシュの場合(MSH_CreateRotationYによって作成された場合)
	} elsif ($primitiveType eq 'D3DPT_MSH_ROTATIONY') {

		my $transVertexCnt = $primitiveOption->[0];
		my $vertexListCnt = $primitiveOption->[1];

		for my $listNum (1..$vertexListCnt) {
			my $startIndPos = 2 + ($listNum - 1)*$transVertexCnt;
			my $ind1 = 0; my $ind2 = 0; my $ind3 = $startIndPos;

			for(my $primN = 0 ; $primN < $transVertexCnt*2; $primN++) {
				## 頂点バッファのインデックスを求める
				$ind1 = $ind2;
				$ind2 = $ind3;
				$ind3 = ($ind2 < $startIndPos + $transVertexCnt ?
					 		$ind2 + $transVertexCnt : $ind2 - $transVertexCnt + 1);
				$ind3 = 1 if ($primN == $transVertexCnt*2-1);

				## クリッピング判定を行う。
				next if ($linesVer[$ind1]->[2] < 0 || $linesVer[$ind1]->[2] > 1 ||
						 $linesVer[$ind2]->[2] < 0 || $linesVer[$ind2]->[2] > 1 ||
						 $linesVer[$ind3]->[2] < 0 || $linesVer[$ind3]->[2] > 1 ||
						 $linesVer[$ind1]->[0] < 0 || $linesVer[$ind1]->[0] > $#{$tSurface->[0]} ||
						 $linesVer[$ind2]->[0] < 0 || $linesVer[$ind2]->[0] > $#{$tSurface->[0]} ||
						 $linesVer[$ind3]->[0] < 0 || $linesVer[$ind3]->[0] > $#{$tSurface->[0]} ||
						 $linesVer[$ind1]->[1] < 0 || $linesVer[$ind1]->[1] > $#$tSurface ||
						 $linesVer[$ind2]->[1] < 0 || $linesVer[$ind2]->[1] > $#$tSurface ||
						 $linesVer[$ind3]->[1] < 0 || $linesVer[$ind3]->[1] > $#$tSurface);

				## 三角形を描画する。
				PXL_PixelShaderLine($tSurface, $rs->{"RS_LINE_COLOR"},
									$linesVer[$ind1]->[0], $linesVer[$ind1]->[1],
									$linesVer[$ind2]->[0], $linesVer[$ind2]->[1]);
				PXL_PixelShaderLine($tSurface, $rs->{"RS_LINE_COLOR"},
									$linesVer[$ind2]->[0], $linesVer[$ind2]->[1],
									$linesVer[$ind3]->[0], $linesVer[$ind3]->[1]);
				PXL_PixelShaderLine($tSurface, $rs->{"RS_LINE_COLOR"},
									$linesVer[$ind3]->[0], $linesVer[$ind3]->[1],
									$linesVer[$ind1]->[0], $linesVer[$ind1]->[1]);

			}
		}

	## Ｙ軸回転トーラス型メッシュの場合(MSH_CreateTorusによって作成された場合)
	} elsif ($primitiveType eq 'D3DPT_MSH_TORUS') {

		for (my $i = 0; $i < $primitiveOption->[0]; $i++) {
			my $ind1 = 0;
			my $ind2 = $i * ($primitiveOption->[1] + 1);
			my $ind3 = $ind2 + $primitiveOption->[1] + 1;

			for ( my $j = 0; $j < $primitiveOption->[1] * 2; $j++) {

				## プリミティブを取得するためのインデックスを求める。
				$ind1 = $ind2;
				$ind2 = $ind3;
				$ind3 = ( $ind2 < ($i + 1) * ($primitiveOption->[1] + 1) ?
											$ind2 + $primitiveOption->[1] + 1 : $ind2 - $primitiveOption->[1] );

				## クリッピング判定を行う。
				next if ($linesVer[$ind1]->[2] < 0 || $linesVer[$ind1]->[2] > 1 ||
						 $linesVer[$ind2]->[2] < 0 || $linesVer[$ind2]->[2] > 1 ||
						 $linesVer[$ind3]->[2] < 0 || $linesVer[$ind3]->[2] > 1 ||
						 $linesVer[$ind1]->[0] < 0 || $linesVer[$ind1]->[0] > $#{$tSurface->[0]} ||
						 $linesVer[$ind2]->[0] < 0 || $linesVer[$ind2]->[0] > $#{$tSurface->[0]} ||
						 $linesVer[$ind3]->[0] < 0 || $linesVer[$ind3]->[0] > $#{$tSurface->[0]} ||
						 $linesVer[$ind1]->[1] < 0 || $linesVer[$ind1]->[1] > $#$tSurface ||
						 $linesVer[$ind2]->[1] < 0 || $linesVer[$ind2]->[1] > $#$tSurface ||
						 $linesVer[$ind3]->[1] < 0 || $linesVer[$ind3]->[1] > $#$tSurface);

				## 三角形を描画する。
				PXL_PixelShaderLine($tSurface, $rs->{"RS_LINE_COLOR"},
									$linesVer[$ind1]->[0], $linesVer[$ind1]->[1],
									$linesVer[$ind2]->[0], $linesVer[$ind2]->[1]);
				PXL_PixelShaderLine($tSurface, $rs->{"RS_LINE_COLOR"},
									$linesVer[$ind2]->[0], $linesVer[$ind2]->[1],
									$linesVer[$ind3]->[0], $linesVer[$ind3]->[1]);
				PXL_PixelShaderLine($tSurface, $rs->{"RS_LINE_COLOR"},
									$linesVer[$ind3]->[0], $linesVer[$ind3]->[1],
									$linesVer[$ind1]->[0], $linesVer[$ind1]->[1]);

			}
		}

	## 平面矩形メッシュの場合(MSH_CreatePlaneRectによって作成された場合)
	} elsif ($primitiveType eq 'D3DPT_MSH_PLANERECT') {

		for (my $i = 0; $i < $primitiveOption->[0]; $i++) {
			my $ind1 = 0;
			my $ind2 = $i * ($primitiveOption->[1] + 1);
			my $ind3 = $ind2 + $primitiveOption->[1] + 1;

			for ( my $j = 0; $j < $primitiveOption->[1] * 2; $j++) {

				## プリミティブを取得するためのインデックスを求める。
				$ind1 = $ind2;
				$ind2 = $ind3;
				$ind3 = ( $ind2 < ($i + 1) * ($primitiveOption->[1] + 1) ?
											$ind2 + $primitiveOption->[1] + 1 : $ind2 - $primitiveOption->[1] );

				## クリッピング判定を行う。
				next if ($linesVer[$ind1]->[2] < 0 || $linesVer[$ind1]->[2] > 1 ||
						 $linesVer[$ind2]->[2] < 0 || $linesVer[$ind2]->[2] > 1 ||
						 $linesVer[$ind3]->[2] < 0 || $linesVer[$ind3]->[2] > 1 ||
						 $linesVer[$ind1]->[0] < 0 || $linesVer[$ind1]->[0] > $#{$tSurface->[0]} ||
						 $linesVer[$ind2]->[0] < 0 || $linesVer[$ind2]->[0] > $#{$tSurface->[0]} ||
						 $linesVer[$ind3]->[0] < 0 || $linesVer[$ind3]->[0] > $#{$tSurface->[0]} ||
						 $linesVer[$ind1]->[1] < 0 || $linesVer[$ind1]->[1] > $#$tSurface ||
						 $linesVer[$ind2]->[1] < 0 || $linesVer[$ind2]->[1] > $#$tSurface ||
						 $linesVer[$ind3]->[1] < 0 || $linesVer[$ind3]->[1] > $#$tSurface);

				## 三角形を描画する。
				PXL_PixelShaderLine($tSurface, $rs->{"RS_LINE_COLOR"},
									$linesVer[$ind1]->[0], $linesVer[$ind1]->[1],
									$linesVer[$ind2]->[0], $linesVer[$ind2]->[1]);
				PXL_PixelShaderLine($tSurface, $rs->{"RS_LINE_COLOR"},
									$linesVer[$ind2]->[0], $linesVer[$ind2]->[1],
									$linesVer[$ind3]->[0], $linesVer[$ind3]->[1]);
				PXL_PixelShaderLine($tSurface, $rs->{"RS_LINE_COLOR"},
									$linesVer[$ind3]->[0], $linesVer[$ind3]->[1],
									$linesVer[$ind1]->[0], $linesVer[$ind1]->[1]);
			}
		}

	## 山岳地形フラクタルメッシュの場合(MSH_CreateMountainsによって作成された場合)
	} elsif ($primitiveType eq 'D3DPT_MSH_MOUNTAINS') {
		for (my $i = 0; $i < $primitiveOption->[0]; $i++) {
			for ( my $j = 0; $j <= $i; $j++) {
				my $r1 = $i*($i+1)/2+$j;
				my $r2 = ($i+1)*($i+2)/2+$j;
				my $r3 = ($i+1)*($i+2)/2+$j+1;

				## TriangleAの描画
				## クリッピング判定を行う。
				next if ($linesVer[$r1]->[2] < 0 || $linesVer[$r1]->[2] > 1 ||
						 $linesVer[$r2]->[2] < 0 || $linesVer[$r2]->[2] > 1 ||
						 $linesVer[$r3]->[2] < 0 || $linesVer[$r3]->[2] > 1 ||
						 $linesVer[$r1]->[0] < 0 || $linesVer[$r1]->[0] > $#{$tSurface->[0]} ||
						 $linesVer[$r2]->[0] < 0 || $linesVer[$r2]->[0] > $#{$tSurface->[0]} ||
						 $linesVer[$r3]->[0] < 0 || $linesVer[$r3]->[0] > $#{$tSurface->[0]} ||
						 $linesVer[$r1]->[1] < 0 || $linesVer[$r1]->[1] > $#$tSurface ||
						 $linesVer[$r2]->[1] < 0 || $linesVer[$r2]->[1] > $#$tSurface ||
						 $linesVer[$r3]->[1] < 0 || $linesVer[$r3]->[1] > $#$tSurface);

				## 三角形を描画する。
				PXL_PixelShaderLine($tSurface, $rs->{"RS_LINE_COLOR"},
									$linesVer[$r1]->[0], $linesVer[$r1]->[1],
									$linesVer[$r2]->[0], $linesVer[$r2]->[1]);
				PXL_PixelShaderLine($tSurface, $rs->{"RS_LINE_COLOR"},
									$linesVer[$r2]->[0], $linesVer[$r2]->[1],
									$linesVer[$r3]->[0], $linesVer[$r3]->[1]);
				PXL_PixelShaderLine($tSurface, $rs->{"RS_LINE_COLOR"},
									$linesVer[$r3]->[0], $linesVer[$r3]->[1],
									$linesVer[$r1]->[0], $linesVer[$r1]->[1]);
			}
		}

	## 線ストリップの場合
	} elsif ($primitiveType eq 'D3DPT_LINESTRIP') {
		for ( my $i = 0; $i < $primitiveOption; $i++) {
			my $ind1 = $i;
			my $ind2 = $i+1;

			## クリッピング判定を行う。
			next if ($linesVer[$ind1]->[2] < 0 || $linesVer[$ind1]->[2] > 1 ||
					 $linesVer[$ind2]->[2] < 0 || $linesVer[$ind2]->[2] > 1 ||
					 $linesVer[$ind1]->[0] < 0 || $linesVer[$ind1]->[0] > $#{$tSurface->[0]} ||
					 $linesVer[$ind2]->[0] < 0 || $linesVer[$ind2]->[0] > $#{$tSurface->[0]} ||
					 $linesVer[$ind1]->[1] < 0 || $linesVer[$ind1]->[1] > $#$tSurface ||
					 $linesVer[$ind2]->[1] < 0 || $linesVer[$ind2]->[1] > $#$tSurface);

			## 線を描画する。
			PXL_PixelShaderLine($tSurface, $rs->{"RS_LINE_COLOR"},
								$linesVer[$ind1]->[0], $linesVer[$ind1]->[1],
								$linesVer[$ind2]->[0], $linesVer[$ind2]->[1]);
		}
	}

}


###
## ジオメトリパイプライン
##
sub GEO_PipeLine {
	my ($vertexBuffer, $rs) = @_;

	## ワールド X ビュー 行列を求める。
	my $matWV = MAT_MMultiply($rs->{"RS_TS_WORLD"}, $rs->{"RS_TS_VIEW"});
	## ワールド X ビュー X 射影 行列を求める。
	my $matWVP = MAT_MMultiply($rs->{"RS_TS_WORLD"}, $rs->{"RS_TS_VIEW"}, $rs->{"RS_TS_PROJECTION"});

	## 頂点バッファ内の各頂点について処理を行う。
	my $vertexStream = VTX_CreateVertexBuffer();
	for my $vtx (@{$vertexBuffer}) {

		## カメラ空間での頂点座標・法線ベクトルをそれぞれ求める。
		my $v = VEC_Vec3TransformCoord($vtx->{"VECTOR"}, $matWV);
		my $n = VEC_Vec3Normalize( VEC_Vec3TransformNormal($vtx->{"NORMAL"}, $matWV));

		## 射影トランスフォームを行う。（トランスフォーム処理）
		## 頂点色を求める。(ライティング処理)
		## 頂点フォーマットを TRANSLITVERTEX へ変換する。
		## 頂点バッファに詰め込む。
		VTX_PushVertex($vertexStream, VTX_MakeTransLitVertex( 
				VEC_Vec3Transform($vtx->{"VECTOR"}, $matWVP), LIT_Lighting($v, $n, $rs), $vtx->{'TEX'}));

	}

	return $vertexStream;
}


###
## クリッピングが必要な場合は1、それ以外は 0 を返す。
##
## １つのプリミティブ(三角形)を形成する３つの頂点全てが
## 下記範囲外に存在する頂点はクリッピング対象となる。
## -w <= x <= w
## -w <= y <= w
##  0 <= z <= w
##
sub GEO_IsClipping {
	my ($vertex1, $vertex2, $vertex3) = @_;

	## 各頂点の同次の値を取得する。
	my $pw1 = $vertex1->{"VECTOR"}->[3];
	$pw1 *= -1 if ($pw1 < 0);
	my $pw2 = $vertex2->{"VECTOR"}->[3];
	$pw2 *= -1 if ($pw2 < 0);
	my $pw3 = $vertex3->{"VECTOR"}->[3];
	$pw3 *= -1 if ($pw3 < 0);

	## クリッピング判定を行う。
	return 1 if ((($vertex1->{"VECTOR"}->[0] > $pw1) || ($vertex1->{"VECTOR"}->[0] < ($pw1)*(-1)) ||
				  ($vertex1->{"VECTOR"}->[1] > $pw1) || ($vertex1->{"VECTOR"}->[1] < ($pw1)*(-1)) ||
				  ($vertex1->{"VECTOR"}->[2] > $pw1) || ($vertex1->{"VECTOR"}->[2] < 0 ))  &&
				 (($vertex2->{"VECTOR"}->[0] > $pw2) || ($vertex2->{"VECTOR"}->[0] < ($pw2)*(-1)) ||
				  ($vertex2->{"VECTOR"}->[1] > $pw2) || ($vertex2->{"VECTOR"}->[1] < ($pw2)*(-1)) ||
				  ($vertex2->{"VECTOR"}->[2] > $pw2) || ($vertex2->{"VECTOR"}->[2] < 0 ))  &&
				 (($vertex3->{"VECTOR"}->[0] > $pw3) || ($vertex3->{"VECTOR"}->[0] < ($pw3)*(-1)) ||
				  ($vertex3->{"VECTOR"}->[1] > $pw3) || ($vertex3->{"VECTOR"}->[1] < ($pw3)*(-1)) ||
				  ($vertex3->{"VECTOR"}->[2] > $pw3) || ($vertex3->{"VECTOR"}->[2] < 0 )));

	return 0;

}


###
## ビューポート変換・Ｗ除算を行い、
## 頂点フォーマットを TRANSLITVERTEX → VEWPORTVERTEX へ変換する。
##
sub GEO_ScaleToViewPort {
	my $mat = shift;

	my @list = @_;
	return map { my $vec = VEC_Vec4Transform($_->{"VECTOR"}, $mat);
				 $_ = VTX_MakeVewportVertex([$vec->[0]/$vec->[3], $vec->[1]/$vec->[3]],
				 $vec->[2]/$vec->[3], 1/$vec->[3], $_->{"DIFFUSE"}, $_->{"SPECULAR"}, $_->{"TEX"}); } @list;
}

1;
