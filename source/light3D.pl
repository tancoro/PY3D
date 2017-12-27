##_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
## Prefix Is LIT
##_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
use strict;
require '..\PY3D\vector3D.pl';


##########################################
##【 Light の定義 】
##
##  Light->{"TYPE"} = 'LIGHT_POINT' or 'LIGHT_DIRECTIONAL';
##  Light->{"DIFFUSE"} = [r, g, b, a];
##  Light->{"SPECULAR"} = [r, g, b, a];
##  Light->{"AMBIENT"} = [r, g, b, a];
##  Light->{"POSITION"} = [x, y, z]; ワールド空間での光源の位置 (LIGHT_POINTの場合のみ効果あり)
##  Light->{"DIRECTION"} = [x, y, z]; ワールド空間での光線ベクトル (LIGHT_DIRECTIONALの場合のみ効果あり)
##  Light->{"ATTENUATION"} = [a0, a1, a2];  光の輝度の距離に対する減衰度。(LIGHT_POINTの場合のみ効果あり)
##
##【 Material の定義 】
##
##  Material->{"DIFFUSE"} = [r, g, b, a];
##  Material->{"SPECULAR"} = [r, g, b, a];
##  Material->{"AMBIENT"} = [r, g, b, a];
##  Material->{"EMISSIVE"} = [r, g, b, a];
##  Material->{"POWER"} = flot; スペキュラハイライトの鮮明度を指定する浮動小数点値。
##
##########################################


###
## 新規のディレクショナルライトを作成します。
##
## @param1 $diffuse [r,g,b,a]
## @param2 $specular [r,g,b,a]
## @param3 $ambient [r,g,b,a]
## @param4 $direction [x, y, z]
## @return ディレクショナルライトオブジェクト
##
sub LIT_CreateDirectionalLight {
	my ($diffuse, $specular, $ambient, $direction) = @_;

	my $light = {	TYPE=>'LIGHT_DIRECTIONAL',
					DIFFUSE=>[@$diffuse],
					SPECULAR=>[@$specular],
					AMBIENT=>[@$ambient],
					DIRECTION=>[@$direction] };
	return $light;
}


###
## 新規のポイントライトを作成します。
##
## @param1 $diffuse [r,g,b,a]
## @param2 $specular [r,g,b,a]
## @param3 $ambient [r,g,b,a]
## @param4 $position [x, y, z]
## @param5 $attenuation = [a0, a1, a2]
## @return ポイントライトオブジェクト
##
sub LIT_CreatePointLight {
	my ($diffuse, $specular, $ambient, $position, $attenuation) = @_;

	my $light = {	TYPE=>'LIGHT_POINT',
					DIFFUSE=>[@$diffuse],
					SPECULAR=>[@$specular],
					AMBIENT=>[@$ambient],
					POSITION=>[@$position],
					ATTENUATION=>[@$attenuation] };
	return $light;
}


###
## 新規のマテリアルを作成します。
##
## @param1 $diffuse [r,g,b,a]
## @param2 $specular [r,g,b,a]
## @param3 $ambient [r,g,b,a]
## @param4 $emissive [r,g,b,a]
## @param5 $power = 浮動小数値 スペキュラハイライトの鮮明度
## @return マテリアルオブジェクト
##
sub LIT_CreateMaterial {
	my ($diffuse, $specular, $ambient, $emissive, $power) = @_;

	my $material = {DIFFUSE=>[@$diffuse],
					SPECULAR=>[@$specular],
					AMBIENT=>[@$ambient],
					EMISSIVE=>[@$emissive],
					POWER=>$power};

	return $material;
}


