##_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
## Prefix Is PXL
##_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
use strict;
require '..\PY3D\vertex3D.pl';
require '..\PY3D\texture3D.pl';

###
## �s�N�Z���V�F�[�_�[�����s����B
## �s�N�Z���X�g���[��������W�A�F�A�[�x�o�b�t�@�A�X�e���V���o�b�t�@��
## �����_�����O�^�[�Q�b�g�T�[�t�F�X�ɏ������݂܂��B
##
sub PXL_PixelShader {
	my ($tSurface, $rs, $pixelStream) = @_;

	for my $i (0..$#$pixelStream) {
		my $x = $pixelStream->[$i]->{"VECTOR"}->[0];
		my $y = $pixelStream->[$i]->{"VECTOR"}->[1];

		## �����_�����O�^�[�Q�b�g�T�[�t�F�X���̓_�����肷��B
		next if ( $x < 0 || $x > $#{$tSurface->[0]} || $y < 0 || $y > $#$tSurface );
		## Z�e�X�g������s���B
		if ($tSurface->[$y][$x][4] > $pixelStream->[$i]->{"Z"} && 0 < $pixelStream->[$i]->{"Z"}) {

			## �f�B�t�F�[�Y�F��ݒ肷��B
			my $texelR = $pixelStream->[$i]->{'DIFFUSE'}->[0];
			my $texelG = $pixelStream->[$i]->{'DIFFUSE'}->[1];
			my $texelB = $pixelStream->[$i]->{'DIFFUSE'}->[2];
			my $texelA = $pixelStream->[$i]->{'DIFFUSE'}->[3];

			## �e�N�X�`���F�̍������s���B
			for my $texStage (0..$#{$pixelStream->[$i]->{'TEX'}}) {
				my $tC = TEX_GetTexColor($rs->{'RS_TS_TEXTURE'}->[$texStage], $rs->{'RS_TSS_ADDRESSU'}->[$texStage],
										$pixelStream->[$i]->{'TEX'}->[$texStage]);
				$texelR *= $tC->[0];
				$texelG *= $tC->[1];
				$texelB *= $tC->[2];
				$texelA *= $tC->[3];
			}

			## �X�y�L�����F�̍������s���B
			$texelR += $pixelStream->[$i]->{'SPECULAR'}->[0];
			$texelG += $pixelStream->[$i]->{'SPECULAR'}->[1];
			$texelB += $pixelStream->[$i]->{'SPECULAR'}->[2];
			## $texelA += $pixelStream->[$i]->{'SPECULAR'}->[3];
			## ���_�̃X�y�L�����F�̃A���t�@�����ɂ̓t�H�O�W�����i�[����Ă���B


			## ���u�����f�B���O���L���ȏꍇ
			if ($rs->{'RS_ALPHABLENDENABLE'} eq 'TRUE') {
				$tSurface->[$y][$x][0] = $texelR * $texelA + $tSurface->[$y][$x][0] * (1 - $texelA);
				$tSurface->[$y][$x][1] = $texelG * $texelA + $tSurface->[$y][$x][1] * (1 - $texelA);
				$tSurface->[$y][$x][2] = $texelB * $texelA + $tSurface->[$y][$x][2] * (1 - $texelA);
				$tSurface->[$y][$x][3] = $texelA * $texelA + $tSurface->[$y][$x][3] * (1 - $texelA);
			## ���u�����f�B���O�������ȏꍇ
			} else {
				$tSurface->[$y][$x][0] = $texelR;
				$tSurface->[$y][$x][1] = $texelG;
				$tSurface->[$y][$x][2] = $texelB;
				$tSurface->[$y][$x][3] = $texelA;
			}

			## Z�l�A�X�e���V���o�b�t�@�l�̍X�V���s���B
			$tSurface->[$y][$x][4] = $pixelStream->[$i]->{"Z"} if ($rs->{'RS_ZWRITEENABLE'} eq 'TRUE');
			$tSurface->[$y][$x][5] = 0;

			## �t�H�O���ʂ̃e�X�g�p�ɒǉ� Start
			if ($rs->{"RS_FOGCOLOR"}) {
				## �t�H�O���E�l
				my $dife = 0.95;
				if ($tSurface->[$y][$x][4] > $dife) {
					my $f = ( $tSurface->[$y][$x][4] - $dife )/(1 - $dife);

					$tSurface->[$y][$x][0] =  $tSurface->[$y][$x][0] * (1 - $f) + $rs->{"RS_FOGCOLOR"}->[0] * $f;
					$tSurface->[$y][$x][1] =  $tSurface->[$y][$x][1] * (1 - $f) + $rs->{"RS_FOGCOLOR"}->[1] * $f;
					$tSurface->[$y][$x][2] =  $tSurface->[$y][$x][2] * (1 - $f) + $rs->{"RS_FOGCOLOR"}->[2] * $f;
					$tSurface->[$y][$x][3] =  $tSurface->[$y][$x][3] * (1 - $f) + $rs->{"RS_FOGCOLOR"}->[3] * $f;
				}
			}
			## �t�H�O���ʂ̃e�X�g�p�ɒǉ� End
		}
	}
}


##
## ������`�悷��B
## @param1 tSurface �����_�����O�^�[�Q�b�g�T�[�t�F�X
## @param2 color �����̐F
## @param3 x1 �����̎n�_(X���W)
## @param4 y1 �����̎n�_(Y���W)
## @param5 x2 �����̏I�_(X���W)
## @param6 y2 �����̏I�_(Y���W)
##
sub PXL_PixelShaderLine {
	my ($tSurface, $color, $x1, $y1, $x2, $y2) = @_;

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
			## �F�̍X�V���s���B
			$tSurface->[$y][$x][0] = $color->[0];
			$tSurface->[$y][$x][1] = $color->[1];
			$tSurface->[$y][$x][2] = $color->[2];
			$tSurface->[$y][$x][3] = $color->[3];
			$tSurface->[$y][$x][4] = 0;
			$tSurface->[$y][$x][5] = 0;
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
			## �F�̍X�V���s���B
			$tSurface->[$y][$x][0] = $color->[0];
			$tSurface->[$y][$x][1] = $color->[1];
			$tSurface->[$y][$x][2] = $color->[2];
			$tSurface->[$y][$x][3] = $color->[3];
			$tSurface->[$y][$x][4] = 0;
			$tSurface->[$y][$x][5] = 0;
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
## ���_�f�[�^���O�p�`�����̑S�Ẵs�N�Z���ɂ��ĕ�Ԃ���
##
## ���̒��_�t�H�[�}�b�g�� VEWPORTVERTEX�Ƃ���B
## �@�@�X�N���[�����W Vertex->{"VECTOR"} = [x, y];
## �@�@Z �o�b�t�@�[�x Vertex->{"Z"} = z;
## �@�@�����̋t��     Vertex->{"RHW"} = rhw;
## �@�@�f�B�t�F�[�Y�F Vertex->{"DIFFUSE"} = [r,g,b,a];
## �@�@�X�y�L�����F   Vertex->{"SPECULAR"} = [r,g,b,a];
## �@�@�e�N�X�`�����W Vertex->{"TEX"} = [[tu1, tv1],[tu2, tv2],[tu3, tv3]...];
##
## @param1 vA �O�p�`�̓_A (Vertex)
## @param2 vB �O�p�`�̓_B (Vertex)
## @param3 vC �O�p�`�̓_C (Vertex)
##
sub PXL_VertexToPixel {
	my ($vA, $vB, $vC) = @_;

	## X,Y�����ɂ��Ă��ꂼ�ꏸ���Ƀ\�[�g�������͈̔͂����߂�
	my @xSortArray = sort {$a <=> $b;} ($vA->{"VECTOR"}->[0], $vB->{"VECTOR"}->[0], $vC->{"VECTOR"}->[0]);
	my @ySortArray = sort {$a <=> $b;} ($vA->{"VECTOR"}->[1], $vB->{"VECTOR"}->[1], $vC->{"VECTOR"}->[1]);
	my ($xStartPos, $xEndPos, $yStartPos, $yEndPos) = ( lookUpLineStartPos($xSortArray[0]),
														lookUpLineEndPos($xSortArray[2]),
														lookUpLineStartPos($ySortArray[0]),
														lookUpLineEndPos($ySortArray[2]));
	## �O�p�`�̊O�ς����߂�
	my $primBata = traiangleCros($vA->{"VECTOR"}, $vB->{"VECTOR"}, $vC->{"VECTOR"});

	## �������J�n����
	my $pixelStream = VTX_CreateVertexBuffer();
	for my $yLine ($yStartPos..$yEndPos) {
		for my $xLine ($xStartPos..$xEndPos) {

			my $bataC = traiangleCros( [$xLine,$yLine], $vA->{"VECTOR"}, $vB->{"VECTOR"});
			my $bataA = traiangleCros( [$xLine,$yLine], $vB->{"VECTOR"}, $vC->{"VECTOR"});
			my $bataB = traiangleCros( [$xLine,$yLine], $vC->{"VECTOR"}, $vA->{"VECTOR"});

			## �O�p�`�̓�������OK�̏ꍇ�̓s�N�Z���P�ʂɐ��`��Ԃ��s��
			if (($bataA >= 0 && $bataB >= 0 && $bataC >= 0) ||
				($bataA <= 0 && $bataB <= 0 && $bataC <= 0)) {
				my $menA 		= $bataA/$primBata;
				my $menB		= $bataB/$primBata;
				my $menC		= $bataC/$primBata;
				my $hZ			= $menA*$vA->{"Z"} + $menB*$vB->{"Z"} + $menC*$vC->{"Z"};
				my $hRHW		= $menA*$vA->{"RHW"} + $menB*$vB->{"RHW"} + $menC*$vC->{"RHW"};
				my $hDIFFUSE_R	= $menA*$vA->{"DIFFUSE"}->[0] + $menB*$vB->{"DIFFUSE"}->[0] + $menC*$vC->{"DIFFUSE"}->[0];
				my $hDIFFUSE_G	= $menA*$vA->{"DIFFUSE"}->[1] + $menB*$vB->{"DIFFUSE"}->[1] + $menC*$vC->{"DIFFUSE"}->[1];
				my $hDIFFUSE_B	= $menA*$vA->{"DIFFUSE"}->[2] + $menB*$vB->{"DIFFUSE"}->[2] + $menC*$vC->{"DIFFUSE"}->[2];
				my $hDIFFUSE_A	= $menA*$vA->{"DIFFUSE"}->[3] + $menB*$vB->{"DIFFUSE"}->[3] + $menC*$vC->{"DIFFUSE"}->[3];
				my $hSPECULAR_R	= $menA*$vA->{"SPECULAR"}->[0] + $menB*$vB->{"SPECULAR"}->[0] + $menC*$vC->{"SPECULAR"}->[0];
				my $hSPECULAR_G	= $menA*$vA->{"SPECULAR"}->[1] + $menB*$vB->{"SPECULAR"}->[1] + $menC*$vC->{"SPECULAR"}->[1];
				my $hSPECULAR_B	= $menA*$vA->{"SPECULAR"}->[2] + $menB*$vB->{"SPECULAR"}->[2] + $menC*$vC->{"SPECULAR"}->[2];
				my $hSPECULAR_A	= $menA*$vA->{"SPECULAR"}->[3] + $menB*$vB->{"SPECULAR"}->[3] + $menC*$vC->{"SPECULAR"}->[3];
				my $tex = [];
				for my $index (0..$#{$vA->{'TEX'}}) {
						push(@$tex, [	$menA*$vA->{'TEX'}->[$index]->[0]+
										$menB*$vB->{'TEX'}->[$index]->[0]+
										$menC*$vC->{'TEX'}->[$index]->[0],
										$menA*$vA->{'TEX'}->[$index]->[1]+
										$menB*$vB->{'TEX'}->[$index]->[1]+
										$menC*$vC->{'TEX'}->[$index]->[1]]);
				}

				VTX_PushVertex($pixelStream, VTX_MakeVewportVertex( [$xLine, $yLine], $hZ, $hRHW, 
								[$hDIFFUSE_R, $hDIFFUSE_G, $hDIFFUSE_B, $hDIFFUSE_A],
								[$hSPECULAR_R, $hSPECULAR_G, $hSPECULAR_B, $hSPECULAR_A], $tex));
			}
		}
	}

	return $pixelStream;
}


##
## �����̊J�n�ʒu�����߂�
## @param1 �J�n�_�i���������j
##
sub lookUpLineStartPos {
	my ($flotVal) = @_;

	if ( $flotVal >0 ) {
		if (int($flotVal) == $flotVal) {
			return $flotVal;
		} else {
			return int($flotVal)+1;
		}
	} else {
		return int($flotVal);
	}

}

##
## �����̏I���ʒu�����߂�
## @param1 �I���_�i���������j
##
sub lookUpLineEndPos {
	my ($flotVal) = @_;

	if ( $flotVal >0 ) {
		return int($flotVal);
	} else {
		if (int($flotVal) == $flotVal) {
			return $flotVal;
		} else {
			return int($flotVal)-1;
		}
	}

}


##
## �O�p�`ABC�̊O�ς�Z������Ԃ��B
## �ȉ��̂悤�Ɍv�Z���s���B
## (�x�N�g��AB) X (�x�N�g��AC)
## �߂�l�́AZ�����̒l�B
##
## @param1 vA �O�p�`�̓_A [x,y]
## @param2 vB �O�p�`�̓_B [x,y]
## @param3 vC �O�p�`�̓_C [x,y]
##
sub traiangleCros {
	my ($vA, $vB, $vC) = @_;
	return ($vB->[0] - $vA->[0])*($vC->[1] - $vA->[1]) - ($vB->[1] - $vA->[1])*($vC->[0] - $vA->[0]);
}

1;
