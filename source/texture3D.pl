##_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
## Prefix Is TEX
##_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
use strict;

###########################################################
##�y �e�N�X�`��[Texture]�̒�` �z
##
##  tTexture->[0] = [size, width, height]; (�e�N�X�`���w�b�_�[)
##    size   = 24 or 32 (1��f������̃f�[�^bit�T�C�Y)
##    width  = �e�N�X�`���̕�(width ��f)
##    height = �e�N�X�`���̍���(height ��f)
##
##  tTexture->[1][Y][X]; (�e�N�X�`���f�[�^)
##    24�r�b�g�t�H�[�}�b�g�̏ꍇ
##       1Byte�� = Blue
##       2Byte�� = Green
##       3Byte�� = Red
##
##    32�r�b�g�t�H�[�}�b�g�̏ꍇ
##       1Byte�� = Blue
##       2Byte�� = Green
##       3Byte�� = Red
##       4Byte�� = �A���t�@�l
##
###########################################################


###
## �t�@�C������e�N�X�`����ǂݍ���
## 24�r�b�g�t�H�[�}�b�gBMP�̏ꍇ�̓��l�͏�ɂP�ƂȂ�B
## 32�r�b�g�t�H�[�}�b�gBMP�̏ꍇ�̓��l�͎w��l�ƂȂ�B
##
sub TEX_CreateTextureFromFile {
	my ($sourceFileName) = @_;

	## �t�@�C������摜�f�[�^��ǂݍ���
	my ($data, $tTexture);
	open(TEXTURE_HANDLE, $sourceFileName) || return 0;
	binmode(TEXTURE_HANDLE);
	read(TEXTURE_HANDLE, $data, -s TEXTURE_HANDLE);
	close(TEXTURE_HANDLE);

	## �w�b�_�[�����擾����B
	my @headerInfo = unpack("aaL3L3S2L6", $data);
	## BMP�̃f�[�^�������擾����B
	substr($data, 0, $headerInfo[4], '');

	## �ォ�牺�ւ̃f�[�^�\���̏ꍇ�͉摜���㉺���E�t�ɂȂ�i���Ӂj
	$headerInfo[7] *= (-1) if ($headerInfo[7] < 0);
	## �����k�����ȊO�͕s��
	return 0 if ($headerInfo[10] != 0);
	## 24�r�b�g�A32�r�b�g�ȊO�̃t�H�[�}�b�g�̏ꍇ�͕s��
	return 0 if ($headerInfo[9] < 24);

	## �f�[�^���擾����B
	my $bCountByte = $headerInfo[9]/8;
	$tTexture->[0] = [$headerInfo[9], $headerInfo[6], $headerInfo[7]];
	for (my $y = 0 ; $y < $headerInfo[7] ; $y++) {
		for (my $x = 0 ; $x < $headerInfo[6] ; $x++) {
			$tTexture->[1][$y][$x] = substr($data, $bCountByte*($headerInfo[6]*$y+$x), $bCountByte );
		}
	}

	return $tTexture;
}


