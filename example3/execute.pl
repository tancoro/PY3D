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
	my $tSurface = RST_CreateTargetSurface(600,600, RST_ToColor(0x00,0x00,0x00,0x00));
	## ���˗p�̃T�[�t�F�[�X���쐬����B
	my $tSurface2 = RST_CreateTargetSurface(600,600, RST_ToColor(0x00,0x00,0x00,0x00));

	## �����_�����O�X�e�[�g�I�u�W�F�N�g���쐬����B
	my $rs = RST_CreateRenderState();
	## �r���[�s���ݒ肷��B
	RST_SetRenderState($rs, 'RS_TS_VIEW', MAT_MMultiply(
								MAT_MRotationX(MAT_DegToRad(-40)),
								MAT_MTranslate(0, 0, 150)));
	## �ˉe�s���ݒ肷��B
	RST_SetRenderState($rs, 'RS_TS_PROJECTION',
						MAT_MProjection(30, 2000, MAT_DegToRad(60), MAT_DegToRad(60)));

	## ���C�g��ݒ肷��B
	RST_SetRenderState($rs, 'RS_LIGHT', [
	  LIT_CreateDirectionalLight(RST_ToColor(0xC0,0xC0,0xC0),RST_ToColor(0xA0,0xA0,0xA0),RST_ToColor(0,0,0,0),[1, -3, 1]),
	  LIT_CreatePointLight(RST_ToColor(0xE0,0xE0,0xEF,0), RST_ToColor(0xD0,0xE0,0xF0,0), RST_ToColor(0,0,0,0), [ 80, 30, 80], [2, 0, 0]),
	  LIT_CreatePointLight(RST_ToColor(0xE0,0xE0,0xEF,0), RST_ToColor(0xD0,0xE0,0xF0,0), RST_ToColor(0,0,0,0), [-80, 30, 80], [2, 0, 0]),
	  LIT_CreatePointLight(RST_ToColor(0xE0,0xE0,0xEF,0), RST_ToColor(0xD0,0xE0,0xF0,0), RST_ToColor(0,0,0,0), [-80, 30,-80], [2, 0, 0]),
	  LIT_CreatePointLight(RST_ToColor(0xE0,0xE0,0xEF,0), RST_ToColor(0xD0,0xE0,0xF0,0), RST_ToColor(0,0,0,0), [ 80, 30,-80], [2, 0, 0])]);

	## XZ���ʂɑ΂��锽�]�s����쐬����B
	my $xzRMat = [[ 1.0, 0.0, 0.0, 0.0],
				  [ 0.0,-1.0, 0.0, 0.0],
				  [ 0.0, 0.0, 1.0, 0.0],
				  [ 0.0, 0.0, 0.0, 1.0]];
	##
	##�y�`�揇���z
	##
	## ���ʗp�T�[�t�F�X���擾����B
	## ���ʗp�T�[�t�F�X�̕`��̈�̃X�e���V���o�b�t�@�l��1�Ƃ���B
	## �N���b�s���O���s���̈���X�e���V���o�b�t�@�ɐݒ肷��B
	##
	##
	##
	##
	##

	## �I�u�W�F�N�g�̕`��
	## print 'ObjectB �쐬���E�E�E', "\n";
	## drawObjectB($tSurface, $rs);
	print 'ObjectA �쐬���E�E�E', "\n";
	drawObjectA($tSurface, $rs, $xzRMat);
	print 'ObjectC �쐬���E�E�E', "\n";
	drawObjectC($tSurface, $rs, $xzRMat);

	## BMP�t�@�C���ɏo�͂���B
	print '�t�@�C���o�͒��E�E�E�E', "\n";
	RST_PrintOutToBmp($tSurface, 'test'.$argPara.'.bmp');

}


