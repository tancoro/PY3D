##_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
## Prefix Is RST
##_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
use strict;
require '..\PY3D\matrix3D.pl';

##########################################
##�y TargetSurface �̒�` �z
##
##  TSurface->[y][x]; (BMP�̂P�s�N�Z���ɑΉ�)
##  TSurface�� height[Y] �� 0 �` $#TSurface (BMP�̍����Ɉ�v)
##  TSurface�� width [X] �� 0 �` $#{TSurface->[0]} (BMP�̕��Ɉ�v)
##
##�y TargetSurface�� pixel�̒�` �z
##  pixel = TSurface->[y][x]; �Ƃ����ꍇ�A
##  pixel = [r, g, b, a, z, s] �Ƃ���B
##  r, g, b, a �� color�l�B
##  z �� flot�[�x�o�b�t�@
##  s �� flot�X�e���V���o�b�t�@
##
##�y RenderState �̒�` �z
##
##  �ȉ��ɐݒ���e�ƒl�������B�Ȃ��A()�̐����̓f�t�H���g�l��\��
##  RenderState->{"RS_TS_WORLD"} = Matrix ���[���h�s�� (�P�ʍs��)
##  RenderState->{"RS_TS_VIEW"} = Matrix �r���[�s�� (�P�ʍs��)
##  RenderState->{"RS_TS_PROJECTION"} = Matrix �ˉe�g�����X�t�H�[���s�� (�P�ʍs��)
##  RenderState->{"RS_TS_TEXTURE"} = [ Texture0, Texture1, Texture2 �E�E�E] �e�e�N�X�`���X�e�[�W�ɐݒ肳���Texture (�Ȃ�)
##  RenderState->{"RS_TSS_ADDRESSU"} = [ mode1, mode2, mode3�E�E�E]  �e�e�N�X�`���X�e�[�W�̃A�h���X���[�h���w�肷��B
##										'TADDRESS_WRAP'�A'TADDRESS_MIRROR'�A'TADDRESS_CLAMP' �̂R���ݒ�\�B
##  RenderState->{"RS_LIGHT"} = [ Light1, Light2, Light3�E�E�E] ���C�g�I�u�W�F�N�g�̔z�� (�Ȃ�)
##  RenderState->{"RS_AMBIENT"} = [r,g,b,a] ����
##  RenderState->{"RS_MATERIAL"} = Material �}�e���A���I�u�W�F�N�g (�Ȃ�)
##  RenderState->{"RS_FOGCOLOR"} = [r,g,b,a] �t�H�O�Ɏg�p����F
##  RenderState->{"RS_LINE_COLOR"} = [r,g,b,a] GEO_DrawPrimitiveLine()���g�p���ă��C���[�t���[����`�悷�鎞�̐��̐F
##  RenderState->{"RS_ALPHABLENDENABLE"} =  ���u�����f�B���O��L���ɂ���ꍇ��'TRUE'�A�����ɂ���ꍇ�� 'FALSE' ���w�肷��B
##  RenderState->{"RS_ZWRITEENABLE"} = �[�x�o�b�t�@�ւ̏������݂�L���ɂ���ɂ́A'TRUE'��ݒ肷��B'FALSE'�̏ꍇ�͐[�x��r�����s����邪�A�[�x�l�̓o�b�t�@�ɏ������܂�Ȃ��B 
##########################################


###
## �V�K�̃����_�����O�^�[�Q�b�g�T�[�t�F�X���쐬���܂��B
## �[�x�o�b�t�@�E�X�e���V���o�b�t�@�E���l�������܂��B
## �����ō��ꂽ�����_�����O�^�[�Q�b�g�T�[�t�F�X�̃T�C�Y�́A
## ���̂܂�BMP�̃t�@�C���T�C�Y�ɂȂ�܂��B
##
## @param1 $width  ��
## @param2 $height ����
## @param3 $color  �f�t�H���g�̓h��Ԃ��F [r,g,b,a]
## @return �����_�����O�^�[�Q�b�g�T�[�t�F�X
##
sub RST_CreateTargetSurface {
	my($width, $height, $color) = @_;

	## $width*3 �́A4�Ŋ���؂��K�v������B
	return 0 if (($width * 3) % 4 != 0);

	## �f�[�^�i�[�̈�̏�����
	my $tSurface = [];
	for my $i(0..$height-1) {
		$tSurface->[$i] = [];
		for my $j(0..$width-1) {
			$tSurface->[$i][$j] = [@$color, 1.0, 1.0];
		}
	}

	return $tSurface;
}


