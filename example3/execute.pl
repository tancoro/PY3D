use strict;
require '..\PY3D\renderState3D.pl';
require '..\PY3D\geometry3D.pl';
require '..\PY3D\vertex3D.pl';
require '..\PY3D\vector3D.pl';
require '..\PY3D\matrix3D.pl';
require '..\PY3D\light3D.pl';
require '..\PY3D\pixel3D.pl';
require '..\PY3D\mesh3D.pl';

main();

sub main {
	my $argPara = $ARGV[0];

	## レンダリングターゲットサーフェスを作成する。
	my $tSurface = RST_CreateTargetSurface(600,600, RST_ToColor(0x00,0x00,0x00,0x00));
	## 反射用のサーフェースを作成する。
	my $tSurface2 = RST_CreateTargetSurface(600,600, RST_ToColor(0x00,0x00,0x00,0x00));

	## レンダリングステートオブジェクトを作成する。
	my $rs = RST_CreateRenderState();
	## ビュー行列を設定する。
	RST_SetRenderState($rs, 'RS_TS_VIEW', MAT_MMultiply(
								MAT_MRotationX(MAT_DegToRad(-40)),
								MAT_MTranslate(0, 0, 150)));
	## 射影行列を設定する。
	RST_SetRenderState($rs, 'RS_TS_PROJECTION',
						MAT_MProjection(30, 2000, MAT_DegToRad(60), MAT_DegToRad(60)));

	## ライトを設定する。
	RST_SetRenderState($rs, 'RS_LIGHT', [
	  LIT_CreateDirectionalLight(RST_ToColor(0xC0,0xC0,0xC0),RST_ToColor(0xA0,0xA0,0xA0),RST_ToColor(0,0,0,0),[1, -3, 1]),
	  LIT_CreatePointLight(RST_ToColor(0xE0,0xE0,0xEF,0), RST_ToColor(0xD0,0xE0,0xF0,0), RST_ToColor(0,0,0,0), [ 80, 30, 80], [2, 0, 0]),
	  LIT_CreatePointLight(RST_ToColor(0xE0,0xE0,0xEF,0), RST_ToColor(0xD0,0xE0,0xF0,0), RST_ToColor(0,0,0,0), [-80, 30, 80], [2, 0, 0]),
	  LIT_CreatePointLight(RST_ToColor(0xE0,0xE0,0xEF,0), RST_ToColor(0xD0,0xE0,0xF0,0), RST_ToColor(0,0,0,0), [-80, 30,-80], [2, 0, 0]),
	  LIT_CreatePointLight(RST_ToColor(0xE0,0xE0,0xEF,0), RST_ToColor(0xD0,0xE0,0xF0,0), RST_ToColor(0,0,0,0), [ 80, 30,-80], [2, 0, 0])]);

	## XZ平面に対する反転行列を作成する。
	my $xzRMat = [[ 1.0, 0.0, 0.0, 0.0],
				  [ 0.0,-1.0, 0.0, 0.0],
				  [ 0.0, 0.0, 1.0, 0.0],
				  [ 0.0, 0.0, 0.0, 1.0]];
	##
	##【描画順序】
	##
	## 鏡面用サーフェスを取得する。
	## 鏡面用サーフェスの描画領域のステンシルバッファ値を1とする。
	## クリッピングを行う領域をステンシルバッファに設定する。
	##
	##
	##
	##
	##

	## オブジェクトの描画
	## print 'ObjectB 作成中・・・', "\n";
	## drawObjectB($tSurface, $rs);
	print 'ObjectA 作成中・・・', "\n";
	drawObjectA($tSurface, $rs, $xzRMat);
	print 'ObjectC 作成中・・・', "\n";
	drawObjectC($tSurface, $rs, $xzRMat);

	## BMPファイルに出力する。
	print 'ファイル出力中・・・・', "\n";
	RST_PrintOutToBmp($tSurface, 'test'.$argPara.'.bmp');

}