##
## �I�u�W�F�N�gA ��`�悷��B
##
sub drawObjectA {
	my ($tSurface, $rs, $xzRMat) = @_;

	## �g�[���X���쐬���A�}�e���A����ݒ肷��B
	my ($vertexBuff, $primType, $primOption ) = 
	MSH_CreateTorus([[10,-10],[10,0],[10,10],[15, 12],[20,14],[25,12],
						 [30, 10],[30,0],[30,-10],[25,-12],[20,-14],[15,-12]],10, [[4,4]]);
	RST_SetRenderState($rs, 'RS_MATERIAL', LIT_CreateMaterial(
				RST_ToColor(0x80,0x80,0x80,0x40), RST_ToColor(0xA0,0xA0,0xA0,0),
						RST_ToColor(0x00,0x00,0x00,0), RST_ToColor(0x00,0x00,0x00,0), 30));

	## �e�N�X�`���̓ǂݍ��݂��s���B
	my $tex1 = TEX_CreateTextureFromFile('tex.bmp');
	RST_SetRenderState($rs,'RS_TS_TEXTURE', [$tex1]);
	RST_SetRenderState($rs,'RS_TSS_ADDRESSU', ['TADDRESS_WRAP']);


	## Z�o�b�t�@���N���A���A�A���t�@�u�����f�B���O�� ON �ɂ���B
	## �܂��AVIEW�s���XZ���ʂɑ΂��鋾�ʔ��ˍs���ݒ肷��B
	RST_ClearZInTargetSurface($tSurface, 1.0);
	RST_SetRenderState($rs, 'RS_ALPHABLENDENABLE', 'TRUE');
	my $vMat = RST_GetRenderState($rs, 'RS_TS_VIEW');
	RST_SetRenderState($rs, 'RS_TS_VIEW', MAT_MMultiply($xzRMat,$vMat));

	## �v���~�e�B�u�̕`����s���B
	print 'ObjectA1 �`�撆�E�E�E�E', "\n";
	RST_SetRenderState($rs,'RS_TS_WORLD', MAT_MMultiply(
											MAT_MTranslate(0, 14, 0),
											MAT_MRotationX(MAT_DegToRad(0))));
	GEO_DrawPrimitive($tSurface, $rs, $primType, $vertexBuff, $primOption);

	## Z�o�b�t�@���N���A���A�A���t�@�u�����f�B���O�� OFF �ɂ���B
	## �܂��AVIEW�s��𐳏��Ԃɖ߂��B
	RST_ClearZInTargetSurface($tSurface, 1.0);
	RST_SetRenderState($rs, 'RS_ALPHABLENDENABLE', 'FALSE');
	RST_SetRenderState($rs, 'RS_TS_VIEW', $vMat);

	## �v���~�e�B�u�̕`����s���B
	print 'ObjectA2 �`�撆�E�E�E�E', "\n";
	GEO_DrawPrimitive($tSurface, $rs, $primType, $vertexBuff, $primOption);

}


##
## �I�u�W�F�N�gB ��`�悷��B
##
sub drawObjectB {
	my ($tSurface, $rs) = @_;

	## �ʂ��쐬���A�}�e���A����ݒ肷��B
	my ($vertexBuff, $primType, $primOption ) =  MSH_CreatePlaneRect([200,200], 50, 50, [[4,4]]);
	RST_SetRenderState($rs, 'RS_MATERIAL', LIT_CreateMaterial(
				RST_ToColor(0x90,0x90,0x90,0xFF), RST_ToColor(0xD0,0xD0,0xD0,0),
						RST_ToColor(0x00,0x00,0x00,0), RST_ToColor(0x00,0x00,0x00,0), 100));

	## �e�N�X�`���̓ǂݍ��݂��s���B
	my $tex1 = TEX_CreateTextureFromFile('moku.bmp');
	RST_SetRenderState($rs,'RS_TS_TEXTURE', [$tex1]);
	RST_SetRenderState($rs,'RS_TSS_ADDRESSU', ['TADDRESS_WRAP']);
	## RST_SetRenderState($rs,'RS_TSS_ADDRESSU', ['TADDRESS_CLAMP']);
	## RST_SetRenderState($rs,'RS_TSS_ADDRESSU', ['TADDRESS_MIRROR']);

	## ����`��
	print '���`�撆�E�E�E�E', "\n";
	RST_SetRenderState($rs,'RS_TS_WORLD', MAT_MMultiply(
											MAT_MTranslate(-100, -100, 0),
											MAT_MRotationX(MAT_DegToRad(90))));
	GEO_DrawPrimitive($tSurface, $rs, $primType, $vertexBuff, $primOption);

}


