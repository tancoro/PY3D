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

	## �����_�����O�^�[�Q�b�g�T�[�t�F�X���쐬����B
	my $tSurface = RST_CreateTargetSurface(600,600, RST_ToColor(0,0,0,0));
	## �����_�����O�X�e�[�g�I�u�W�F�N�g���쐬����B
	my $rs = RST_CreateRenderState();
	## �r���[�s���ݒ肷��B
	RST_SetRenderState($rs, 'RS_TS_VIEW', MAT_MMultiply(
								MAT_MRotationX(MAT_DegToRad(-60)),
								MAT_MTranslate(0, 0, 180)));
	## �ˉe�s���ݒ肷��B
	RST_SetRenderState($rs, 'RS_TS_PROJECTION',
						MAT_MProjection(30, 1000, MAT_DegToRad(60), MAT_DegToRad(60)));
	## �O���[�o���A���r�G���g��ݒ肷��B
	RST_SetRenderState($rs, 'RS_AMBIENT', RST_ToColor(0,0,0,0));

	## ���C�g��ݒ肷��B
	RST_SetRenderState($rs, 'RS_LIGHT', 
	[ LIT_CreateDirectionalLight(RST_ToColor(0xA0,0xA0,0xA0),RST_ToColor(0xA0,0xA0,0xA0),RST_ToColor(0,0,0,0),[1, -3, 0]),
	  LIT_CreatePointLight(RST_ToColor(0xC0,0xC0,0xC0,0), RST_ToColor(0xA0,0xA0,0xA0,0), RST_ToColor(0,0,0,0), [50, 50, 0], [1, 0, 0])]);
	## LIT_CreatePointLight(RST_ToColor(200,200,200,0), RST_ToColor(0,0,0,0), RST_ToColor(0,0,0,0), [-100,0, 0], [3, 0, 0]),
	## LIT_CreatePointLight(RST_ToColor(200,200,200,0), RST_ToColor(0,0,0,0), RST_ToColor(0,0,0,0), [0, 100, 0], [3, 0, 0]),
	## LIT_CreatePointLight(RST_ToColor(200,200,200,0), RST_ToColor(0,0,0,0), RST_ToColor(0,0,0,0), [0,-100, 0], [3, 0, 0])]);

	## Line�̃J���[��ݒ肷��B
	RST_SetRenderState($rs, 'RS_LINE_COLOR', RST_ToColor(0xFF, 0xFF, 0xFF, 0xFF));

	## �I�u�W�F�N�g�̕`��
	print 'ObjectA �쐬���E�E�E', "\n";
	drawObjectA($tSurface, $rs);
	## print 'ObjectB �쐬���E�E�E', "\n";
	## drawObjectB($tSurface, $rs);
	## print 'ObjectC �쐬���E�E�E', "\n";
	## drawObjectC($tSurface, $rs);

	## BMP�t�@�C���ɏo�͂���B
	print '�t�@�C���o�͒��E�E�E�E', "\n";
	RST_PrintOutToBmp($tSurface, 'test'.$argPara.'.bmp');

}