##
## オブジェクトA を描画する。
##
sub drawObjectA {
	my ($tSurface, $rs, $xzRMat) = @_;

	## トーラスを作成し、マテリアルを設定する。
	my ($vertexBuff, $primType, $primOption ) = 
	MSH_CreateTorus([[10,-10],[10,0],[10,10],[15, 12],[20,14],[25,12],
						 [30, 10],[30,0],[30,-10],[25,-12],[20,-14],[15,-12]],10, [[4,4]]);
	RST_SetRenderState($rs, 'RS_MATERIAL', LIT_CreateMaterial(
				RST_ToColor(0x80,0x80,0x80,0x40), RST_ToColor(0xA0,0xA0,0xA0,0),
						RST_ToColor(0x00,0x00,0x00,0), RST_ToColor(0x00,0x00,0x00,0), 30));

	## テクスチャの読み込みを行う。
	my $tex1 = TEX_CreateTextureFromFile('tex.bmp');
	RST_SetRenderState($rs,'RS_TS_TEXTURE', [$tex1]);
	RST_SetRenderState($rs,'RS_TSS_ADDRESSU', ['TADDRESS_WRAP']);


	## Zバッファをクリアし、アルファブレンディングを ON にする。
	## また、VIEW行列にXZ平面に対する鏡面反射行列を設定する。
	RST_ClearZInTargetSurface($tSurface, 1.0);
	RST_SetRenderState($rs, 'RS_ALPHABLENDENABLE', 'TRUE');
	my $vMat = RST_GetRenderState($rs, 'RS_TS_VIEW');
	RST_SetRenderState($rs, 'RS_TS_VIEW', MAT_MMultiply($xzRMat,$vMat));

	## プリミティブの描画を行う。
	print 'ObjectA1 描画中・・・・', "\n";
	RST_SetRenderState($rs,'RS_TS_WORLD', MAT_MMultiply(
											MAT_MTranslate(0, 14, 0),
											MAT_MRotationX(MAT_DegToRad(0))));
	GEO_DrawPrimitive($tSurface, $rs, $primType, $vertexBuff, $primOption);

	## Zバッファをクリアし、アルファブレンディングを OFF にする。
	## また、VIEW行列を正常状態に戻す。
	RST_ClearZInTargetSurface($tSurface, 1.0);
	RST_SetRenderState($rs, 'RS_ALPHABLENDENABLE', 'FALSE');
	RST_SetRenderState($rs, 'RS_TS_VIEW', $vMat);

	## プリミティブの描画を行う。
	print 'ObjectA2 描画中・・・・', "\n";
	GEO_DrawPrimitive($tSurface, $rs, $primType, $vertexBuff, $primOption);

}


##
## オブジェクトB を描画する。
##
sub drawObjectB {
	my ($tSurface, $rs) = @_;

	## 面を作成し、マテリアルを設定する。
	my ($vertexBuff, $primType, $primOption ) =  MSH_CreatePlaneRect([200,200], 50, 50, [[4,4]]);
	RST_SetRenderState($rs, 'RS_MATERIAL', LIT_CreateMaterial(
				RST_ToColor(0x90,0x90,0x90,0xFF), RST_ToColor(0xD0,0xD0,0xD0,0),
						RST_ToColor(0x00,0x00,0x00,0), RST_ToColor(0x00,0x00,0x00,0), 100));

	## テクスチャの読み込みを行う。
	my $tex1 = TEX_CreateTextureFromFile('moku.bmp');
	RST_SetRenderState($rs,'RS_TS_TEXTURE', [$tex1]);
	RST_SetRenderState($rs,'RS_TSS_ADDRESSU', ['TADDRESS_WRAP']);
	## RST_SetRenderState($rs,'RS_TSS_ADDRESSU', ['TADDRESS_CLAMP']);
	## RST_SetRenderState($rs,'RS_TSS_ADDRESSU', ['TADDRESS_MIRROR']);

	## 机を描画
	print '机描画中・・・・', "\n";
	RST_SetRenderState($rs,'RS_TS_WORLD', MAT_MMultiply(
											MAT_MTranslate(-100, -100, 0),
											MAT_MRotationX(MAT_DegToRad(90))));
	GEO_DrawPrimitive($tSurface, $rs, $primType, $vertexBuff, $primOption);

}