##
## �I�u�W�F�N�gC��`�悷��B
##
sub drawObjectC {
	my ($tSurface, $rs, $xzRMat) = @_;

	## ��]�I�u�W�F�N�g���쐬���A�}�e���A����ݒ肷��B
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

	## Z�o�b�t�@���N���A���A�A���t�@�u�����f�B���O�� ON �ɂ���B
	## �܂��AVIEW�s���XZ���ʂɑ΂��鋾�ʔ��ˍs���ݒ肷��B
	RST_ClearZInTargetSurface($tSurface, 1.0);
	RST_SetRenderState($rs, 'RS_ALPHABLENDENABLE', 'TRUE');
	my $vMat = RST_GetRenderState($rs, 'RS_TS_VIEW');
	RST_SetRenderState($rs, 'RS_TS_VIEW', MAT_MMultiply($xzRMat,$vMat));

	## �f�荞�ݕ���`��
	print 'ObjectC1 �`�撆�E�E�E�E', "\n";
	RST_SetRenderState($rs,'RS_TS_WORLD', $objW1);
	GEO_DrawPrimitive($tSurface, $rs, $primType, $vertexBuff, $primOption);
	RST_SetRenderState($rs,'RS_TS_WORLD', $objW2);
	GEO_DrawPrimitive($tSurface, $rs, $primType, $vertexBuff, $primOption);

	## Z�o�b�t�@���N���A���A�A���t�@�u�����f�B���O�� OFF �ɂ���B
	## �܂��AVIEW�s��𐳏��Ԃɖ߂��B
	RST_ClearZInTargetSurface($tSurface, 1.0);
	RST_SetRenderState($rs, 'RS_ALPHABLENDENABLE', 'FALSE');
	RST_SetRenderState($rs, 'RS_TS_VIEW', $vMat);

	## �v���~�e�B�u�̕`����s���B
	print 'ObjectC2 �`�撆�E�E�E�E', "\n";
	RST_SetRenderState($rs,'RS_TS_WORLD', $objW1);
	GEO_DrawPrimitive($tSurface, $rs, $primType, $vertexBuff, $primOption);
	RST_SetRenderState($rs,'RS_TS_WORLD', $objW2);
	GEO_DrawPrimitive($tSurface, $rs, $primType, $vertexBuff, $primOption);

}


##
## �I�u�W�F�N�gD��`�悷��B
##
sub drawObjectD {
	my ($tSurface, $rs) = @_;

	## �}�e���A����ݒ肷��B
	RST_SetRenderState($rs, 'RS_MATERIAL', LIT_CreateMaterial(
				RST_ToColor(0xFF,0xFF,0xFF,0xFF), RST_ToColor(0x00,0x00,0x00,0x00),
						RST_ToColor(0x00,0x00,0x00,0), RST_ToColor(0x00,0x00,0x00,0), 0));
	## �ʂ��쐬����B
	my ($vertexBuff, $primType, $primOption ) =  MSH_CreatePlaneRect([20,20], 10, 10, [[1,1]]);
	## �e�N�X�`���̐ݒ���s���B
	my $tex1 = TEX_CreateTextureFromFile('lit.bmp');
	RST_SetRenderState($rs,'RS_TS_TEXTURE', [$tex1]);
	RST_SetRenderState($rs,'RS_TSS_ADDRESSU', ['TADDRESS_CLAMP']);
	## ���[���h�s���ݒ肷��B
	RST_SetRenderState($rs,'RS_TS_WORLD', MAT_MMultiply(
											MAT_MTranslate(-10,-10,0),
											MAT_MRotationX(MAT_DegToRad(40)),
											MAT_MTranslate(80,30,80)));
	## �v���~�e�B�u�̕`����s���B
	print 'ObjectC2 �`�撆�E�E�E�E', "\n";
	GEO_DrawPrimitive($tSurface, $rs, $primType, $vertexBuff, $primOption);

}

