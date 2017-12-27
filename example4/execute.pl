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
	my $tSurface = RST_CreateTargetSurface(400,400, RST_ToColor(0,0,0,0));

	## �����_�����O�X�e�[�g�I�u�W�F�N�g���쐬����B
	my $rs = RST_CreateRenderState();

	## �r���[�s���ݒ肷��B
	RST_SetRenderState($rs, 'RS_TS_VIEW', MAT_MMultiply( MAT_MTranslate(0, 0, 120)));

	## �ˉe�s���ݒ肷��B
	RST_SetRenderState($rs, 'RS_TS_PROJECTION',
						MAT_MProjection(30, 300, MAT_DegToRad(60), MAT_DegToRad(60)));

	## �O���[�o���A���r�G���g��ݒ肷��B
	RST_SetRenderState($rs, 'RS_AMBIENT', RST_ToColor(0,0,0,0));

	## ���C�g�̐ݒ���s�Ȃ��B
	RST_SetRenderState($rs, 'RS_LIGHT', [ LIT_CreatePointLight(RST_ToColor(0xE0,0xA0,0xFF,0), RST_ToColor(0xEA,0xEA,0xFA,0), RST_ToColor(0,0,0,0), [0, 0, -30], [1, 0, 0])] );

	## �}�e���A����ݒ肷��B
	RST_SetRenderState($rs, 'RS_MATERIAL', LIT_CreateMaterial(
				RST_ToColor(0xE0,0xFF,0xC0,0), RST_ToColor(0xDF,0xEF,0xFF,0),
						RST_ToColor(0x00,0x00,0x00,0), RST_ToColor(0x00,0x00,0x00,0), 50));

	## ���[���h�s���ݒ肷��B
	RST_SetRenderState($rs,'RS_TS_WORLD', MAT_MMultiply( MAT_MTranslate(-50, -50, 0)));

	## ���ɂȂ�O�p�`���擾����B
	print '��v���~�e�B�u�擾���E�E�E', "\n";
	my ($num, $primType, $vertexBuff, $primOption ) = (0, 'D3DPT_TRIANGLELIST', getObjctSource(), 1);
	print '��v���~�e�B�u�`�撆�E�E�E', "\n";
	GEO_DrawPrimitiveLine($tSurface, $rs, $primType, $vertexBuff, $primOption);
	print '��v���~�e�B�uBMP�o�͒��E�E�E', "\n";
	RST_PrintOutToBmp($tSurface, 'kunk'. $num . '.bmp');
	print '�T�[�t�F�X�N���A���E�E�E', "\n";
	RST_ClearTargetSurface($tSurface, RST_ToColor(0,0,0,0));

	for($num = 1; $num < 8 ; $num++) {
		
		print '/_/_/_/_/_/_/_/_/_/_/_/_/ num [' . $num . '] /_/_/_/_/_/_/_/_/_/_/_/_/', "\n";
		## �ו���
		print 'ObjectA �ו����E�E�E', "\n";
		if ($num >= 7) {
			($vertexBuff, $primType, $primOption ) = MSH_CreateMountainsLast($vertexBuff);
		} else {
			($vertexBuff, $primType, $primOption ) = MSH_CreateMountains($vertexBuff);
		}

		## �I�u�W�F�N�g�̕`��
		print 'ObjectA Line �`�撆�E�E�E', "\n";
		GEO_DrawPrimitiveLine($tSurface, $rs, $primType, $vertexBuff, $primOption);

		## BMP�t�@�C���ɏo��
		print '�t�@�C���o�͒��E�E�E�E', "\n";
		RST_PrintOutToBmp($tSurface, 'kunk'. $num . '.bmp');

		## �T�[�t�F�X���N���A
		print '�^�[�Q�b�g�T�[�t�F�X�N���A���E�E�E' , "\n";
		RST_ClearTargetSurface($tSurface, RST_ToColor(0,0,0,0));
		print '/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/', "\n";

	}

	print '/_/_/_/_/_/_/_/_/_/_/_/_/ num [' . $num . '] /_/_/_/_/_/_/_/_/_/_/_/_/', "\n";
	## �I�u�W�F�N�g�̕`��
	print 'ObjectA �`�撆�E�E�E', "\n";
	GEO_DrawPrimitive($tSurface, $rs, $primType, $vertexBuff, $primOption);
	## BMP�t�@�C���ɏo��
	print '�ŏI�t�@�C���o�͒��E�E�E�E', "\n";
	RST_PrintOutToBmp($tSurface, 'kunk'. $num . '.bmp');
	print '/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/', "\n";


}


## �������_���쐬����B
sub getObjctSource {
	my $vertexBuff = VTX_CreateVertexBuffer();
	VTX_PushVertex( $vertexBuff, VTX_MakeUnlitVertex([0,0,0], [0,0,0]));
	VTX_PushVertex( $vertexBuff, VTX_MakeUnlitVertex([100,0,0], [0,0,0]));
	VTX_PushVertex( $vertexBuff, VTX_MakeUnlitVertex([50,100,0], [0,0,0]));
	return $vertexBuff;
}

1;