##
## オブジェクトCを描画する。
##
sub drawObjectC {
	my ($tSurface, $rs, $xzRMat) = @_;

	## 回転オブジェクトを作成し、マテリアルを設定する。
	my ($vertexBuff, $primType, $primOption ) =
		MSH_CreateRotationY([[0,30],[5,30],[5,20],[5,10],[5,0],[0,0]], 5);
	RST_SetRenderState($rs, 'RS_MATERIAL', LIT_CreateMaterial(
				RST_ToColor(0x50,0x30,0x30,0x40), RST_ToColor(0xF0,0xF0,0xF0,0x00),
						RST_ToColor(0x00,0x00,0x00,0), RST_ToColor(0x00,0x00,0x00,0), 50));
	my $objW1 = MAT_MTranslate(30,0,-35);
	my $objW2 = MAT_MMultiply(
				MAT_MTranslate(0,-15,0),
				MAT_MRotationX(MAT_DegToRad(90)),
				MAT_MTranslate(0,5,0),
				MAT_MRotationY(MAT_DegToRad(-50)),
				MAT_MTranslate(-35,0,-50));

	## Zバッファをクリアし、アルファブレンディングを ON にする。
	## また、VIEW行列にXZ平面に対する鏡面反射行列を設定する。
	RST_ClearZInTargetSurface($tSurface, 1.0);
	RST_SetRenderState($rs, 'RS_ALPHABLENDENABLE', 'TRUE');
	my $vMat = RST_GetRenderState($rs, 'RS_TS_VIEW');
	RST_SetRenderState($rs, 'RS_TS_VIEW', MAT_MMultiply($xzRMat,$vMat));

	## 映り込み部を描画
	print 'ObjectC1 描画中・・・・', "\n";
	RST_SetRenderState($rs,'RS_TS_WORLD', $objW1);
	GEO_DrawPrimitive($tSurface, $rs, $primType, $vertexBuff, $primOption);
	RST_SetRenderState($rs,'RS_TS_WORLD', $objW2);
	GEO_DrawPrimitive($tSurface, $rs, $primType, $vertexBuff, $primOption);

	## Zバッファをクリアし、アルファブレンディングを OFF にする。
	## また、VIEW行列を正常状態に戻す。
	RST_ClearZInTargetSurface($tSurface, 1.0);
	RST_SetRenderState($rs, 'RS_ALPHABLENDENABLE', 'FALSE');
	RST_SetRenderState($rs, 'RS_TS_VIEW', $vMat);

	## プリミティブの描画を行う。
	print 'ObjectC2 描画中・・・・', "\n";
	RST_SetRenderState($rs,'RS_TS_WORLD', $objW1);
	GEO_DrawPrimitive($tSurface, $rs, $primType, $vertexBuff, $primOption);
	RST_SetRenderState($rs,'RS_TS_WORLD', $objW2);
	GEO_DrawPrimitive($tSurface, $rs, $primType, $vertexBuff, $primOption);

}


##
## オブジェクトDを描画する。
##
sub drawObjectD {
	my ($tSurface, $rs) = @_;

	## マテリアルを設定する。
	RST_SetRenderState($rs, 'RS_MATERIAL', LIT_CreateMaterial(
				RST_ToColor(0xFF,0xFF,0xFF,0xFF), RST_ToColor(0x00,0x00,0x00,0x00),
						RST_ToColor(0x00,0x00,0x00,0), RST_ToColor(0x00,0x00,0x00,0), 0));
	## 面を作成する。
	my ($vertexBuff, $primType, $primOption ) =  MSH_CreatePlaneRect([20,20], 10, 10, [[1,1]]);
	## テクスチャの設定を行う。
	my $tex1 = TEX_CreateTextureFromFile('lit.bmp');
	RST_SetRenderState($rs,'RS_TS_TEXTURE', [$tex1]);
	RST_SetRenderState($rs,'RS_TSS_ADDRESSU', ['TADDRESS_CLAMP']);
	## ワールド行列を設定する。
	RST_SetRenderState($rs,'RS_TS_WORLD', MAT_MMultiply(
											MAT_MTranslate(-10,-10,0),
											MAT_MRotationX(MAT_DegToRad(40)),
											MAT_MTranslate(80,30,80)));
	## プリミティブの描画を行う。
	print 'ObjectC2 描画中・・・・', "\n";
	GEO_DrawPrimitive($tSurface, $rs, $primType, $vertexBuff, $primOption);

}