###
## �����_�����O�^�[�Q�b�g�T�[�t�F�X�̃f�[�^���N���A���܂��B
## �[�x�o�b�t�@�E�X�e���V���o�b�t�@�E���l�͑S�ď����l�ɖ߂���A
## �w�肳�ꂽ�F�œh��Ԃ���܂��B
##
## @param1 $tSurface �����_�����O�^�[�Q�b�g�T�[�t�F�X
## @param2 $color    �h��Ԃ��F [r,g,b,a]
## @return �����_�����O�^�[�Q�b�g�T�[�t�F�X
##
sub RST_ClearTargetSurface {
	my($tSurface, $color) = @_;

	for my $i(0..$#$tSurface) {
		for my $j(0..$#{$tSurface->[0]}) {
			$tSurface->[$i][$j][0] = $color->[0];
			$tSurface->[$i][$j][1] = $color->[1];
			$tSurface->[$i][$j][2] = $color->[2];
			$tSurface->[$i][$j][3] = $color->[3];
			$tSurface->[$i][$j][4] = 1.0;
			$tSurface->[$i][$j][5] = 1.0;
		}
	}

	return $tSurface;
}


###
## �����_�����O�^�[�Q�b�g�T�[�t�F�X��
## �[�x�o�b�t�@���w��l�ŃN���A���܂��B
##
## @param1 $tSurface �����_�����O�^�[�Q�b�g�T�[�t�F�X
## @param2 $zValue   �[�x�o�b�t�@�l
## @return �����_�����O�^�[�Q�b�g�T�[�t�F�X
##
sub RST_ClearZInTargetSurface {
	my($tSurface, $zValue) = @_;

	for my $i(0..$#$tSurface) {
		for my $j(0..$#{$tSurface->[0]}) {
			$tSurface->[$i][$j][4] = $zValue;
		}
	}

	return $tSurface;
}


###
## �����_�����O�^�[�Q�b�g�T�[�t�F�X�̃f�[�^��BMP�t�@�C���ɏo�͂��܂��B
##
## @param1 �����_�����O�^�[�Q�b�g�T�[�t�F�X
## @param2 BMP�t�@�C����
##
sub RST_PrintOutToBmp {
	my ($tSurface, $fileName) = @_;

	## �摜�f�[�^�̃T�C�Y���擾����
	my $height = $#$tSurface + 1;
	my $width  = $#{$tSurface->[0]} + 1;

	## �o�͗p�̃t�@�C�����J��
	open(W_FILE, '>' . $fileName) || return(0);
	binmode(W_FILE);

	## �t�@�C���w�b�_�[�����o�͂���
	print W_FILE makeBmpFileHeader($width * $height * 3 + 54);

	## ���w�b�_�[�����o�͂���
	print W_FILE makeBmpInfoHeader($width, $height);

	## �摜�f�[�^���o�͂���
	## ��������E��Ɍ������ċL�^�����
	for(my $i = 0; $i < $height ; $i++) {
		for(my $j = 0 ; $j < $width ; $j++) {
			my $red = $tSurface->[$i][$j][0];
			my $gre = $tSurface->[$i][$j][1];
			my $bru = $tSurface->[$i][$j][2];
			print W_FILE makeRgbData($red, $gre, $bru);
		}
	}

	## �t�@�C�������
	close(W_FILE);

}


##
## BMP�̃t�@�C���w�b�_�[���쐬���܂��B
## �t�@�C���w�b�_�[�T�C�Y�� 14Byte�B
##
## @param1 BMP�t�@�C���̑S�T�C�Y(Byte)
##
sub makeBmpFileHeader {
	my ($fileSizeAll) = @_;

	return pack("aaL3", 'B', 'M', $fileSizeAll, 0, 54);
}