##
## �I�u�W�F�N�gA ��`�悷��B
##
sub drawObjectA {
	my ($tSurface, $rs) = @_;

	## �}�e���A����ݒ肷��B
	RST_SetRenderState($rs, 'RS_MATERIAL', LIT_CreateMaterial(
				RST_ToColor(0xC0,0xC0,0xC0,0), RST_ToColor(0xDF,0xEF,0xFF,0),
						RST_ToColor(0x00,0x00,0x00,0), RST_ToColor(0x30,0x30,0x90,0), 30));

	## �ʂ̐F��ݒ肷��B
	RST_SetRenderState($rs, 'RS_LINE_COLOR', RST_ToColor(0x80, 0xFF, 0xFF, 0xFF));
	## �ʂ��쐬����B
	my ($vertexBuffP, $primTypeP, $primOptionP ) =  MSH_CreatePlaneRect([100,100], 50, 50);
	## ���[���h�s���ݒ肷��B
	RST_SetRenderState($rs,'RS_TS_WORLD', MAT_MMultiply(
											MAT_MTranslate(-50, -50, 0),
											MAT_MRotationX(MAT_DegToRad(90))));
	## �v���~�e�B�u�̕`����s���B
	## print 'ObjectA �`�撆�E�E�E�E', "\n";
	## GEO_DrawPrimitiveLine($tSurface, $rs, $primTypeP, $vertexBuffP, $primOptionP);


	## ���_�쐬
	my @bezVer = ([[  0,0,0],[  0,  0,20],[  0,  0,40],[  0,  0,60],[  0,  0,80],[  0,  0,100]],
				  [[ 20,0,0],[ 20,100,20],[ 20,100,40],[ 20, 50,60],[ 20,  5,80],[ 20,  0,100]],
				  [[ 40,0,0],[ 40,120,20],[ 40,  5,40],[ 40, 5,60],[ 40, 10,80],[ 40,  0,100]],
				  [[ 60,0,0],[ 60, 30,20],[ 60,  5,40],[ 60, 5,60],[ 60,100,80],[ 60,  0,100]],
				  [[ 80,0,0],[ 80, 30,20],[ 80, 30,40],[ 80, 30,60],[ 80,100,80],[ 80,  0,100]],
				  [[100,0,0],[100,  0,20],[100,  0,40],[100,  0,60],[100,  0,80],[100,  0,100]]);

	## �x�W�F�Ȗʂ��쐬����B
	my ($vertexBuff, $primType, $primOption ) = 
		MSH_CreateBezierPlane([@bezVer], 50, 50,[[2,2]]);

	## ���[���h�s���ݒ肷��B
	RST_SetRenderState($rs,'RS_TS_WORLD', MAT_MMultiply(
											MAT_MTranslate(-50, 0, -50),
											MAT_MRotationY(MAT_DegToRad(0))));

	## �e�N�X�`���̐ݒ���s���B
	my $tex1 = TEX_CreateTextureFromFile('tex.bmp');
	RST_SetRenderState($rs,'RS_TS_TEXTURE', [$tex1]);
	## RST_SetRenderState($rs,'RS_TSS_ADDRESSU', ['TADDRESS_CLAMP']);
	## RST_SetRenderState($rs,'RS_TSS_ADDRESSU', ['TADDRESS_MIRROR']);
	RST_SetRenderState($rs,'RS_TSS_ADDRESSU', ['TADDRESS_WRAP']);

	## �v���~�e�B�u�̕`����s���B
	print 'ObjectA �`�撆�E�E�E�E', "\n";
	GEO_DrawPrimitiveLine($tSurface, $rs, $primType, $vertexBuff, $primOption);


	## ����l�b�g��`�悷��B
	## Line�̃J���[��ݒ肷��B
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
## �I�u�W�F�N�gB ��`�悷��B
##
sub drawObjectB {
	my ($tSurface, $rs) = @_;

	## �}�e���A����ݒ肷��B
	RST_SetRenderState($rs, 'RS_MATERIAL', LIT_CreateMaterial(
				RST_ToColor(0xC0,0xC0,0xC0,0), RST_ToColor(0xDF,0xEF,0xFF,0),
						RST_ToColor(0x00,0x00,0x00,0), RST_ToColor(0x30,0x30,0x90,0), 30));

	## �ʂ��쐬����B
	my ($vertexBuff, $primType, $primOption ) = 
		MSH_CreatePlaneRect([100,10], 50, 5, [[2,0.2]]);

	## �e�N�X�`���̐ݒ���s���B
	my $tex1 = TEX_CreateTextureFromFile('tex.bmp');
	RST_SetRenderState($rs,'RS_TS_TEXTURE', [$tex1]);
	## RST_SetRenderState($rs,'RS_TSS_ADDRESSU', ['TADDRESS_CLAMP']);
	## RST_SetRenderState($rs,'RS_TSS_ADDRESSU', ['TADDRESS_MIRROR']);
	RST_SetRenderState($rs,'RS_TSS_ADDRESSU', ['TADDRESS_WRAP']);

	## ���[���h�s���ݒ肷��B
	RST_SetRenderState($rs,'RS_TS_WORLD', MAT_MMultiply(
											MAT_MTranslate(-50, 0, 50),
											MAT_MRotationX(MAT_DegToRad(0))));
	## �v���~�e�B�u�̕`����s���B
	print 'ObjectB1 �`�撆�E�E�E�E', "\n";
	GEO_DrawPrimitive($tSurface, $rs, $primType, $vertexBuff, $primOption);

	## ���[���h�s���ݒ肷��B
	RST_SetRenderState($rs,'RS_TS_WORLD', MAT_MMultiply(
											MAT_MTranslate(-50, 0, 0),
											MAT_MRotationY(MAT_DegToRad(-90)),
											MAT_MTranslate(-50,0,0)));
	## �v���~�e�B�u�̕`����s���B
	print 'ObjectB2 �`�撆�E�E�E�E', "\n";
	GEO_DrawPrimitive($tSurface, $rs, $primType, $vertexBuff, $primOption);

	## ���[���h�s���ݒ肷��B
	RST_SetRenderState($rs,'RS_TS_WORLD', MAT_MMultiply(
											MAT_MTranslate(-50, 0, 0),
											MAT_MRotationY(MAT_DegToRad(90)),
											MAT_MTranslate(50,0,0)));

	## �v���~�e�B�u�̕`����s���B
	print 'ObjectB3 �`�撆�E�E�E�E', "\n";
	GEO_DrawPrimitive($tSurface, $rs, $primType, $vertexBuff, $primOption);
}


##
## �I�u�W�F�N�gC ��`�悷��B
##
sub drawObjectC {
	my ($tSurface, $rs) = @_;

	## �}�e���A����ݒ肷��B
	RST_SetRenderState($rs, 'RS_MATERIAL', LIT_CreateMaterial(
				RST_ToColor(0xC0,0xC0,0xC0,0), RST_ToColor(0x70,0x70,0x70,0),
						RST_ToColor(0x00,0x00,0x00,0), RST_ToColor(0x30,0x30,0x90,0), 50));

	## �ʂ��쐬����B
	my ($vertexBuff, $primType, $primOption ) = 
		MSH_CreatePlaneRect([100,100], 50, 50, [[2,2]]);

	## �e�N�X�`���̐ݒ���s���B
	my $tex1 = TEX_CreateTextureFromFile('tex.bmp');
	RST_SetRenderState($rs,'RS_TS_TEXTURE', [$tex1]);
	## RST_SetRenderState($rs,'RS_TSS_ADDRESSU', ['TADDRESS_CLAMP']);
	## RST_SetRenderState($rs,'RS_TSS_ADDRESSU', ['TADDRESS_MIRROR']);
	RST_SetRenderState($rs,'RS_TSS_ADDRESSU', ['TADDRESS_WRAP']);

	## ���[���h�s���ݒ肷��B
	RST_SetRenderState($rs,'RS_TS_WORLD', MAT_MMultiply(
											MAT_MTranslate(-50,-50, 0),
											MAT_MRotationX(MAT_DegToRad(90)),
											MAT_MTranslate(0, 10, -100)));
	## �v���~�e�B�u�̕`����s���B
	print 'ObjectC1 �`�撆�E�E�E�E', "\n";
	GEO_DrawPrimitive($tSurface, $rs, $primType, $vertexBuff, $primOption);

	## ���[���h�s���ݒ肷��B
	RST_SetRenderState($rs,'RS_TS_WORLD', MAT_MMultiply(
											MAT_MTranslate(-50,-50, 0),
											MAT_MRotationX(MAT_DegToRad(90)),
											MAT_MTranslate(100, 10, 0)));
	## �v���~�e�B�u�̕`����s���B
	print 'ObjectC2 �`�撆�E�E�E�E', "\n";
	GEO_DrawPrimitive($tSurface, $rs, $primType, $vertexBuff, $primOption);

	## ���[���h�s���ݒ肷��B
	RST_SetRenderState($rs,'RS_TS_WORLD', MAT_MMultiply(
											MAT_MTranslate(-50,-50, 0),
											MAT_MRotationX(MAT_DegToRad(90)),
											MAT_MTranslate(-100, 10, 0)));
	## �v���~�e�B�u�̕`����s���B
	print 'ObjectC3 �`�撆�E�E�E�E', "\n";
	GEO_DrawPrimitive($tSurface, $rs, $primType, $vertexBuff, $primOption);

	## ���[���h�s���ݒ肷��B
	RST_SetRenderState($rs,'RS_TS_WORLD', MAT_MMultiply(
											MAT_MTranslate(-50,-50, 0),
											MAT_MRotationX(MAT_DegToRad(90)),
											MAT_MTranslate(100, 10, -100)));
	## �v���~�e�B�u�̕`����s���B
	print 'ObjectC4 �`�撆�E�E�E�E', "\n";
	GEO_DrawPrimitive($tSurface, $rs, $primType, $vertexBuff, $primOption);

	## ���[���h�s���ݒ肷��B
	RST_SetRenderState($rs,'RS_TS_WORLD', MAT_MMultiply(
											MAT_MTranslate(-50,-50, 0),
											MAT_MRotationX(MAT_DegToRad(90)),
											MAT_MTranslate(-100, 10, -100)));
	## �v���~�e�B�u�̕`����s���B
	print 'ObjectC5 �`�撆�E�E�E�E', "\n";
	GEO_DrawPrimitive($tSurface, $rs, $primType, $vertexBuff, $primOption);

	## ���[���h�s���ݒ肷��B
	RST_SetRenderState($rs,'RS_TS_WORLD', MAT_MMultiply(
											MAT_MTranslate(-50,-50, 0),
											MAT_MRotationX(MAT_DegToRad(90)),
											MAT_MTranslate(0, 10, 100)));
	## �v���~�e�B�u�̕`����s���B
	print 'ObjectC6 �`�撆�E�E�E�E', "\n";
	GEO_DrawPrimitive($tSurface, $rs, $primType, $vertexBuff, $primOption);

	## ���[���h�s���ݒ肷��B
	RST_SetRenderState($rs,'RS_TS_WORLD', MAT_MMultiply(
											MAT_MTranslate(-50,-50, 0),
											MAT_MRotationX(MAT_DegToRad(90)),
											MAT_MTranslate(100, 10, 100)));
	## �v���~�e�B�u�̕`����s���B
	print 'ObjectC7 �`�撆�E�E�E�E', "\n";
	GEO_DrawPrimitive($tSurface, $rs, $primType, $vertexBuff, $primOption);

	## ���[���h�s���ݒ肷��B
	RST_SetRenderState($rs,'RS_TS_WORLD', MAT_MMultiply(
											MAT_MTranslate(-50,-50, 0),
											MAT_MRotationX(MAT_DegToRad(90)),
											MAT_MTranslate(-100, 10, 100)));
	## �v���~�e�B�u�̕`����s���B
	print 'ObjectC8 �`�撆�E�E�E�E', "\n";
	GEO_DrawPrimitive($tSurface, $rs, $primType, $vertexBuff, $primOption);

}


##
## �I�u�W�F�N�gD��`�悷��B
##
sub drawObjectD {
	my ($tSurface, $rs) = @_;

	## �}�e���A����ݒ肷��B
	RST_SetRenderState($rs, 'RS_MATERIAL', LIT_CreateMaterial(
				RST_ToColor(0xFF,0xFF,0xFF,0), RST_ToColor(0xFF,0xFF,0xFF,0),
						RST_ToColor(0x00,0x00,0x00,0), RST_ToColor(0x60,0x20,0x20,0), 100));

	## �g�[���X���쐬����B
	my ($vertexBuff, $primType, $primOption) = 
	MSH_CreateTorus([[20,0],[25, 12],[30, 20],[35, 12],[40,0],
						[35,-12],[30,-20],[25,-12]], 20, [[3,3]]);

	## ���[���h�s���ݒ肷��B
	RST_SetRenderState($rs,'RS_TS_WORLD', MAT_MMultiply(
											MAT_MScaling(0.3,0.3,0.3),
											MAT_MTranslate(0, 50, 0),
											MAT_MRotationX(MAT_DegToRad(-60)) ));

	## �e�N�X�`���̐ݒ���s���B
	my $tex1 = TEX_CreateTextureFromFile('mon.bmp');
	RST_SetRenderState($rs,'RS_TS_TEXTURE', [$tex1]);
	## RST_SetRenderState($rs,'RS_TSS_ADDRESSU', ['TADDRESS_CLAMP']);
	## RST_SetRenderState($rs,'RS_TSS_ADDRESSU', ['TADDRESS_MIRROR']);
	RST_SetRenderState($rs,'RS_TSS_ADDRESSU', ['TADDRESS_WRAP']);

	## �v���~�e�B�u�̕`����s���B
	print 'ObjectC �`�撆�E�E�E�E', "\n";
	GEO_DrawPrimitive($tSurface, $rs, $primType, $vertexBuff, $primOption);

}

