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
	my $tSurface = RST_CreateTargetSurface(600,600, RST_ToColor(0,0,0,0));
	## レンダリングステートオブジェクトを作成する。
	my $rs = RST_CreateRenderState();
	## ビュー行列を設定する。
	RST_SetRenderState($rs, 'RS_TS_VIEW', MAT_MMultiply(
								MAT_MRotationX(MAT_DegToRad(-60)),
								MAT_MTranslate(0, 0, 180)));
	## 射影行列を設定する。
	RST_SetRenderState($rs, 'RS_TS_PROJECTION',
						MAT_MProjection(30, 1000, MAT_DegToRad(60), MAT_DegToRad(60)));
	## グローバルアンビエントを設定する。
	RST_SetRenderState($rs, 'RS_AMBIENT', RST_ToColor(0,0,0,0));

	## ライトを設定する。
	RST_SetRenderState($rs, 'RS_LIGHT', 
	[ LIT_CreateDirectionalLight(RST_ToColor(0xA0,0xA0,0xA0),RST_ToColor(0xA0,0xA0,0xA0),RST_ToColor(0,0,0,0),[1, -3, 0]),
	  LIT_CreatePointLight(RST_ToColor(0xC0,0xC0,0xC0,0), RST_ToColor(0xA0,0xA0,0xA0,0), RST_ToColor(0,0,0,0), [50, 50, 0], [1, 0, 0])]);
	## LIT_CreatePointLight(RST_ToColor(200,200,200,0), RST_ToColor(0,0,0,0), RST_ToColor(0,0,0,0), [-100,0, 0], [3, 0, 0]),
	## LIT_CreatePointLight(RST_ToColor(200,200,200,0), RST_ToColor(0,0,0,0), RST_ToColor(0,0,0,0), [0, 100, 0], [3, 0, 0]),
	## LIT_CreatePointLight(RST_ToColor(200,200,200,0), RST_ToColor(0,0,0,0), RST_ToColor(0,0,0,0), [0,-100, 0], [3, 0, 0])]);

	## Lineのカラーを設定する。
	RST_SetRenderState($rs, 'RS_LINE_COLOR', RST_ToColor(0xFF, 0xFF, 0xFF, 0xFF));

	## オブジェクトの描画
	print 'ObjectA 作成中・・・', "\n";
	drawObjectA($tSurface, $rs);
	## print 'ObjectB 作成中・・・', "\n";
	## drawObjectB($tSurface, $rs);
	## print 'ObjectC 作成中・・・', "\n";
	## drawObjectC($tSurface, $rs);

	## BMPファイルに出力する。
	print 'ファイル出力中・・・・', "\n";
	RST_PrintOutToBmp($tSurface, 'test'.$argPara.'.bmp');

}