##
## BMP�̏��w�b�_�[���쐬���܂��B
##
## @param1 �摜�̕�(�s�N�Z���P��)
## @param2 �摜�̍���(�s�N�Z���P��)
##
sub makeBmpInfoHeader {
	my($width, $height) = @_;

	return pack("L3S2L6", 40, $width, $height, 1, 24, 0, $width * $height * 3, 11808, 11808, 0, 0);
}


##
## BMP�̉摜�f�[�^�������쐬���܂��B
##
## @param1 �ԐF�̗v�f(0 �` 1.0)
## @param2 �ΐF�̗v�f(0 �` 1.0)
## @param3 �F�̗v�f(0 �` 1.0)
##
sub makeRgbData {
	my($red, $green, $blue) = @_;
	$red *= 255; $green *= 255; $blue *= 255;
	$red = 0 if ($red < 0); $red = 255 if ($red > 255);
	$green = 0 if ($green < 0); $green = 255 if ($green > 255);
	$blue = 0 if ($blue < 0); $blue = 255 if ($blue > 255);
	return pack("CCC", $blue % 256, $green % 256, $red % 256);
}


###
## �V�K�̃����_�����O�X�e�[�g�I�u�W�F�N�g���쐬���܂��B
## �e��v�Z���@�E�`����@��ݒ肷�邽�߂Ɏg�p���܂��B
##
## @return �V�K�̃����_�����O�X�e�[�g�I�u�W�F�N�g
##
sub RST_CreateRenderState {
	my $rs = {};

	$rs->{'RS_TS_WORLD'} = MAT_MIdentity();
	$rs->{'RS_TS_VIEW'} = MAT_MIdentity();
	$rs->{'RS_TS_PROJECTION'} = MAT_MIdentity();
	## $rs->{'RS_TS_TEXTURE'}
	## $rs->{'RS_TSS_ADDRESSU'}
	## $rs->{'RS_LIGHT'}
	## $rs->{'RS_MATERIAL'}
	## $rs->{'RS_FOGCOLOR'}
	$rs->{'RS_AMBIENT'} = RST_ToColor(0x00, 0x00, 0x00, 0x00);
	$rs->{'RS_LINE_COLOR'} = RST_ToColor(0xFF,0xFF,0xFF,0xFF);
	$rs->{'RS_ALPHABLENDENABLE'} = 'FALSE';
	$rs->{'RS_ZWRITEENABLE'} = 'TRUE';

	return $rs;
}


###
## �����_�����O�X�e�[�g��ݒ肷��B
##
## @param1 �����_�����O�X�e�[�g�I�u�W�F�N�g
## @param2 ����
## @param3 ���ڂɑ΂���ݒ�l
##
sub RST_SetRenderState {
	my ($rso ,$stateType, $value) = @_;
	$rso->{$stateType} = $value;
}


###
## �����_�����O�X�e�[�g���擾����B
##
## @param1 �����_�����O�X�e�[�g�I�u�W�F�N�g
## @param2 ����
##
sub RST_GetRenderState {
	my ($rso ,$stateType) = @_;
	return $rso->{$stateType};
}


###
## 255 �` 0 ��COLOR�l��
## 1.0 �` 0 �͈̔͂Ƀg�����X�|�[�g���܂��B
##
sub RST_ToColor {
	my ($r, $g, $b, $a) = @_;
	my $redf = $r / 255;
	my $gref = $g / 255;
	my $bluf = $b / 255;
	my $alff = $a / 255;

	$redf = 0 if ($redf < 0); $redf = 1.0 if ($redf > 1.0);
	$gref = 0 if ($gref < 0); $gref = 1.0 if ($gref > 1.0);
	$bluf = 0 if ($bluf < 0); $bluf = 1.0 if ($bluf > 1.0);
	$alff = 0 if ($alff < 0); $alff = 1.0 if ($alff > 1.0);

	return [$redf, $gref, $bluf, $alff];
}

1;
