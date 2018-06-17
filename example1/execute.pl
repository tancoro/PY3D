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

	## �����_�����O�^�[�Q�b�g�T�[�t�F�X���쐬����B
	print '�T�[�t�F�X���������E�E�E�E', "\n";
	my $tSurface = RST_CreateTargetSurface(200, 200, RST_ToColor(0x00,0x00,0x00,0x00));

	## �����_�����O�X�e�[�g�I�u�W�F�N�g���쐬����B
	my $rs = RST_CreateRenderState();

	## �r���[�s���ݒ肷��B
	RST_SetRenderState($rs, 'RS_TS_VIEW', MAT_MTranslate(0, 0, 150));

	## �ˉe�s���ݒ肷��B
	RST_SetRenderState($rs, 'RS_TS_PROJECTION',
						MAT_MProjection(20, 400, MAT_DegToRad(60), MAT_DegToRad(60)));

	## �O���[�o���A���r�G���g��ݒ肷��B
	RST_SetRenderState($rs, 'RS_AMBIENT', RST_ToColor(0,0,0,0));

	## ���C�g��ݒ肷��B
	RST_SetRenderState($rs, 'RS_LIGHT', 
		[ LIT_CreatePointLight(RST_ToColor(0x90,0x90,0x90,0), RST_ToColor(0xD0,0xE0,0xF0,0), RST_ToColor(0,0,0,0), [0, 0,-40], [1, 0, 0]),
		  LIT_CreatePointLight(RST_ToColor(0xCD,0xDD,0xFF,0), RST_ToColor(0xFF,0xFF,0xFF,0), RST_ToColor(0,0,0,0), [-100,-100,-20], [1, 0, 0]),
		  LIT_CreatePointLight(RST_ToColor(0xCD,0xDD,0xFF,0), RST_ToColor(0xFF,0xFF,0xFF,0), RST_ToColor(0,0,0,0), [ 100, 100,-20], [1, 0, 0])]);

	## �}�e���A����ݒ肷��B
	RST_SetRenderState($rs, 'RS_MATERIAL', LIT_CreateMaterial(
				RST_ToColor(0xFF,0xFF,0xFF,0), RST_ToColor(0xC0,0xD0,0xE0,0),
						RST_ToColor(0,0,0,0), RST_ToColor(0,0,0,0), 10));

	## �J�n�I�u�W�F�N�g���쐬����B
	my ($vertexBuff1, $primType1, $primOpt1) = 
		MSH_CreateTorus([[20,0],[25, 12],[30, 20],[35, 12],[40,0],
								[35,-12],[30,-20],[25,-12]], 10);

	## �I���I�u�W�F�N�g���쐬����B
	my ($vertexBuff2, $primType2, $primOpt2) = 
		MSH_CreateTorus([[5,0],[17, 2],[30, 30],[43, 2],[55,0],
								[43,-2],[30,-30],[17,-2]], 10);

	## �g�D�C�[�j���O���s���B
	my $vertexBuff = MSH_CreateTweening($vertexBuff1, $vertexBuff2, 12, $argPara - 32);

	## ���[���h�s���ݒ肷��B
	RST_SetRenderState($rs,'RS_TS_WORLD', MAT_MRotationX(MAT_DegToRad(4*$argPara)));

	## �e�N�X�`���̐ݒ���s���B
	## my $tttt1 = TEX_CreateTextureFromFile('aaa2.bmp');
	## my $tttt2 = TEX_CreateTextureFromFile('tex7.bmp');
	## RST_SetRenderState($rs,'RS_TS_TEXTURE', [$tttt1,$tttt2]);
	## RST_SetRenderState($rs,'RS_TSS_ADDRESSU', ['TADDRESS_MIRROR','TADDRESS_MIRROR']);

	## �v���~�e�B�u�̕`����s���B
	print '�T�[�t�F�X�`�撆�E�E�E�E', "\n";
	GEO_DrawPrimitive($tSurface, $rs, $primType1, $vertexBuff, $primOpt1);

	print '�t�@�C���o�͒��E�E�E�E', "\n";
	## BMP�t�@�C���ɏo�͂���B
	RST_PrintOutToBmp($tSurface, 'test'.$argPara.'.bmp');

}

