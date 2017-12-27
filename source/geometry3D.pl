##_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
## Prefix Is GEO
##_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
use strict;
require '..\PY3D\vector3D.pl';
require '..\PY3D\matrix3D.pl';
require '..\PY3D\pixel3D.pl';
require '..\PY3D\vertex3D.pl';


#######################################################################
## (1) �|���S���̒��_�f�[�^��ǂݍ���
##
## (2) �|���S���̒��_�f�[�^�ɑ΂��Ē��_�V�F�[�_�����s
##
## (3) �N���b�s���O�A�v���Z�A�r���[�|�[�g�ϊ��Ȃǂ��s��
##
## (4) ���_�f�[�^���|���S�������̑S�Ẵs�N�Z���ɂ��ĕ��
##
## (5) �|���S�������̑S�Ẵs�N�Z���f�[�^�ɂ��ăs�N�Z���V�F�[�_�����s���A�F���v�Z
##
## (6) �t�H�O�u�����h�A�A���t�@�e�X�g�A�X�e���V���e�X�g�A�f�v�X�e�X�g�A�A���t�@�u�����f�B���O�Ȃǂ��s��
##
## (7) �����_�����O�^�[�Q�b�g�T�[�t�F�X�ɐF���������� 
##
#######################################################################


###
## �����_�����O���s���B
##
## @param1 �����_�����O�^�[�Q�b�g�T�[�t�F�X
## @param2 �����_�����O�X�e�[�g�I�u�W�F�N�g
## @param3 �v���~�e�B�u�^�C�v
## @param4 ���_�o�b�t�@
## @param5 �I�v�V�����i�v���~�e�B�u�^�C�v�ɂ��p�r�͈قȂ�j
##
sub GEO_DrawPrimitive {
	my ($tSurface, $rs, $primitiveType, $vertexBuffer, $primitiveOption) = @_;

	## ���C�e�B���O�E�g�����X�t�H�[�����s���B
	my $vertexStream = GEO_PipeLine($vertexBuffer, $rs);

	## �r���[�|�[�g�ϊ��s����쐬����B
	my $width2  = $#{$tSurface->[0]}/2;
	my $height2 = $#$tSurface/2;
	my $matTranceformVP = MAT_MMultiply(MAT_MScaling($width2, $height2, 1),
										MAT_MTranslate($width2, $height2, 0));

	## �O�p�`���X�g�̏ꍇ
	if ($primitiveType eq 'D3DPT_TRIANGLELIST') {
		for ( my $i = 0; $i < $primitiveOption; $i++) {

			## �v���~�e�B�u���擾���邽�߂̃C���f�b�N�X�����߂�B
			my $ind1 = 0 + 3 * $i;
			my $ind2 = 1 + 3 * $i;
			my $ind3 = 2 + 3 * $i;

			## �N���b�s���O������s���B
			next if (GEO_IsClipping($vertexStream->[$ind1],
									$vertexStream->[$ind2],
									$vertexStream->[$ind3]));

			## �r���[�|�[�g�ϊ��E�v���Z���s���B
			## �s�N�Z����Ԃ��s���A�����_�����O�^�[�Q�b�g�T�[�t�F�X�ɑ΂��ď������ށB
			PXL_PixelShader($tSurface, $rs, PXL_VertexToPixel( GEO_ScaleToViewPort($matTranceformVP,
									$vertexStream->[$ind1], $vertexStream->[$ind2], $vertexStream->[$ind3])));
		}

	## �O�p�`�X�g���b�v�̏ꍇ
	} elsif ($primitiveType eq 'D3DPT_TRIANGLESTRIP') {
		for ( my $i = 0; $i < $primitiveOption; $i++) {

			## �v���~�e�B�u���擾���邽�߂̃C���f�b�N�X�����߂�B
			my $ind1 = 0 + $i;
			my $ind2 = 1 + $i;
			my $ind3 = 2 + $i;

			## �N���b�s���O������s���B
			next if (GEO_IsClipping($vertexStream->[$ind1],
									$vertexStream->[$ind2],
									$vertexStream->[$ind3]));

			## �r���[�|�[�g�ϊ��E�v���Z���s���B
			## �s�N�Z����Ԃ��s���A�����_�����O�^�[�Q�b�g�T�[�t�F�X�ɑ΂��ď������ށB
			PXL_PixelShader($tSurface, $rs, PXL_VertexToPixel( GEO_ScaleToViewPort($matTranceformVP,
									$vertexStream->[$ind1], $vertexStream->[$ind2], $vertexStream->[$ind3])));

		}

	## �x����]���b�V���̏ꍇ(MSH_CreateRotationY�ɂ���č쐬���ꂽ�ꍇ)
	} elsif ($primitiveType eq 'D3DPT_MSH_ROTATIONY') {

		my $transVertexCnt = $primitiveOption->[0];
		my $vertexListCnt = $primitiveOption->[1];

		for my $listNum (1..$vertexListCnt) {
			my $startIndPos = 2 + ($listNum - 1)*$transVertexCnt;
			my $ind1 = 0; my $ind2 = 0; my $ind3 = $startIndPos;

			for(my $primN = 0 ; $primN < $transVertexCnt*2; $primN++) {
				## ���_�o�b�t�@�̃C���f�b�N�X�����߂�
				$ind1 = $ind2;
				$ind2 = $ind3;
				$ind3 = ($ind2 < $startIndPos + $transVertexCnt ?
					 		$ind2 + $transVertexCnt : $ind2 - $transVertexCnt + 1);
				$ind3 = 1 if ($primN == $transVertexCnt*2-1);

				## �N���b�s���O������s���B
				next if (GEO_IsClipping($vertexStream->[$ind1],
										$vertexStream->[$ind2],
										$vertexStream->[$ind3]));

				## �r���[�|�[�g�ϊ��E�v���Z���s���B
				## �s�N�Z����Ԃ��s���A�����_�����O�^�[�Q�b�g�T�[�t�F�X�ɑ΂��ď������ށB
				PXL_PixelShader($tSurface, $rs, PXL_VertexToPixel( GEO_ScaleToViewPort($matTranceformVP,
									$vertexStream->[$ind1], $vertexStream->[$ind2], $vertexStream->[$ind3])));
			}
		}

	## �x����]�g�[���X�^���b�V���̏ꍇ(MSH_CreateTorus�ɂ���č쐬���ꂽ�ꍇ)
	} elsif ($primitiveType eq 'D3DPT_MSH_TORUS') {

		for (my $i = 0; $i < $primitiveOption->[0]; $i++) {
			my $ind1 = 0;
			my $ind2 = $i * ($primitiveOption->[1] + 1);
			my $ind3 = $ind2 + $primitiveOption->[1] + 1;

			for ( my $j = 0; $j < $primitiveOption->[1] * 2; $j++) {

				## �v���~�e�B�u���擾���邽�߂̃C���f�b�N�X�����߂�B
				$ind1 = $ind2;
				$ind2 = $ind3;
				$ind3 = ( $ind2 < ($i + 1) * ($primitiveOption->[1] + 1) ?
											$ind2 + $primitiveOption->[1] + 1 : $ind2 - $primitiveOption->[1] );

				## �N���b�s���O������s���B
				next if (GEO_IsClipping($vertexStream->[$ind1],
										$vertexStream->[$ind2],
										$vertexStream->[$ind3]));

				## �r���[�|�[�g�ϊ��E�v���Z���s���B
				## �s�N�Z����Ԃ��s���A�����_�����O�^�[�Q�b�g�T�[�t�F�X�ɑ΂��ď������ށB
				PXL_PixelShader($tSurface, $rs, PXL_VertexToPixel( GEO_ScaleToViewPort($matTranceformVP,
										$vertexStream->[$ind1], $vertexStream->[$ind2], $vertexStream->[$ind3])));

			}
		}

	## ���ʋ�`���b�V���̏ꍇ(MSH_CreatePlaneRect�ɂ���č쐬���ꂽ�ꍇ)
	} elsif ($primitiveType eq 'D3DPT_MSH_PLANERECT') {

		for (my $i = 0; $i < $primitiveOption->[0]; $i++) {
			my $ind1 = 0;
			my $ind2 = $i * ($primitiveOption->[1] + 1);
			my $ind3 = $ind2 + $primitiveOption->[1] + 1;

			for ( my $j = 0; $j < $primitiveOption->[1] * 2; $j++) {

				## �v���~�e�B�u���擾���邽�߂̃C���f�b�N�X�����߂�B
				$ind1 = $ind2;
				$ind2 = $ind3;
				$ind3 = ( $ind2 < ($i + 1) * ($primitiveOption->[1] + 1) ?
											$ind2 + $primitiveOption->[1] + 1 : $ind2 - $primitiveOption->[1] );

				## �N���b�s���O������s���B
				next if (GEO_IsClipping($vertexStream->[$ind1],
										$vertexStream->[$ind2],
										$vertexStream->[$ind3]));

				## �r���[�|�[�g�ϊ��E�v���Z���s���B
				## �s�N�Z����Ԃ��s���A�����_�����O�^�[�Q�b�g�T�[�t�F�X�ɑ΂��ď������ށB
				PXL_PixelShader($tSurface, $rs, PXL_VertexToPixel( GEO_ScaleToViewPort($matTranceformVP,
										$vertexStream->[$ind1], $vertexStream->[$ind2], $vertexStream->[$ind3])));

			}
		}

	## �R�x�n�`�t���N�^�����b�V���̏ꍇ(MSH_CreateMountains�ɂ���č쐬���ꂽ�ꍇ)
	} elsif ($primitiveType eq 'D3DPT_MSH_MOUNTAINS') {
		for (my $i = 0; $i < $primitiveOption->[0]; $i++) {
			for ( my $j = 0; $j <= $i; $j++) {
				my $r1 = $i*($i+1)/2+$j;
				my $r2 = ($i+1)*($i+2)/2+$j;
				my $r3 = ($i+1)*($i+2)/2+$j+1;

				## TriangleB�̕`��
				if ($j > 0) {
					my $r4 = $i*($i+1)/2+$j-1;
					## �N���b�s���O������s���B
					next if (GEO_IsClipping($vertexStream->[$r4],
											$vertexStream->[$r2],
											$vertexStream->[$r1]));

					## �r���[�|�[�g�ϊ��E�v���Z���s���B
					## �s�N�Z����Ԃ��s���A�����_�����O�^�[�Q�b�g�T�[�t�F�X�ɑ΂��ď������ށB
					PXL_PixelShader($tSurface, $rs, PXL_VertexToPixel( GEO_ScaleToViewPort($matTranceformVP,
										$vertexStream->[$r4], $vertexStream->[$r2], $vertexStream->[$r1])));
				}

				## TriangleA�̕`��
				## �N���b�s���O������s���B
				next if (GEO_IsClipping($vertexStream->[$r1],
										$vertexStream->[$r2],
										$vertexStream->[$r3]));

				## �r���[�|�[�g�ϊ��E�v���Z���s���B
				## �s�N�Z����Ԃ��s���A�����_�����O�^�[�Q�b�g�T�[�t�F�X�ɑ΂��ď������ށB
				PXL_PixelShader($tSurface, $rs, PXL_VertexToPixel( GEO_ScaleToViewPort($matTranceformVP,
									$vertexStream->[$r1], $vertexStream->[$r2], $vertexStream->[$r3])));
			}
		}
	}

}


