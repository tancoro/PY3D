use strict;
require '..\PY3D\renderState3D.pl';
require '..\PY3D\geometry3D.pl';
require '..\PY3D\vertex3D.pl';
require '..\PY3D\vector3D.pl';
require '..\PY3D\matrix3D.pl';
require '..\PY3D\light3D.pl';
require '..\PY3D\pixel3D.pl';
require '..\PY3D\mesh3D.pl';
require '..\PY3D\texture3D.pl';

main();


sub main {
	my $argPara = $ARGV[0];

	## レンダリングターゲットサーフェスを作成する。
	print 'サーフェス初期化中・・・・', "\n";
	my $tSurface = RST_CreateTargetSurface(200, 200, RST_ToColor(0x00,0x00,0x00,0x00));

	## レンダリングステートオブジェクトを作成する。
	my $rs = RST_CreateRenderState();

	## ビュー行列を設定する。
	RST_SetRenderState($rs, 'RS_TS_VIEW', MAT_MTranslate(0, 0, 150));

	## 射影行列を設定する。
	RST_SetRenderState($rs, 'RS_TS_PROJECTION',
						MAT_MProjection(20, 400, MAT_DegToRad(60), MAT_DegToRad(60)));

	## グローバルアンビエントを設定する。
	RST_SetRenderState($rs, 'RS_AMBIENT', RST_ToColor(0,0,0,0));

	## ライトを設定する。
	RST_SetRenderState($rs, 'RS_LIGHT', 
		[ LIT_CreatePointLight(RST_ToColor(0x90,0x90,0x90,0), RST_ToColor(0xD0,0xE0,0xF0,0), RST_ToColor(0,0,0,0), [0, 0,-40], [1, 0, 0]),
		  LIT_CreatePointLight(RST_ToColor(0xCD,0xDD,0xFF,0), RST_ToColor(0xFF,0xFF,0xFF,0), RST_ToColor(0,0,0,0), [-100,-100,-20], [1, 0, 0]),
		  LIT_CreatePointLight(RST_ToColor(0xCD,0xDD,0xFF,0), RST_ToColor(0xFF,0xFF,0xFF,0), RST_ToColor(0,0,0,0), [ 100, 100,-20], [1, 0, 0])]);

	## マテリアルを設定する。
	RST_SetRenderState($rs, 'RS_MATERIAL', LIT_CreateMaterial(
				RST_ToColor(0xFF,0xFF,0xFF,0), RST_ToColor(0xC0,0xD0,0xE0,0),
						RST_ToColor(0,0,0,0), RST_ToColor(0,0,0,0), 10));

	## 開始オブジェクトを作成する。
	my ($vertexBuff1, $primType1, $primOpt1) = 
		MSH_CreateTorus([[20,0],[25, 12],[30, 20],[35, 12],[40,0],
								[35,-12],[30,-20],[25,-12]], 10);

	## 終了オブジェクトを作成する。
	my ($vertexBuff2, $primType2, $primOpt2) = 
		MSH_CreateTorus([[5,0],[17, 2],[30, 30],[43, 2],[55,0],
								[43,-2],[30,-30],[17,-2]], 10);

	## トゥイーニングを行う。
	my $vertexBuff = MSH_CreateTweening($vertexBuff1, $vertexBuff2, 12, $argPara - 32);

	## ワールド行列を設定する。
	RST_SetRenderState($rs,'RS_TS_WORLD', MAT_MRotationX(MAT_DegToRad(4*$argPara)));

	## テクスチャの設定を行う。
	## my $tttt1 = TEX_CreateTextureFromFile('aaa2.bmp');
	## my $tttt2 = TEX_CreateTextureFromFile('tex7.bmp');
	## RST_SetRenderState($rs,'RS_TS_TEXTURE', [$tttt1,$tttt2]);
	## RST_SetRenderState($rs,'RS_TSS_ADDRESSU', ['TADDRESS_MIRROR','TADDRESS_MIRROR']);

	## プリミティブの描画を行う。
	print 'サーフェス描画中・・・・', "\n";
	GEO_DrawPrimitive($tSurface, $rs, $primType1, $vertexBuff, $primOpt1);

	print 'ファイル出力中・・・・', "\n";
	## BMPファイルに出力する。
	RST_PrintOutToBmp($tSurface, 'test'.$argPara.'.bmp');

}