##
## オブジェクトA を描画する。
##
sub drawObjectA {
	my ($tSurface, $rs) = @_;

	## マテリアルを設定する。
	RST_SetRenderState($rs, 'RS_MATERIAL', LIT_CreateMaterial(
				RST_ToColor(0xC0,0xC0,0xC0,0), RST_ToColor(0xDF,0xEF,0xFF,0),
						RST_ToColor(0x00,0x00,0x00,0), RST_ToColor(0x30,0x30,0x90,0), 30));

	## 面の色を設定する。
	RST_SetRenderState($rs, 'RS_LINE_COLOR', RST_ToColor(0x80, 0xFF, 0xFF, 0xFF));
	## 面を作成する。
	my ($vertexBuffP, $primTypeP, $primOptionP ) =  MSH_CreatePlaneRect([100,100], 50, 50);
	## ワールド行列を設定する。
	RST_SetRenderState($rs,'RS_TS_WORLD', MAT_MMultiply(
											MAT_MTranslate(-50, -50, 0),
											MAT_MRotationX(MAT_DegToRad(90))));
	## プリミティブの描画を行う。
	## print 'ObjectA 描画中・・・・', "\n";
	## GEO_DrawPrimitiveLine($tSurface, $rs, $primTypeP, $vertexBuffP, $primOptionP);


	## 頂点作成
	my @bezVer = ([[  0,0,0],[  0,  0,20],[  0,  0,40],[  0,  0,60],[  0,  0,80],[  0,  0,100]],
				  [[ 20,0,0],[ 20,100,20],[ 20,100,40],[ 20, 50,60],[ 20,  5,80],[ 20,  0,100]],
				  [[ 40,0,0],[ 40,120,20],[ 40,  5,40],[ 40, 5,60],[ 40, 10,80],[ 40,  0,100]],
				  [[ 60,0,0],[ 60, 30,20],[ 60,  5,40],[ 60, 5,60],[ 60,100,80],[ 60,  0,100]],
				  [[ 80,0,0],[ 80, 30,20],[ 80, 30,40],[ 80, 30,60],[ 80,100,80],[ 80,  0,100]],
				  [[100,0,0],[100,  0,20],[100,  0,40],[100,  0,60],[100,  0,80],[100,  0,100]]);

	## ベジェ曲面を作成する。
	my ($vertexBuff, $primType, $primOption ) = 
		MSH_CreateBezierPlane([@bezVer], 50, 50,[[2,2]]);

	## ワールド行列を設定する。
	RST_SetRenderState($rs,'RS_TS_WORLD', MAT_MMultiply(
											MAT_MTranslate(-50, 0, -50),
											MAT_MRotationY(MAT_DegToRad(0))));

	## テクスチャの設定を行う。
	my $tex1 = TEX_CreateTextureFromFile('tex.bmp');
	RST_SetRenderState($rs,'RS_TS_TEXTURE', [$tex1]);
	## RST_SetRenderState($rs,'RS_TSS_ADDRESSU', ['TADDRESS_CLAMP']);
	## RST_SetRenderState($rs,'RS_TSS_ADDRESSU', ['TADDRESS_MIRROR']);
	RST_SetRenderState($rs,'RS_TSS_ADDRESSU', ['TADDRESS_WRAP']);

	## プリミティブの描画を行う。
	print 'ObjectA 描画中・・・・', "\n";
	GEO_DrawPrimitiveLine($tSurface, $rs, $primType, $vertexBuff, $primOption);


	## 制御ネットを描画する。
	## Lineのカラーを設定する。
	RST_SetRenderState($rs, 'RS_LINE_COLOR', RST_ToColor(0xFF, 0xFF, 0x80, 0xFF));
	for my $bv (@bezVer) {
		## my $cv = $bv;
		my $cv = MSH_CreateBezierLine($bv,50);
		my $seigyoVrtBuff = VTX_CreateVertexBuffer();
		map { VTX_PushVertex( $seigyoVrtBuff, VTX_MakeUnlitVertex($_, [0, 0, 1])) } @$cv;
		GEO_DrawPrimitiveLine($tSurface, $rs, 'D3DPT_LINESTRIP', $seigyoVrtBuff, $#$seigyoVrtBuff);
	}

}

##
## オブジェクトB を描画する。
##
sub drawObjectB {
	my ($tSurface, $rs) = @_;

	## マテリアルを設定する。
	RST_SetRenderState($rs, 'RS_MATERIAL', LIT_CreateMaterial(
				RST_ToColor(0xC0,0xC0,0xC0,0), RST_ToColor(0xDF,0xEF,0xFF,0),
						RST_ToColor(0x00,0x00,0x00,0), RST_ToColor(0x30,0x30,0x90,0), 30));

	## 面を作成する。
	my ($vertexBuff, $primType, $primOption ) = 
		MSH_CreatePlaneRect([100,10], 50, 5, [[2,0.2]]);

	## テクスチャの設定を行う。
	my $tex1 = TEX_CreateTextureFromFile('tex.bmp');
	RST_SetRenderState($rs,'RS_TS_TEXTURE', [$tex1]);
	## RST_SetRenderState($rs,'RS_TSS_ADDRESSU', ['TADDRESS_CLAMP']);
	## RST_SetRenderState($rs,'RS_TSS_ADDRESSU', ['TADDRESS_MIRROR']);
	RST_SetRenderState($rs,'RS_TSS_ADDRESSU', ['TADDRESS_WRAP']);

	## ワールド行列を設定する。
	RST_SetRenderState($rs,'RS_TS_WORLD', MAT_MMultiply(
											MAT_MTranslate(-50, 0, 50),
											MAT_MRotationX(MAT_DegToRad(0))));
	## プリミティブの描画を行う。
	print 'ObjectB1 描画中・・・・', "\n";
	GEO_DrawPrimitive($tSurface, $rs, $primType, $vertexBuff, $primOption);

	## ワールド行列を設定する。
	RST_SetRenderState($rs,'RS_TS_WORLD', MAT_MMultiply(
											MAT_MTranslate(-50, 0, 0),
											MAT_MRotationY(MAT_DegToRad(-90)),
											MAT_MTranslate(-50,0,0)));
	## プリミティブの描画を行う。
	print 'ObjectB2 描画中・・・・', "\n";
	GEO_DrawPrimitive($tSurface, $rs, $primType, $vertexBuff, $primOption);

	## ワールド行列を設定する。
	RST_SetRenderState($rs,'RS_TS_WORLD', MAT_MMultiply(
											MAT_MTranslate(-50, 0, 0),
											MAT_MRotationY(MAT_DegToRad(90)),
											MAT_MTranslate(50,0,0)));

	## プリミティブの描画を行う。
	print 'ObjectB3 描画中・・・・', "\n";
	GEO_DrawPrimitive($tSurface, $rs, $primType, $vertexBuff, $primOption);
}


##
## オブジェクトC を描画する。
##
sub drawObjectC {
	my ($tSurface, $rs) = @_;

	## マテリアルを設定する。
	RST_SetRenderState($rs, 'RS_MATERIAL', LIT_CreateMaterial(
				RST_ToColor(0xC0,0xC0,0xC0,0), RST_ToColor(0x70,0x70,0x70,0),
						RST_ToColor(0x00,0x00,0x00,0), RST_ToColor(0x30,0x30,0x90,0), 50));

	## 面を作成する。
	my ($vertexBuff, $primType, $primOption ) = 
		MSH_CreatePlaneRect([100,100], 50, 50, [[2,2]]);

	## テクスチャの設定を行う。
	my $tex1 = TEX_CreateTextureFromFile('tex.bmp');
	RST_SetRenderState($rs,'RS_TS_TEXTURE', [$tex1]);
	## RST_SetRenderState($rs,'RS_TSS_ADDRESSU', ['TADDRESS_CLAMP']);
	## RST_SetRenderState($rs,'RS_TSS_ADDRESSU', ['TADDRESS_MIRROR']);
	RST_SetRenderState($rs,'RS_TSS_ADDRESSU', ['TADDRESS_WRAP']);

	## ワールド行列を設定する。
	RST_SetRenderState($rs,'RS_TS_WORLD', MAT_MMultiply(
											MAT_MTranslate(-50,-50, 0),
											MAT_MRotationX(MAT_DegToRad(90)),
											MAT_MTranslate(0, 10, -100)));
	## プリミティブの描画を行う。
	print 'ObjectC1 描画中・・・・', "\n";
	GEO_DrawPrimitive($tSurface, $rs, $primType, $vertexBuff, $primOption);

	## ワールド行列を設定する。
	RST_SetRenderState($rs,'RS_TS_WORLD', MAT_MMultiply(
											MAT_MTranslate(-50,-50, 0),
											MAT_MRotationX(MAT_DegToRad(90)),
											MAT_MTranslate(100, 10, 0)));
	## プリミティブの描画を行う。
	print 'ObjectC2 描画中・・・・', "\n";
	GEO_DrawPrimitive($tSurface, $rs, $primType, $vertexBuff, $primOption);

	## ワールド行列を設定する。
	RST_SetRenderState($rs,'RS_TS_WORLD', MAT_MMultiply(
											MAT_MTranslate(-50,-50, 0),
											MAT_MRotationX(MAT_DegToRad(90)),
											MAT_MTranslate(-100, 10, 0)));
	## プリミティブの描画を行う。
	print 'ObjectC3 描画中・・・・', "\n";
	GEO_DrawPrimitive($tSurface, $rs, $primType, $vertexBuff, $primOption);

	## ワールド行列を設定する。
	RST_SetRenderState($rs,'RS_TS_WORLD', MAT_MMultiply(
											MAT_MTranslate(-50,-50, 0),
											MAT_MRotationX(MAT_DegToRad(90)),
											MAT_MTranslate(100, 10, -100)));
	## プリミティブの描画を行う。
	print 'ObjectC4 描画中・・・・', "\n";
	GEO_DrawPrimitive($tSurface, $rs, $primType, $vertexBuff, $primOption);

	## ワールド行列を設定する。
	RST_SetRenderState($rs,'RS_TS_WORLD', MAT_MMultiply(
											MAT_MTranslate(-50,-50, 0),
											MAT_MRotationX(MAT_DegToRad(90)),
											MAT_MTranslate(-100, 10, -100)));
	## プリミティブの描画を行う。
	print 'ObjectC5 描画中・・・・', "\n";
	GEO_DrawPrimitive($tSurface, $rs, $primType, $vertexBuff, $primOption);

	## ワールド行列を設定する。
	RST_SetRenderState($rs,'RS_TS_WORLD', MAT_MMultiply(
											MAT_MTranslate(-50,-50, 0),
											MAT_MRotationX(MAT_DegToRad(90)),
											MAT_MTranslate(0, 10, 100)));
	## プリミティブの描画を行う。
	print 'ObjectC6 描画中・・・・', "\n";
	GEO_DrawPrimitive($tSurface, $rs, $primType, $vertexBuff, $primOption);

	## ワールド行列を設定する。
	RST_SetRenderState($rs,'RS_TS_WORLD', MAT_MMultiply(
											MAT_MTranslate(-50,-50, 0),
											MAT_MRotationX(MAT_DegToRad(90)),
											MAT_MTranslate(100, 10, 100)));
	## プリミティブの描画を行う。
	print 'ObjectC7 描画中・・・・', "\n";
	GEO_DrawPrimitive($tSurface, $rs, $primType, $vertexBuff, $primOption);

	## ワールド行列を設定する。
	RST_SetRenderState($rs,'RS_TS_WORLD', MAT_MMultiply(
											MAT_MTranslate(-50,-50, 0),
											MAT_MRotationX(MAT_DegToRad(90)),
											MAT_MTranslate(-100, 10, 100)));
	## プリミティブの描画を行う。
	print 'ObjectC8 描画中・・・・', "\n";
	GEO_DrawPrimitive($tSurface, $rs, $primType, $vertexBuff, $primOption);

}


##
## オブジェクトDを描画する。
##
sub drawObjectD {
	my ($tSurface, $rs) = @_;

	## マテリアルを設定する。
	RST_SetRenderState($rs, 'RS_MATERIAL', LIT_CreateMaterial(
				RST_ToColor(0xFF,0xFF,0xFF,0), RST_ToColor(0xFF,0xFF,0xFF,0),
						RST_ToColor(0x00,0x00,0x00,0), RST_ToColor(0x60,0x20,0x20,0), 100));

	## トーラスを作成する。
	my ($vertexBuff, $primType, $primOption) = 
	MSH_CreateTorus([[20,0],[25, 12],[30, 20],[35, 12],[40,0],
						[35,-12],[30,-20],[25,-12]], 20, [[3,3]]);

	## ワールド行列を設定する。
	RST_SetRenderState($rs,'RS_TS_WORLD', MAT_MMultiply(
											MAT_MScaling(0.3,0.3,0.3),
											MAT_MTranslate(0, 50, 0),
											MAT_MRotationX(MAT_DegToRad(-60)) ));

	## テクスチャの設定を行う。
	my $tex1 = TEX_CreateTextureFromFile('mon.bmp');
	RST_SetRenderState($rs,'RS_TS_TEXTURE', [$tex1]);
	## RST_SetRenderState($rs,'RS_TSS_ADDRESSU', ['TADDRESS_CLAMP']);
	## RST_SetRenderState($rs,'RS_TSS_ADDRESSU', ['TADDRESS_MIRROR']);
	RST_SetRenderState($rs,'RS_TSS_ADDRESSU', ['TADDRESS_WRAP']);

	## プリミティブの描画を行う。
	print 'ObjectC 描画中・・・・', "\n";
	GEO_DrawPrimitive($tSurface, $rs, $primType, $vertexBuff, $primOption);

}