###
## 24bit�t�H�[�}�b�g��BMP�t�@�C������e�N�X�`����ǂݍ���
## ���̎����l�͋P�x���傫���قǑ傫���Ȃ�B
## �܂荕�F�͓����A���F�͕s�����ƂȂ�B
##
sub TEX_CreateAlphaTextureFromFile {
	my ($sourceFileName) = @_;

	## �t�@�C������摜�f�[�^��ǂݍ���
	my ($data, $tTexture);
	open(TEXTURE_HANDLE, $sourceFileName) || return 0;
	binmode(TEXTURE_HANDLE);
	read(TEXTURE_HANDLE, $data, -s TEXTURE_HANDLE);
	close(TEXTURE_HANDLE);

	## �w�b�_�[�����擾����B
	my @headerInfo = unpack("aaL3L3S2L6", $data);
	## BMP�̃f�[�^�������擾����B
	substr($data, 0, $headerInfo[4], '');

	## �ォ�牺�ւ̃f�[�^�\���̏ꍇ�͉摜���㉺���E�t�ɂȂ�i���Ӂj
	$headerInfo[7] *= (-1) if ($headerInfo[7] < 0);
	## �����k�����ȊO�͕s��
	return 0 if ($headerInfo[10] != 0);
	## 24�r�b�g�A32�r�b�g�ȊO�̃t�H�[�}�b�g�̏ꍇ�͕s��
	return 0 if ($headerInfo[9] != 24);

	## �f�[�^���擾����B
	my $bCountByte = $headerInfo[9]/8;
	$tTexture->[0] = [32, $headerInfo[6], $headerInfo[7]];
	for (my $y = 0 ; $y < $headerInfo[7] ; $y++) {
		for (my $x = 0 ; $x < $headerInfo[6] ; $x++) {
			my @colorData = unpack('C3', substr($data, $bCountByte*($headerInfo[6]*$y+$x), $bCountByte ));
			$tTexture->[1][$y][$x] = pack('C4', $colorData[0],$colorData[1],$colorData[2],
										int(($colorData[0]+$colorData[1]+$colorData[2])/3));
		}
	}

	return $tTexture;
}


sub TEX_GetTexColor {
	my ($tTexture, $addressuMode, $texTV) = @_;
	my ($x, $y);

	## AddressuMode --�y TADDRESS_CLAMP �z�̏ꍇ
	if ($addressuMode eq 'TADDRESS_CLAMP') {

		## �e�N�X�`�����W�� [0 �` height][0 �` width] �͈̔͂ɒ���
		$x = int($tTexture->[0][1] * $texTV->[0]);
		$y = int($tTexture->[0][2] * $texTV->[1]);
		$x = 0 if ($x < 0);
		$x = $tTexture->[0][1] - 1 if ($x > $tTexture->[0][1] - 1);
		$y = 0 if ($y < 0);
		$y = $tTexture->[0][2] - 1 if ($y > $tTexture->[0][2] - 1);

	## AddressuMode --�y TADDRESS_WRAP �z�̏ꍇ
	} elsif ($addressuMode eq 'TADDRESS_WRAP') {

		$x = $tTexture->[0][1] * $texTV->[0];
		$y = $tTexture->[0][2] * $texTV->[1];

		if ($x < 0) {
			$x = (int($x)*(-1) % $tTexture->[0][1] - $tTexture->[0][1] + 1)*(-1);
		} else {
			$x = int($x) % $tTexture->[0][1];
		}

		if ($y < 0) {
			$y = (int($y)*(-1) % $tTexture->[0][2] - $tTexture->[0][2] + 1)*(-1);
		} else {
			$y = int($y) % $tTexture->[0][2];
		}

	## AddressuMode --�y TADDRESS_MIRROR �z�̏ꍇ
	} else {

		$x = int($tTexture->[0][1] * $texTV->[0]);
		$y = int($tTexture->[0][2] * $texTV->[1]);
		$x *= (-1) if ($x < 0);
		$y *= (-1) if ($y < 0);
		$x = $x % ($tTexture->[0][1] * 2);
		$y = $y % ($tTexture->[0][2] * 2);
		$x = $tTexture->[0][1] * 2 - $x - 1 if ($x >= $tTexture->[0][1]);
		$y = $tTexture->[0][2] * 2 - $y - 1 if ($y >= $tTexture->[0][2]);

	}

	## �e�N�X�`���t�H�[�}�b�g 24bit �̏ꍇ
	## ���l�͏�ɂP�ƂȂ�B
	if ($tTexture->[0][0] == 24) {
		my @colorData = unpack('C3', $tTexture->[1][$y][$x]);
		return RST_ToColor($colorData[2], $colorData[1], $colorData[0], 0xFF);

	## �e�N�X�`���t�H�[�}�b�g 32bit �̏ꍇ
	} else {
		my @colorData = unpack('C4', $tTexture->[1][$y][$x]);
		return RST_ToColor($colorData[2], $colorData[1], $colorData[0], $colorData[3]);
	}

}

1;
