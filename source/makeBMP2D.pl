##_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
## Prefix Is MBF
##_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
use strict;

##
## BMP�t�@�C�����쐬���܂��B
##
sub MBF_PrintToBmp {
	my ($fileName, $cTable) = @_;

	## �摜�f�[�^�̃T�C�Y���擾����
	my $height = $#$cTable + 1;
	my $width  = $#{$cTable->[0]} + 1;

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
			print W_FILE $cTable->[$i][$j];
		}
	}

	## �t�@�C�������
	close(W_FILE);

}


##
## �w����W�Ɏw��̐F�œ_��ł�
## (x,y)�Ƃ����ꍇ
## ����(0,0)�A�E��(width-1,0)�A����(0, height-1)�A�E��(width-1,height-1)
## �ƂȂ�
##
sub MBF_SetColorData {
	my ($x, $y, $color, $cTable) = @_;

	## �摜�f�[�^�͈͂̃`�F�b�N
	return(0) if ( $x < 0 || $x > $#{$cTable->[0]} || $y < 0 || $y > $#$cTable );

	## �摜�f�[�^���L�^����
	$cTable->[$y][$x] = $color;
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
## @param1 �ԐF�̗v�f(0 �` 255)
## @param2 �ΐF�̗v�f(0 �` 255)
## @param3 �F�̗v�f(0 �` 255)
##
sub MBF_MakeRgbData {
	my($red, $green, $blue) = @_;

	return pack("CCC", $blue % 256, $green % 256, $red % 256);
}


##
## �V�K�̃J���[�e�[�u�����擾���܂��B
##
sub MBF_GetNewColorTable {
	my($width, $height, $color) = @_;

	## $width*3 �́A4�Ŋ���؂��K�v������B
	return 0 if (($width * 3) % 4 != 0);

	## �f�[�^�i�[�̈�̏�����
	my $cTable = [];
	for my $i(0..$height-1) {
		$cTable->[$i] = [];
		for my $j(0..$width-1) {
			$cTable->[$i][$j] = $color;
		}
	}

	return $cTable;
}



##
## �J���[�e�[�u�����N���A���܂��B
##
sub MBF_ClearColorTable {
	my($color, $cTable) = @_;
	map { map { $_ = $color } @$_  } @$cTable;
}



##
## ������`�悷��B
## (�v���[���n���̃A���S���Y��)
## @param1 x1 �����̎n�_(X���W)
## @param2 y1 �����̎n�_(Y���W)
## @param3 x2 �����̏I�_(X���W)
## @param4 y2 �����̏I�_(Y���W)
## @param5 color �����̐F
##
sub MBF_DrawLine {
	my ($x1, $y1, $x2, $y2, $color, $cTable) = @_;

	my ($i, $x, $y, $dx, $dy, $addx, $addy);
	my $cnt = 0;

	## �w�x�������ꂼ��̋���������
	## addx�Aaddy�����肷��
	$dx = $x2 - $x1;
	if ($dx < 0){
		$addx = -1;
		$dx  *= -1;
	} else {
		$addx = 1;
	}

	$dy = $y2 - $y1;
	if ($dy < 0){
		$addy = -1;
		$dy  *= -1;
	} else {
		$addy = 1;
	}

	$x = $x1;
	$y = $y1;

	## �w�x�������ꂼ��̋������ׂ�
	## �w�����������Ȃ�w����������A
	## �����łȂ��Ȃ�x��������ɂ���
	if ($dx > $dy){
		## �w�����̋����̕����傫��
		for ($i = 0; $i < $dx; ++$i){
			MBF_SetColorData($x, $y, $color, $cTable);
			$cnt += $dy;
			if ($cnt >= $dx){
				$cnt -= $dx;
				$y   += $addy;
			}
			$x += $addx;
		}
	} else {
		## �x�����̋����̕����傫��
		for ($i = 0; $i < $dy; ++$i){
			MBF_SetColorData($x, $y, $color, $cTable);
			$cnt += $dx;
			if ($cnt >= $dy){
				$cnt -= $dy;
				$x   += $addx;
			}
			$y += $addy;
		}
	}
}

##
## �~��`�悷��B
## �~�b�`�F�i�[�ɂ��~�`��̃A���S���Y��
## @param1 xo �~�̒��S(X���W)
## @param2 yo �~�̒��S(Y���W)
## @param3 r  �~�̔��a
## @param4 color  �~���̐F
##
sub MBF_DrawCircle {
	my ($xo, $yo, $r, $color, $cTable) = @_;
	my ($x, $y);

	$x = $r;
    $y = 0;
    while ($x >= $y){
		MBF_SetColorData($xo + $x, $yo + $y, $color, $cTable);
		MBF_SetColorData($xo + $x, $yo - $y, $color, $cTable);
		MBF_SetColorData($xo - $x, $yo + $y, $color, $cTable);
		MBF_SetColorData($xo - $x, $yo - $y, $color, $cTable);
		MBF_SetColorData($xo + $y, $yo + $x, $color, $cTable);
		MBF_SetColorData($xo + $y, $yo - $x, $color, $cTable);
		MBF_SetColorData($xo - $y, $yo + $x, $color, $cTable);
		MBF_SetColorData($xo - $y, $yo - $x, $color, $cTable);

		$r -= ($y << 1) - 1;
		if ($r < 0){
			$r += ($x - 1) << 1;
			$x--;
		}
		$y++;
	}
}

##
## �ȉ~��`�悷��
##
## @param1 xo �ȉ~�̒��S(X���W)
## @param2 yo �ȉ~�̒��S(Y���W)
## @param3 rx X�������̔��a
## @param4 ry Y�������̔��a
## @param5 color �~���̐F
##
sub MBF_DrawEllipse {
	my ($xo, $yo, $rx, $ry, $color, $cTable) = @_;
	my ($x, $x1, $y, $y1, $r);

	if ($rx > $ry){
		$x = $r = $rx;
		$y = 0;
		while ($x >= $y) {
			$x1 = int($x * $ry / $rx);
			$y1 = int($y * $ry / $rx);
			MBF_SetColorData($xo + $x, $yo + $y1, $color, $cTable);
			MBF_SetColorData($xo + $x, $yo - $y1, $color, $cTable);
			MBF_SetColorData($xo - $x, $yo + $y1, $color, $cTable);
			MBF_SetColorData($xo - $x, $yo - $y1, $color, $cTable);
			MBF_SetColorData($xo + $y, $yo + $x1, $color, $cTable);
			MBF_SetColorData($xo + $y, $yo - $x1, $color, $cTable);
			MBF_SetColorData($xo - $y, $yo + $x1, $color, $cTable);
			MBF_SetColorData($xo - $y, $yo - $x1, $color, $cTable);

			$r -= ($y << 1) - 1;
			if ($r < 0){
				$r += ($x - 1) << 1;
				$x--;
			}
			$y++;
		}
	} else{
		$x = $r = $ry;
		$y = 0;
		while ($x >= $y){
			$x1 = int($x * $rx / $ry);
			$y1 = int($y * $rx / $ry);
			MBF_SetColorData($xo + $x1, $yo + $y, $color, $cTable);
			MBF_SetColorData($xo + $x1, $yo - $y, $color, $cTable);
			MBF_SetColorData($xo - $x1, $yo + $y, $color, $cTable);
			MBF_SetColorData($xo - $x1, $yo - $y, $color, $cTable);
			MBF_SetColorData($xo + $y1, $yo + $x, $color, $cTable);
			MBF_SetColorData($xo + $y1, $yo - $x, $color, $cTable);
			MBF_SetColorData($xo - $y1, $yo + $x, $color, $cTable);
			MBF_SetColorData($xo - $y1, $yo - $x, $color, $cTable);

			$r -= ($y << 1) - 1;
			if ($r < 0){
				$r += ($x - 1) << 1;
				$x--;
			}
			$y++;
		}
	}
}

1;