###
## ライティングを行う。
##
## @param1 VECTOR3 カメラ空間での頂点座標
## @param2 VECTOR3 カメラ空間での頂点の法線(正規化されたもの）
## @param3 RenderState レンダリングステートオブジェクト
## @return (Diffuse, Specular) ライティング後の頂点の色
##
sub LIT_Lighting {
	my ($v, $n, $rs) = @_;

	## マテリアルを取得する。
	my $material = $rs->{"RS_MATERIAL"};

	## ライトから影響される各色を用意する。
	my ($lightDiffRed, $lightDiffGreen, $lightDiffBlue) = (0,0,0);
	my ($lightSpecRed, $lightSpecGreen, $lightSpecBlue) = (0,0,0);

	## ライトの個数分処理をする。
	foreach my $light (@{$rs->{"RS_LIGHT"}}) {

		## 変数宣言
		my $ld = [0,0,1]; my $att= 1;

		## ディレクショナルライトの場合
		if ($light->{"TYPE"} eq 'LIGHT_DIRECTIONAL') {
			## ライトへの方向ベクトルを求める。
			$ld = VEC_Vec3Scale(
						VEC_Vec3Normalize(
							VEC_Vec3TransformNormal($light->{"DIRECTION"}, $rs->{"RS_TS_VIEW"})), -1);

		## ポイントライトの場合
		} elsif ($light->{"TYPE"} eq 'LIGHT_POINT') {

			## 頂点からライトへ向くベクトルを求める。
			my $vLp = VEC_Vec3Subtract( VEC_Vec3TransformCoord($light->{"POSITION"}, $rs->{"RS_TS_VIEW"}), $v);
			## 頂点 - ライト間の距離を求める。
			my $d = VEC_Vec3Length($vLp);

			## ライトへの方向ベクトルを求める。
			## VEC_VecPrint($vLp) if ($vLp->[0] == 0 && $vLp->[1] == 0 && $vLp->[2] == 0);
			$ld = VEC_Vec3Normalize($vLp);
			## ライトの減衰係数を求める。
			$att = 1 / ( $light->{"ATTENUATION"}->[0] + 
							$light->{"ATTENUATION"}->[1] * $d + 
								$light->{"ATTENUATION"}->[2] * $d**2 );
		}

		## 視点へのベクトルを求める。
		my $vPe = VEC_Vec3Normalize( VEC_Vec3Scale($v, -1));
		## ライトへのベクトルと視点へのベクトルの間の中間ベクトルを求める。
		my $h = VEC_Vec3Normalize( VEC_Vec3Add($vPe, $ld));
		## スペキュラ反射率(中間ベクトルと法線ベクトルの内積)を求める。
		my $rSp = VEC_Vec3Dot($n, $h);
		$rSp = 1 if ($rSp > 1);
		$rSp = 0 if ($rSp < 0);

		## ライトへの方向ベクトルと法線ベクトルの内積を求める。
		my $nldcos = VEC_Vec3Dot($n, $ld);
		$nldcos = 1 if ($nldcos > 1);
		$nldcos = 0 if ($nldcos < 0);

		## ライトの影響から受けるディフェーズ色を求める。
		$lightDiffRed += $att * ($material->{"DIFFUSE"}->[0] * $light->{"DIFFUSE"}->[0] * $nldcos + 
											$material->{"AMBIENT"}->[0] * $light->{"AMBIENT"}->[0]);
		$lightDiffGreen += $att * ($material->{"DIFFUSE"}->[1] * $light->{"DIFFUSE"}->[1] * $nldcos + 
											$material->{"AMBIENT"}->[1] * $light->{"AMBIENT"}->[1]);
		$lightDiffBlue += $att * ($material->{"DIFFUSE"}->[2] * $light->{"DIFFUSE"}->[2] * $nldcos + 
											$material->{"AMBIENT"}->[2] * $light->{"AMBIENT"}->[2]);

		## ライトの影響から受けるスペキュラ色を求める。
		$lightSpecRed += $att * ($rSp**$material->{"POWER"}) * $light->{"SPECULAR"}->[0];
		$lightSpecGreen += $att * ($rSp**$material->{"POWER"}) * $light->{"SPECULAR"}->[1];
		$lightSpecBlue += $att * ($rSp**$material->{"POWER"}) * $light->{"SPECULAR"}->[2];

	}

	## ディフェーズ色を格納する。
	my $vtxDiffuse = [		$material->{"AMBIENT"}->[0] * $rs->{"RS_AMBIENT"}->[0] + 
										$material->{"EMISSIVE"}->[0] + $lightDiffRed ,
							$material->{"AMBIENT"}->[1] * $rs->{"RS_AMBIENT"}->[1] + 
										$material->{"EMISSIVE"}->[1] + $lightDiffGreen ,
							$material->{"AMBIENT"}->[2] * $rs->{"RS_AMBIENT"}->[2] + 
										$material->{"EMISSIVE"}->[2] + $lightDiffBlue ,
							$material->{"DIFFUSE"}->[3] ];

	## スペキュラ色を格納する。
	my $vtxSpecular = [		$material->{"SPECULAR"}->[0] * $lightSpecRed,
							$material->{"SPECULAR"}->[1] * $lightSpecGreen,
							$material->{"SPECULAR"}->[2] * $lightSpecBlue,
							$material->{"SPECULAR"}->[3]];


	return ($vtxDiffuse, $vtxSpecular);
}

1;
