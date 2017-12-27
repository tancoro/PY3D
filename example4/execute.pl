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
	my $tSurface = RST_CreateTargetSurface(400,400, RST_ToColor(0,0,0,0));

	## レンダリングステートオブジェクトを作成する。
	my $rs = RST_CreateRenderState();

	## ビュー行列を設定する。
	RST_SetRenderState($rs, 'RS_TS_VIEW', MAT_MMultiply( MAT_MTranslate(0, 0, 120)));

	## 射影行列を設定する。
	RST_SetRenderState($rs, 'RS_TS_PROJECTION',
						MAT_MProjection(30, 300, MAT_DegToRad(60), MAT_DegToRad(60)));

	## グローバルアンビエントを設定する。
	RST_SetRenderState($rs, 'RS_AMBIENT', RST_ToColor(0,0,0,0));

	## ライトの設定を行なう。
	RST_SetRenderState($rs, 'RS_LIGHT', [ LIT_CreatePointLight(RST_ToColor(0xE0,0xA0,0xFF,0), RST_ToColor(0xEA,0xEA,0xFA,0), RST_ToColor(0,0,0,0), [0, 0, -30], [1, 0, 0])] );

	## マテリアルを設定する。
	RST_SetRenderState($rs, 'RS_MATERIAL', LIT_CreateMaterial(
				RST_ToColor(0xE0,0xFF,0xC0,0), RST_ToColor(0xDF,0xEF,0xFF,0),
						RST_ToColor(0x00,0x00,0x00,0), RST_ToColor(0x00,0x00,0x00,0), 50));

	## ワールド行列を設定する。
	RST_SetRenderState($rs,'RS_TS_WORLD', MAT_MMultiply( MAT_MTranslate(-50, -50, 0)));

	## 元になる三角形を取得する。
	print '基プリミティブ取得中・・・', "\n";
	my ($num, $primType, $vertexBuff, $primOption ) = (0, 'D3DPT_TRIANGLELIST', getObjctSource(), 1);
	print '基プリミティブ描画中・・・', "\n";
	GEO_DrawPrimitiveLine($tSurface, $rs, $primType, $vertexBuff, $primOption);
	print '基プリミティブBMP出力中・・・', "\n";
	RST_PrintOutToBmp($tSurface, 'kunk'. $num . '.bmp');
	print 'サーフェスクリア中・・・', "\n";
	RST_ClearTargetSurface($tSurface, RST_ToColor(0,0,0,0));

	for($num = 1; $num < 8 ; $num++) {
		
		print '/_/_/_/_/_/_/_/_/_/_/_/_/ num [' . $num . '] /_/_/_/_/_/_/_/_/_/_/_/_/', "\n";
		## 細分化
		print 'ObjectA 細分化・・・', "\n";
		if ($num >= 7) {
			($vertexBuff, $primType, $primOption ) = MSH_CreateMountainsLast($vertexBuff);
		} else {
			($vertexBuff, $primType, $primOption ) = MSH_CreateMountains($vertexBuff);
		}

		## オブジェクトの描画
		print 'ObjectA Line 描画中・・・', "\n";
		GEO_DrawPrimitiveLine($tSurface, $rs, $primType, $vertexBuff, $primOption);

		## BMPファイルに出力
		print 'ファイル出力中・・・・', "\n";
		RST_PrintOutToBmp($tSurface, 'kunk'. $num . '.bmp');

		## サーフェスをクリア
		print 'ターゲットサーフェスクリア中・・・' , "\n";
		RST_ClearTargetSurface($tSurface, RST_ToColor(0,0,0,0));
		print '/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/', "\n";

	}

	print '/_/_/_/_/_/_/_/_/_/_/_/_/ num [' . $num . '] /_/_/_/_/_/_/_/_/_/_/_/_/', "\n";
	## オブジェクトの描画
	print 'ObjectA 描画中・・・', "\n";
	GEO_DrawPrimitive($tSurface, $rs, $primType, $vertexBuff, $primOption);
	## BMPファイルに出力
	print '最終ファイル出力中・・・・', "\n";
	RST_PrintOutToBmp($tSurface, 'kunk'. $num . '.bmp');
	print '/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/', "\n";


}


## 初期頂点を作成する。
sub getObjctSource {
	my $vertexBuff = VTX_CreateVertexBuffer();
	VTX_PushVertex( $vertexBuff, VTX_MakeUnlitVertex([0,0,0], [0,0,0]));
	VTX_PushVertex( $vertexBuff, VTX_MakeUnlitVertex([100,0,0], [0,0,0]));
	VTX_PushVertex( $vertexBuff, VTX_MakeUnlitVertex([50,100,0], [0,0,0]));
	return $vertexBuff;
}

1;