###
## ���C���[�t���[���Ƃ��ă����_�����O���s���B
##
## @param1 �����_�����O�^�[�Q�b�g�T�[�t�F�X
## @param2 �����_�����O�X�e�[�g�I�u�W�F�N�g
## @param3 �v���~�e�B�u�^�C�v
## @param4 ���_�o�b�t�@
## @param5 �I�v�V�����i�v���~�e�B�u�^�C�v�ɂ��p�r�͈قȂ�j
##
sub GEO_DrawPrimitiveLine {
	my ($tSurface, $rs, $primitiveType, $vertexBuffer, $primitiveOption) = @_;

	## �r���[�|�[�g�ϊ��s����쐬����B
	my $width2  = $#{$tSurface->[0]}/2;
	my $height2 = $#$tSurface/2;
	my $matTranceformVP = MAT_MMultiply(MAT_MScaling($width2, $height2, 1),
										MAT_MTranslate($width2, $height2, 0));

	## ���[���h X �r���[ X �ˉe X �r���[�|�[�g�ϊ� �����߂�B
	my $matWVPV = MAT_MMultiply( $rs->{"RS_TS_WORLD"},
								 $rs->{"RS_TS_VIEW"},
								 $rs->{"RS_TS_PROJECTION"},
								 $matTranceformVP);

	## �r���[�|�[�g�ϊ����s���B
	my @linesVer = map { VEC_Vec3TransformCoord($_->{"VECTOR"}, $matWVPV) } @$vertexBuffer;

	## �O�p�`���X�g�̏ꍇ
	if ($primitiveType eq 'D3DPT_TRIANGLELIST') {
		for ( my $i = 0; $i < $primitiveOption; $i++) {

			## �v���~�e�B�u���擾���邽�߂̃C���f�b�N�X�����߂�B
			my $ind1 = 0 + 3 * $i;
			my $ind2 = 1 + 3 * $i;
			my $ind3 = 2 + 3 * $i;

			## �N���b�s���O������s���B
			next if ($linesVer[$ind1]->[2] < 0 || $linesVer[$ind1]->[2] > 1 ||
					 $linesVer[$ind2]->[2] < 0 || $linesVer[$ind2]->[2] > 1 ||
					 $linesVer[$ind3]->[2] < 0 || $linesVer[$ind3]->[2] > 1 ||
					 $linesVer[$ind1]->[0] < 0 || $linesVer[$ind1]->[0] > $#{$tSurface->[0]} ||
					 $linesVer[$ind2]->[0] < 0 || $linesVer[$ind2]->[0] > $#{$tSurface->[0]} ||
					 $linesVer[$ind3]->[0] < 0 || $linesVer[$ind3]->[0] > $#{$tSurface->[0]} ||
					 $linesVer[$ind1]->[1] < 0 || $linesVer[$ind1]->[1] > $#$tSurface ||
					 $linesVer[$ind2]->[1] < 0 || $linesVer[$ind2]->[1] > $#$tSurface ||
					 $linesVer[$ind3]->[1] < 0 || $linesVer[$ind3]->[1] > $#$tSurface);

			## �O�p�`��`�悷��B
			PXL_PixelShaderLine($tSurface, $rs->{"RS_LINE_COLOR"},
								$linesVer[$ind1]->[0], $linesVer[$ind1]->[1],
								$linesVer[$ind2]->[0], $linesVer[$ind2]->[1]);
			PXL_PixelShaderLine($tSurface, $rs->{"RS_LINE_COLOR"},
								$linesVer[$ind2]->[0], $linesVer[$ind2]->[1],
								$linesVer[$ind3]->[0], $linesVer[$ind3]->[1]);
			PXL_PixelShaderLine($tSurface, $rs->{"RS_LINE_COLOR"},
								$linesVer[$ind3]->[0], $linesVer[$ind3]->[1],
								$linesVer[$ind1]->[0], $linesVer[$ind1]->[1]);
		}

	## �O�p�`�X�g���b�v�̏ꍇ
	} elsif ($primitiveType eq 'D3DPT_TRIANGLESTRIP') {
		for ( my $i = 0; $i < $primitiveOption; $i++) {

			## �v���~�e�B�u���擾���邽�߂̃C���f�b�N�X�����߂�B
			my $ind1 = 0 + $i;
			my $ind2 = 1 + $i;
			my $ind3 = 2 + $i;

			## �N���b�s���O������s���B
			next if ($linesVer[$ind1]->[2] < 0 || $linesVer[$ind1]->[2] > 1 ||
					 $linesVer[$ind2]->[2] < 0 || $linesVer[$ind2]->[2] > 1 ||
					 $linesVer[$ind3]->[2] < 0 || $linesVer[$ind3]->[2] > 1 ||
					 $linesVer[$ind1]->[0] < 0 || $linesVer[$ind1]->[0] > $#{$tSurface->[0]} ||
					 $linesVer[$ind2]->[0] < 0 || $linesVer[$ind2]->[0] > $#{$tSurface->[0]} ||
					 $linesVer[$ind3]->[0] < 0 || $linesVer[$ind3]->[0] > $#{$tSurface->[0]} ||
					 $linesVer[$ind1]->[1] < 0 || $linesVer[$ind1]->[1] > $#$tSurface ||
					 $linesVer[$ind2]->[1] < 0 || $linesVer[$ind2]->[1] > $#$tSurface ||
					 $linesVer[$ind3]->[1] < 0 || $linesVer[$ind3]->[1] > $#$tSurface);

			## �O�p�`��`�悷��B
			PXL_PixelShaderLine($tSurface, $rs->{"RS_LINE_COLOR"},
								$linesVer[$ind1]->[0], $linesVer[$ind1]->[1],
								$linesVer[$ind2]->[0], $linesVer[$ind2]->[1]);
			PXL_PixelShaderLine($tSurface, $rs->{"RS_LINE_COLOR"},
								$linesVer[$ind2]->[0], $linesVer[$ind2]->[1],
								$linesVer[$ind3]->[0], $linesVer[$ind3]->[1]);
			PXL_PixelShaderLine($tSurface, $rs->{"RS_LINE_COLOR"},
								$linesVer[$ind3]->[0], $linesVer[$ind3]->[1],
								$linesVer[$ind1]->[0], $linesVer[$ind1]->[1]);

		}

	## �x����]���b�V���̏ꍇ(MSH_CreateRotationY�ɂ���č쐬���ꂽ�ꍇ)
	} elsif ($primitiveType eq 'D3DPT_MSH_ROTATIONY') {

		my $transVertexCnt = $primitiveOption->[0];
		my $vertexListCnt = $primitiveOption->[1];

		for my $listNum (1..$vertexListCnt) {
			my $startIndPos = 2 + ($listNum - 1)*$transVertexCnt;
			my $ind1 = 0; my $ind2 = 0; my $ind3 = $startIndPos;

			for(my $primN = 0 ; $primN < $transVertexCnt*2; $primN++) {
				## ���_�o�b�t�@�̃C���f�b�N�X�����߂�
				$ind1 = $ind2;
				$ind2 = $ind3;
				$ind3 = ($ind2 < $startIndPos + $transVertexCnt ?
					 		$ind2 + $transVertexCnt : $ind2 - $transVertexCnt + 1);
				$ind3 = 1 if ($primN == $transVertexCnt*2-1);

				## �N���b�s���O������s���B
				next if ($linesVer[$ind1]->[2] < 0 || $linesVer[$ind1]->[2] > 1 ||
						 $linesVer[$ind2]->[2] < 0 || $linesVer[$ind2]->[2] > 1 ||
						 $linesVer[$ind3]->[2] < 0 || $linesVer[$ind3]->[2] > 1 ||
						 $linesVer[$ind1]->[0] < 0 || $linesVer[$ind1]->[0] > $#{$tSurface->[0]} ||
						 $linesVer[$ind2]->[0] < 0 || $linesVer[$ind2]->[0] > $#{$tSurface->[0]} ||
						 $linesVer[$ind3]->[0] < 0 || $linesVer[$ind3]->[0] > $#{$tSurface->[0]} ||
						 $linesVer[$ind1]->[1] < 0 || $linesVer[$ind1]->[1] > $#$tSurface ||
						 $linesVer[$ind2]->[1] < 0 || $linesVer[$ind2]->[1] > $#$tSurface ||
						 $linesVer[$ind3]->[1] < 0 || $linesVer[$ind3]->[1] > $#$tSurface);

				## �O�p�`��`�悷��B
				PXL_PixelShaderLine($tSurface, $rs->{"RS_LINE_COLOR"},
									$linesVer[$ind1]->[0], $linesVer[$ind1]->[1],
									$linesVer[$ind2]->[0], $linesVer[$ind2]->[1]);
				PXL_PixelShaderLine($tSurface, $rs->{"RS_LINE_COLOR"},
									$linesVer[$ind2]->[0], $linesVer[$ind2]->[1],
									$linesVer[$ind3]->[0], $linesVer[$ind3]->[1]);
				PXL_PixelShaderLine($tSurface, $rs->{"RS_LINE_COLOR"},
									$linesVer[$ind3]->[0], $linesVer[$ind3]->[1],
									$linesVer[$ind1]->[0], $linesVer[$ind1]->[1]);

			}
		}

	## �x����]�g�[���X�^���b�V���̏ꍇ(MSH_CreateTorus�ɂ���č쐬���ꂽ�ꍇ)
	} elsif ($primitiveType eq 'D3DPT_MSH_TORUS') {

		for (my $i = 0; $i < $primitiveOption->[0]; $i++) {
			my $ind1 = 0;
			my $ind2 = $i * ($primitiveOption->[1] + 1);
			my $ind3 = $ind2 + $primitiveOption->[1] + 1;

			for ( my $j = 0; $j < $primitiveOption->[1] * 2; $j++) {

				## �v���~�e�B�u���擾���邽�߂̃C���f�b�N�X�����߂�B
				$ind1 = $ind2;
				$ind2 = $ind3;
				$ind3 = ( $ind2 < ($i + 1) * ($primitiveOption->[1] + 1) ?
											$ind2 + $primitiveOption->[1] + 1 : $ind2 - $primitiveOption->[1] );

				## �N���b�s���O������s���B
				next if ($linesVer[$ind1]->[2] < 0 || $linesVer[$ind1]->[2] > 1 ||
						 $linesVer[$ind2]->[2] < 0 || $linesVer[$ind2]->[2] > 1 ||
						 $linesVer[$ind3]->[2] < 0 || $linesVer[$ind3]->[2] > 1 ||
						 $linesVer[$ind1]->[0] < 0 || $linesVer[$ind1]->[0] > $#{$tSurface->[0]} ||
						 $linesVer[$ind2]->[0] < 0 || $linesVer[$ind2]->[0] > $#{$tSurface->[0]} ||
						 $linesVer[$ind3]->[0] < 0 || $linesVer[$ind3]->[0] > $#{$tSurface->[0]} ||
						 $linesVer[$ind1]->[1] < 0 || $linesVer[$ind1]->[1] > $#$tSurface ||
						 $linesVer[$ind2]->[1] < 0 || $linesVer[$ind2]->[1] > $#$tSurface ||
						 $linesVer[$ind3]->[1] < 0 || $linesVer[$ind3]->[1] > $#$tSurface);

				## �O�p�`��`�悷��B
				PXL_PixelShaderLine($tSurface, $rs->{"RS_LINE_COLOR"},
									$linesVer[$ind1]->[0], $linesVer[$ind1]->[1],
									$linesVer[$ind2]->[0], $linesVer[$ind2]->[1]);
				PXL_PixelShaderLine($tSurface, $rs->{"RS_LINE_COLOR"},
									$linesVer[$ind2]->[0], $linesVer[$ind2]->[1],
									$linesVer[$ind3]->[0], $linesVer[$ind3]->[1]);
				PXL_PixelShaderLine($tSurface, $rs->{"RS_LINE_COLOR"},
									$linesVer[$ind3]->[0], $linesVer[$ind3]->[1],
									$linesVer[$ind1]->[0], $linesVer[$ind1]->[1]);

			}
		}

	## ���ʋ�`���b�V���̏ꍇ(MSH_CreatePlaneRect�ɂ���č쐬���ꂽ�ꍇ)
	} elsif ($primitiveType eq 'D3DPT_MSH_PLANERECT') {

		for (my $i = 0; $i < $primitiveOption->[0]; $i++) {
			my $ind1 = 0;
			my $ind2 = $i * ($primitiveOption->[1] + 1);
			my $ind3 = $ind2 + $primitiveOption->[1] + 1;

			for ( my $j = 0; $j < $primitiveOption->[1] * 2; $j++) {

				## �v���~�e�B�u���擾���邽�߂̃C���f�b�N�X�����߂�B
				$ind1 = $ind2;
				$ind2 = $ind3;
				$ind3 = ( $ind2 < ($i + 1) * ($primitiveOption->[1] + 1) ?
											$ind2 + $primitiveOption->[1] + 1 : $ind2 - $primitiveOption->[1] );

				## �N���b�s���O������s���B
				next if ($linesVer[$ind1]->[2] < 0 || $linesVer[$ind1]->[2] > 1 ||
						 $linesVer[$ind2]->[2] < 0 || $linesVer[$ind2]->[2] > 1 ||
						 $linesVer[$ind3]->[2] < 0 || $linesVer[$ind3]->[2] > 1 ||
						 $linesVer[$ind1]->[0] < 0 || $linesVer[$ind1]->[0] > $#{$tSurface->[0]} ||
						 $linesVer[$ind2]->[0] < 0 || $linesVer[$ind2]->[0] > $#{$tSurface->[0]} ||
						 $linesVer[$ind3]->[0] < 0 || $linesVer[$ind3]->[0] > $#{$tSurface->[0]} ||
						 $linesVer[$ind1]->[1] < 0 || $linesVer[$ind1]->[1] > $#$tSurface ||
						 $linesVer[$ind2]->[1] < 0 || $linesVer[$ind2]->[1] > $#$tSurface ||
						 $linesVer[$ind3]->[1] < 0 || $linesVer[$ind3]->[1] > $#$tSurface);

				## �O�p�`��`�悷��B
				PXL_PixelShaderLine($tSurface, $rs->{"RS_LINE_COLOR"},
									$linesVer[$ind1]->[0], $linesVer[$ind1]->[1],
									$linesVer[$ind2]->[0], $linesVer[$ind2]->[1]);
				PXL_PixelShaderLine($tSurface, $rs->{"RS_LINE_COLOR"},
									$linesVer[$ind2]->[0], $linesVer[$ind2]->[1],
									$linesVer[$ind3]->[0], $linesVer[$ind3]->[1]);
				PXL_PixelShaderLine($tSurface, $rs->{"RS_LINE_COLOR"},
									$linesVer[$ind3]->[0], $linesVer[$ind3]->[1],
									$linesVer[$ind1]->[0], $linesVer[$ind1]->[1]);
			}
		}

	## �R�x�n�`�t���N�^�����b�V���̏ꍇ(MSH_CreateMountains�ɂ���č쐬���ꂽ�ꍇ)
	} elsif ($primitiveType eq 'D3DPT_MSH_MOUNTAINS') {
		for (my $i = 0; $i < $primitiveOption->[0]; $i++) {
			for ( my $j = 0; $j <= $i; $j++) {
				my $r1 = $i*($i+1)/2+$j;
				my $r2 = ($i+1)*($i+2)/2+$j;
				my $r3 = ($i+1)*($i+2)/2+$j+1;

				## TriangleA�̕`��
				## �N���b�s���O������s���B
				next if ($linesVer[$r1]->[2] < 0 || $linesVer[$r1]->[2] > 1 ||
						 $linesVer[$r2]->[2] < 0 || $linesVer[$r2]->[2] > 1 ||
						 $linesVer[$r3]->[2] < 0 || $linesVer[$r3]->[2] > 1 ||
						 $linesVer[$r1]->[0] < 0 || $linesVer[$r1]->[0] > $#{$tSurface->[0]} ||
						 $linesVer[$r2]->[0] < 0 || $linesVer[$r2]->[0] > $#{$tSurface->[0]} ||
						 $linesVer[$r3]->[0] < 0 || $linesVer[$r3]->[0] > $#{$tSurface->[0]} ||
						 $linesVer[$r1]->[1] < 0 || $linesVer[$r1]->[1] > $#$tSurface ||
						 $linesVer[$r2]->[1] < 0 || $linesVer[$r2]->[1] > $#$tSurface ||
						 $linesVer[$r3]->[1] < 0 || $linesVer[$r3]->[1] > $#$tSurface);

				## �O�p�`��`�悷��B
				PXL_PixelShaderLine($tSurface, $rs->{"RS_LINE_COLOR"},
									$linesVer[$r1]->[0], $linesVer[$r1]->[1],
									$linesVer[$r2]->[0], $linesVer[$r2]->[1]);
				PXL_PixelShaderLine($tSurface, $rs->{"RS_LINE_COLOR"},
									$linesVer[$r2]->[0], $linesVer[$r2]->[1],
									$linesVer[$r3]->[0], $linesVer[$r3]->[1]);
				PXL_PixelShaderLine($tSurface, $rs->{"RS_LINE_COLOR"},
									$linesVer[$r3]->[0], $linesVer[$r3]->[1],
									$linesVer[$r1]->[0], $linesVer[$r1]->[1]);
			}
		}

	## ���X�g���b�v�̏ꍇ
	} elsif ($primitiveType eq 'D3DPT_LINESTRIP') {
		for ( my $i = 0; $i < $primitiveOption; $i++) {
			my $ind1 = $i;
			my $ind2 = $i+1;

			## �N���b�s���O������s���B
			next if ($linesVer[$ind1]->[2] < 0 || $linesVer[$ind1]->[2] > 1 ||
					 $linesVer[$ind2]->[2] < 0 || $linesVer[$ind2]->[2] > 1 ||
					 $linesVer[$ind1]->[0] < 0 || $linesVer[$ind1]->[0] > $#{$tSurface->[0]} ||
					 $linesVer[$ind2]->[0] < 0 || $linesVer[$ind2]->[0] > $#{$tSurface->[0]} ||
					 $linesVer[$ind1]->[1] < 0 || $linesVer[$ind1]->[1] > $#$tSurface ||
					 $linesVer[$ind2]->[1] < 0 || $linesVer[$ind2]->[1] > $#$tSurface);

			## ����`�悷��B
			PXL_PixelShaderLine($tSurface, $rs->{"RS_LINE_COLOR"},
								$linesVer[$ind1]->[0], $linesVer[$ind1]->[1],
								$linesVer[$ind2]->[0], $linesVer[$ind2]->[1]);
		}
	}

}


###
## �W�I���g���p�C�v���C��
##
sub GEO_PipeLine {
	my ($vertexBuffer, $rs) = @_;

	## ���[���h X �r���[ �s������߂�B
	my $matWV = MAT_MMultiply($rs->{"RS_TS_WORLD"}, $rs->{"RS_TS_VIEW"});
	## ���[���h X �r���[ X �ˉe �s������߂�B
	my $matWVP = MAT_MMultiply($rs->{"RS_TS_WORLD"}, $rs->{"RS_TS_VIEW"}, $rs->{"RS_TS_PROJECTION"});

	## ���_�o�b�t�@���̊e���_�ɂ��ď������s���B
	my $vertexStream = VTX_CreateVertexBuffer();
	for my $vtx (@{$vertexBuffer}) {

		## �J������Ԃł̒��_���W�E�@���x�N�g�������ꂼ�ꋁ�߂�B
		my $v = VEC_Vec3TransformCoord($vtx->{"VECTOR"}, $matWV);
		my $n = VEC_Vec3Normalize( VEC_Vec3TransformNormal($vtx->{"NORMAL"}, $matWV));

		## �ˉe�g�����X�t�H�[�����s���B�i�g�����X�t�H�[�������j
		## ���_�F�����߂�B(���C�e�B���O����)
		## ���_�t�H�[�}�b�g�� TRANSLITVERTEX �֕ϊ�����B
		## ���_�o�b�t�@�ɋl�ߍ��ށB
		VTX_PushVertex($vertexStream, VTX_MakeTransLitVertex( 
				VEC_Vec3Transform($vtx->{"VECTOR"}, $matWVP), LIT_Lighting($v, $n, $rs), $vtx->{'TEX'}));

	}

	return $vertexStream;
}


###
## �N���b�s���O���K�v�ȏꍇ��1�A����ȊO�� 0 ��Ԃ��B
##
## �P�̃v���~�e�B�u(�O�p�`)���`������R�̒��_�S�Ă�
## ���L�͈͊O�ɑ��݂��钸�_�̓N���b�s���O�ΏۂƂȂ�B
## -w <= x <= w
## -w <= y <= w
##  0 <= z <= w
##
sub GEO_IsClipping {
	my ($vertex1, $vertex2, $vertex3) = @_;

	## �e���_�̓����̒l���擾����B
	my $pw1 = $vertex1->{"VECTOR"}->[3];
	$pw1 *= -1 if ($pw1 < 0);
	my $pw2 = $vertex2->{"VECTOR"}->[3];
	$pw2 *= -1 if ($pw2 < 0);
	my $pw3 = $vertex3->{"VECTOR"}->[3];
	$pw3 *= -1 if ($pw3 < 0);

	## �N���b�s���O������s���B
	return 1 if ((($vertex1->{"VECTOR"}->[0] > $pw1) || ($vertex1->{"VECTOR"}->[0] < ($pw1)*(-1)) ||
				  ($vertex1->{"VECTOR"}->[1] > $pw1) || ($vertex1->{"VECTOR"}->[1] < ($pw1)*(-1)) ||
				  ($vertex1->{"VECTOR"}->[2] > $pw1) || ($vertex1->{"VECTOR"}->[2] < 0 ))  &&
				 (($vertex2->{"VECTOR"}->[0] > $pw2) || ($vertex2->{"VECTOR"}->[0] < ($pw2)*(-1)) ||
				  ($vertex2->{"VECTOR"}->[1] > $pw2) || ($vertex2->{"VECTOR"}->[1] < ($pw2)*(-1)) ||
				  ($vertex2->{"VECTOR"}->[2] > $pw2) || ($vertex2->{"VECTOR"}->[2] < 0 ))  &&
				 (($vertex3->{"VECTOR"}->[0] > $pw3) || ($vertex3->{"VECTOR"}->[0] < ($pw3)*(-1)) ||
				  ($vertex3->{"VECTOR"}->[1] > $pw3) || ($vertex3->{"VECTOR"}->[1] < ($pw3)*(-1)) ||
				  ($vertex3->{"VECTOR"}->[2] > $pw3) || ($vertex3->{"VECTOR"}->[2] < 0 )));

	return 0;

}


###
## �r���[�|�[�g�ϊ��E�v���Z���s���A
## ���_�t�H�[�}�b�g�� TRANSLITVERTEX �� VEWPORTVERTEX �֕ϊ�����B
##
sub GEO_ScaleToViewPort {
	my $mat = shift;

	my @list = @_;
	return map { my $vec = VEC_Vec4Transform($_->{"VECTOR"}, $mat);
				 $_ = VTX_MakeVewportVertex([$vec->[0]/$vec->[3], $vec->[1]/$vec->[3]],
				 $vec->[2]/$vec->[3], 1/$vec->[3], $_->{"DIFFUSE"}, $_->{"SPECULAR"}, $_->{"TEX"}); } @list;
}

1;
