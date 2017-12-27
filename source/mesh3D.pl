##_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
## Prefix Is MSH
##_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
use strict;
require '..\PY3D\vector3D.pl';
require '..\PY3D\matrix3D.pl';
require '..\PY3D\vertex3D.pl';


###
## XY����(2D)��X���̈��ɒ�`���ꂽ���_���X�g��
## Y���ŉ�]���������b�V�����쐬����B
## �n�_�A�I�_��Y����(x�v�f��0)�ł���K�v������B
## @param1 VECTOR2�z��  XY���ʏ��X���̈撸�_���W
## @param2 Deg          Y���̉�]����
##
sub MSH_CreateRotationY {
	my ($v2D, $angle) = @_;

	## ���_��2D->3D�ɕϊ�����B
	my ($startVertex, $endVertex);
	my $vertexBuff = VTX_CreateVertexBuffer();
	for (my $i = 0 ; $i <= $#$v2D ; $i++) {
		if ($i == 0) {
			$startVertex = VTX_MakeUnlitVertex( [$v2D->[$i]->[0], $v2D->[$i]->[1], 0], [0, 1,0]);
		} elsif ($i == $#$v2D) {
			$endVertex = VTX_MakeUnlitVertex( [$v2D->[$i]->[0], $v2D->[$i]->[1], 0], [0,-1,0]);
		} else {
			VTX_PushVertex( $vertexBuff, VTX_MakeUnlitVertex( [$v2D->[$i]->[0], $v2D->[$i]->[1], 0],
						[$v2D->[$i-1]->[1]-$v2D->[$i+1]->[1], $v2D->[$i+1]->[0]-$v2D->[$i-1]->[0], 0]));
		}
	}

	## Y���𒆐S�ɉ�]������B
	## for (my $cnt = 1 ; 360 > ($angle<0 ? (-1)*$angle*$cnt : $angle*$cnt) ; $cnt++) 
	my $cnt = 1;
	my $transVertexCnt = $#$vertexBuff;
	$angle = $angle < 0 ? $angle*(-1) : $angle;
	for ($cnt = 1 ; 360 > $angle*$cnt ; $cnt++) {
		my $m = MAT_MRotationY(MAT_DegToRad($angle*$cnt));
		for my $i (0..$transVertexCnt) {
			VTX_PushVertex( $vertexBuff, VTX_MakeUnlitVertex(
				VEC_Vec3TransformCoord($vertexBuff->[$i]->{"VECTOR"}, $m),
				VEC_Vec3TransformNormal($vertexBuff->[$i]->{"NORMAL"}, $m)));
		}
	}

	## �I�u�W�F�N�g�����
	for my $i (0..$transVertexCnt) {
		VTX_PushVertex( $vertexBuff, $vertexBuff->[$i]);
	}

	## �㒆�S�_�A�����S�_�𒸓_�o�b�t�@�ɒǉ�����B
	VTX_UnshiftVertex($vertexBuff,$endVertex);
	VTX_UnshiftVertex($vertexBuff,$startVertex);

	## ���_�o�b�t�@�A�v���~�e�B�u�^�C�v�A�I�v�V������ݒ肷��B
	return ($vertexBuff, 'D3DPT_MSH_ROTATIONY', [$transVertexCnt+1, $cnt]);
}


###
## XY����(2D)��X���̈��ɒ�`���ꂽ���_���X�g��
## Y���ŉ�]�������g�[���X�^�̃��b�V�����쐬����B
## �n�_�ƏI�_�����񂾕����}�`����]����
## @param1 VECTOR2�z��  XY���ʏ��X���̈撸�_���W
## @param2 Deg          Y���̉�]����
## @param3 �e�N�X�`�����W [[tu1, tv1],[tu2, tv2],[tu3, tv3]�E�E�E] 
##
sub MSH_CreateTorus {
	my ($v2D, $angle, $texV) = @_;

	## ���_��2D->3D�ɕϊ�����B
	my ($startVertex, $endVertex);
	my $vertexBuff = VTX_CreateVertexBuffer();
	for (my $i = 0 ; $i <= $#$v2D ; $i++) {
		if ($i == 0) {
			VTX_PushVertex( $vertexBuff, VTX_MakeUnlitVertex( [$v2D->[$i]->[0], $v2D->[$i]->[1], 0],
				[$v2D->[$#$v2D]->[1]-$v2D->[$i+1]->[1], $v2D->[$i+1]->[0]-$v2D->[$#$v2D]->[0], 0]));
		} elsif ($i == $#$v2D) {
			VTX_PushVertex( $vertexBuff, VTX_MakeUnlitVertex( [$v2D->[$i]->[0], $v2D->[$i]->[1], 0],
				[$v2D->[$i-1]->[1]-$v2D->[0]->[1], $v2D->[0]->[0]-$v2D->[$i-1]->[0], 0]));
		} else {
			VTX_PushVertex( $vertexBuff, VTX_MakeUnlitVertex( [$v2D->[$i]->[0], $v2D->[$i]->[1], 0],
				[$v2D->[$i-1]->[1]-$v2D->[$i+1]->[1], $v2D->[$i+1]->[0]-$v2D->[$i-1]->[0], 0]));
		}
	}

	## 2D�I�u�W�F�N�g�����
	VTX_PushVertex( $vertexBuff, VTX_MakeUnlitVertex( [$v2D->[0]->[0], $v2D->[0]->[1], 0],
		[$v2D->[$#$v2D]->[1]-$v2D->[1]->[1], $v2D->[1]->[0]-$v2D->[$#$v2D]->[0], 0]));

	## Y���𒆐S�ɉ�]������B
	## for (my $cnt = 1 ; 360 > ($angle<0 ? (-1)*$angle*$cnt : $angle*$cnt) ; $cnt++) 
	my $cnt = 1;
	my $transVertexCnt = $#$vertexBuff;
	$angle = $angle < 0 ? $angle*(-1) : $angle;
	for ($cnt = 1 ; 360 > $angle*$cnt ; $cnt++) {
		my $m = MAT_MRotationY(MAT_DegToRad($angle*$cnt));
		for my $i (0..$transVertexCnt) {
			VTX_PushVertex( $vertexBuff, VTX_MakeUnlitVertex(
				VEC_Vec3TransformCoord($vertexBuff->[$i]->{"VECTOR"}, $m),
				VEC_Vec3TransformNormal($vertexBuff->[$i]->{"NORMAL"}, $m)));
		}
	}

	## �I�u�W�F�N�g�����
	for my $i (0..$transVertexCnt) {
		VTX_PushVertex( $vertexBuff, $vertexBuff->[$i]);
	}

	## �e�N�X�`�������݂���ꍇ�̒��_�쐬
	if ($texV) {
		my $indexCounta = 0;
		for( my $i = 0; $i <= $cnt ; $i++) {
			for( my $j = 0; $j <= ($#$v2D+1) ; $j++) {
				my $tpX = $i / $cnt;
				my $tpY = $j / ($#$v2D+1);

				my @texBuff = ();
				map { push(@texBuff, [$tpX * $_->[0], $tpY * $_->[1]]) } @$texV;
				VTX_SetTexUnlitVertex($vertexBuff->[$indexCounta], [@texBuff]);
				$indexCounta++;
			}
		}
	}

	## ���_�o�b�t�@�A�v���~�e�B�u�^�C�v�A�I�v�V������ݒ肷��B
	return ($vertexBuff, 'D3DPT_MSH_TORUS', [$cnt, $#$v2D+1]);
}


###
## ���_[0,0,0] �������Ƃ��镽�ʋ�`���쐬����B
## ���_�@���x�N�g���́A�S��[0,0,-1]�Ƃ���B
##
## @param1 VECTOR2   ���ʋ�`�̉E�㒸�_���W (x > 0 ���� y > 0 �̓_)(Z������ 0 �Œ�)
## @param2 ��������  ���̃|���S��������(����)
## @param3 �c������  �c�̃|���S��������(����)
## @param4 �e�N�X�`�����W [[tu1, tv1],[tu2, tv2],[tu3, tv3]�E�E�E] 
##         �e�e�N�X�`���X�e�[�W�̕��ʋ�`�E����W
##         ( ���ʋ�`�������W�͑S�Ẵe�N�X�`���X�e�[�W�ɂ����� [0,0] �Œ�Ƃ���B)
##
sub MSH_CreatePlaneRect {
	my ($trVec, $xPch, $yPch, $texV) = @_;

	my $vertexBuff = VTX_CreateVertexBuffer();
	for( my $i = 0; $i <= $xPch ; $i++) {
		for( my $j = 0; $j <= $yPch ; $j++) {
			my $tpX = $i / $xPch;
			my $tpY = $j / $yPch;

			## �e�N�X�`�������݂���ꍇ
			if ($texV) {
				## my $ttY = ($yPch - $j) / $yPch;
				my @texBuff = ();
				## map { push(@texBuff, [$tpX * $_->[0], $ttY * $_->[1]]) } @$texV;
				map { push(@texBuff, [$tpX * $_->[0], $tpY * $_->[1]]) } @$texV;
				VTX_PushVertex( $vertexBuff,
					VTX_MakeUnlitVertex( [$tpX*$trVec->[0], $tpY*$trVec->[1], 0], [0, 0, -1], [@texBuff] ));

			## �e�N�X�`�������݂��Ȃ��ꍇ
			} else {
				VTX_PushVertex( $vertexBuff,
					VTX_MakeUnlitVertex( [$tpX*$trVec->[0], $tpY*$trVec->[1], 0], [0, 0, -1] ));
			}
		}
	}

	## ���_�o�b�t�@�A�v���~�e�B�u�^�C�v�A�I�v�V������ݒ肷��B
	return ($vertexBuff, 'D3DPT_MSH_PLANERECT', [$xPch, $yPch]);
}


###
## �Q�̒��_�o�b�t�@�̐��`��Ԃɂ��g�D�C�[�j���O�}�`��Ԃ��B
## �Q�̒��_�o�b�t�@�͈ȉ��̂S�̏����𖞂����K�v������B
##   �@  ���_�o�b�t�@�̒��_���������ł��邱�ƁB
##   �A  �v���~�e�B�u�^�C�v�������ł��邱�ƁB
##   �B  �I�v�V�����������ł��邱�ƁB
##   �C  �e�N�X�`���X�e�[�W������ł��邱�ƁB
##
## @param1 ���_�o�b�t�@�P�i�J�n�}�`�j
## @param2 ���_�o�b�t�@�Q�i�I���}�`�j
## @param3 �t���[�������R�}���i�P�ȏ�̐����j
## @param4 �擾�}�`�̃C���f�b�N�X�i [ 0 �` �t���[�������R�}�� ] �͈̔͂̐������w�� �j
##        �w 0 �x���w�肵���ꍇ�͒��_�o�b�t�@�P���A
##        �w�t���[�������R�}���x���w�肵���ꍇ�͒��_�o�b�t�@�Q�̃f�[�^�����̂܂ܕԂ��B
##
sub MSH_CreateTweening {
	my ($vertexBuff1, $vertexBuff2, $pich, $accessIndex) = @_;

	my $pers1 = $accessIndex / $pich;
	my $pers2 = 1 - $pers1;
	my $vertexBuff = VTX_CreateVertexBuffer();
	for my $i (0..$#$vertexBuff1) {
		## �e�N�X�`�������݂���ꍇ
		if ($vertexBuff1->[$i]->{"TEX"}) {
			## �e�N�X�`���X�e�[�W�P�ʂɐ��`��Ԃ��s���B
			my @texBuff = ();
			for my $j (0..$#{$vertexBuff1->[$i]->{"TEX"}}) {
				push(@texBuff, [ $vertexBuff1->[$i]->{"TEX"}->[$j]->[0] * $pers2 +
								 $vertexBuff2->[$i]->{"TEX"}->[$j]->[0] * $pers1,
								 $vertexBuff1->[$i]->{"TEX"}->[$j]->[1] * $pers2 +
								 $vertexBuff2->[$i]->{"TEX"}->[$j]->[1] * $pers1 ]);
			}
			## ���`��Ԃ��s���B
			VTX_PushVertex( $vertexBuff, VTX_MakeUnlitVertex(
			[ $vertexBuff1->[$i]->{"VECTOR"}->[0] * $pers2 + $vertexBuff2->[$i]->{"VECTOR"}->[0] * $pers1,
			  $vertexBuff1->[$i]->{"VECTOR"}->[1] * $pers2 + $vertexBuff2->[$i]->{"VECTOR"}->[1] * $pers1,
			  $vertexBuff1->[$i]->{"VECTOR"}->[2] * $pers2 + $vertexBuff2->[$i]->{"VECTOR"}->[2] * $pers1 ],
			[ $vertexBuff1->[$i]->{"NORMAL"}->[0] * $pers2 + $vertexBuff2->[$i]->{"NORMAL"}->[0] * $pers1,
			  $vertexBuff1->[$i]->{"NORMAL"}->[1] * $pers2 + $vertexBuff2->[$i]->{"NORMAL"}->[1] * $pers1,
			  $vertexBuff1->[$i]->{"NORMAL"}->[2] * $pers2 + $vertexBuff2->[$i]->{"NORMAL"}->[2] * $pers1 ],
			[ @texBuff ] ));

		## �e�N�X�`�������݂��Ȃ��ꍇ
		} else {
			## ���`��Ԃ��s���B
			VTX_PushVertex( $vertexBuff, VTX_MakeUnlitVertex(
			[ $vertexBuff1->[$i]->{"VECTOR"}->[0] * $pers2 + $vertexBuff2->[$i]->{"VECTOR"}->[0] * $pers1,
			  $vertexBuff1->[$i]->{"VECTOR"}->[1] * $pers2 + $vertexBuff2->[$i]->{"VECTOR"}->[1] * $pers1,
			  $vertexBuff1->[$i]->{"VECTOR"}->[2] * $pers2 + $vertexBuff2->[$i]->{"VECTOR"}->[2] * $pers1 ],
			[ $vertexBuff1->[$i]->{"NORMAL"}->[0] * $pers2 + $vertexBuff2->[$i]->{"NORMAL"}->[0] * $pers1,
			  $vertexBuff1->[$i]->{"NORMAL"}->[1] * $pers2 + $vertexBuff2->[$i]->{"NORMAL"}->[1] * $pers1,
			  $vertexBuff1->[$i]->{"NORMAL"}->[2] * $pers2 + $vertexBuff2->[$i]->{"NORMAL"}->[2] * $pers1 ] ));
		}
	}

	## ���_�o�b�t�@��ݒ肷��B
	return $vertexBuff;
}


###
## XY���ʏ�̃x�W�F�Ȑ����x���ŉ�]���������b�V�����쐬����B
##
## XY����(2D)��X���̈��ɒ�`���ꂽ���䒸�_���X�g����
## �x�W�F�Ȑ���XY���ʏ�ɕ`���B
## ����� Y���ŉ�]���������b�V�����쐬����B
## �n�_�A�I�_��Y����(x�v�f��0)�ł���K�v������B
##
## @param1 VECTOR2�z�� XY���ʏ��X���̈撸�_���W(�x�W�F�Ȑ��̐���_�z��)
## @param2 �Ȑ�������  �x�W�F�Ȑ��̕�����(����)
## @param3 Deg         Y���̉�]����
##
sub MSH_CreateBezierRotationY {
	my ($trVec, $pch, $angle) = @_;

	my $bezierBox = [];
	for(my $i = 0; $i <= $pch; $i++) {

		## ���_���o�b�t�@�ɓ���ւ���
		my @vertBuff = @$trVec;
		## ��Ԋ��������߂�B
		my $t = $i/$pch;

		## �Ȑ���̒��_�̍��W�����߂�B
		for (1..$#$trVec) {
			for(my $j = 0; $j < $#vertBuff; $j++) {
				## �e���_�v�f�ɂ��ĕ�Ԃ���
				$vertBuff[$j] = [ $vertBuff[$j]->[0] * (1 - $t) + $vertBuff[$j+1]->[0] * $t,
							  $vertBuff[$j]->[1] * (1 - $t) + $vertBuff[$j+1]->[1] * $t ];
			}
			pop(@vertBuff);
		}

		## ���߂��Ȑ���̓_���i�[����B
		push(@$bezierBox, $vertBuff[0]);
	}

	return MSH_CreateRotationY($bezierBox, $angle);

}


###
## �x�W�F�Ȑ����쐬����B
## 4�ȏ�̐���_����x�W�F�Ȑ���`���B
##
## @param1 VECTOR3�z��  [[x0,y0,z0],[x1,y1,z1],[x2,y2,z2],[x3,y3,z3]] ����_
## @param2 �Ȑ�������  �x�W�F�Ȑ��̕�����(����)
##
sub MSH_CreateBezierLine {
	my ($trVec, $pch) = @_;

	my $bezierBox = [];
	for(my $i = 0; $i <= $pch; $i++) {

		## ���_���o�b�t�@�ɓ���ւ���
		my @vertBuff = @$trVec;
		## ��Ԋ��������߂�B
		my $t = $i/$pch;

		## �Ȑ���̒��_�̍��W�����߂�B
		for (1..$#$trVec) {
			for(my $j = 0; $j < $#vertBuff; $j++) {
				## �e���_�v�f�ɂ��ĕ�Ԃ���
				$vertBuff[$j] = [ $vertBuff[$j]->[0] * (1 - $t) + $vertBuff[$j+1]->[0] * $t,
								  $vertBuff[$j]->[1] * (1 - $t) + $vertBuff[$j+1]->[1] * $t,
								  $vertBuff[$j]->[2] * (1 - $t) + $vertBuff[$j+1]->[2] * $t ];
			}
			pop(@vertBuff);
		}

		## ���߂��Ȑ���̓_���i�[����B
		push(@$bezierBox, $vertBuff[0]);
	}

	return $bezierBox;
}


###
## �x�W�F�Ȗʂ��쐬����B
##
## 4�ȏ�̃x�W�F�Ȑ���A���I�Ȑ���_�Ƃ��ăx�W�F�Ȗʂ�`���B
##
## @param1 VECTOR3�� n X m �s��  [[[x00,y00,z00],[x01,y01,z01],[x02,y02,z02],[x03,y03,z03]],
##								  [[x10,y10,z10],[x11,y11,z11],[x12,y12,z12],[x13,y13,z13]],
##								  [[x20,y20,z20],[x21,y21,z21],[x22,y22,z22],[x23,y23,z23]],
##								  [[x30,y30,z30],[x31,y31,z31],[x32,y32,z32],[x33,y33,z33]]]
##								i�s�ŕ\�����x�W�F�Ȑ��� m�񕪍쐬����B
##								�쐬���ꂽm�{�̃x�W�F�Ȑ��𐧌�_�Ƃ���x�W�F�Ȗʂ��쐬����B
## @param2 �Ȑ�������  ��P�i�K�ō쐬����x�W�F�Ȑ��̕�����(����)
## @param3 �Ȑ�������  ��Q�i�K�ō쐬����x�W�F�Ȑ��̕�����(����)
## @param4 �e�N�X�`�����W [[tu1, tv1],[tu2, tv2],[tu3, tv3]�E�E�E] 
##         �e�e�N�X�`���X�e�[�W�̕��ʋ�`�E����W
##         ( ���ʋ�`�������W�͑S�Ẵe�N�X�`���X�e�[�W�ɂ����� [0,0] �Œ�Ƃ���B)
##
sub MSH_CreateBezierPlane {
	my ($trVec, $xPch, $yPch, $texV) = @_;

	## ��P�i�K�x�W�F�Ȑ������߂�B
	my @bezierBox = ();
	for(my $bCnt = 0; $bCnt <= $#$trVec; $bCnt++) {
		$bezierBox[$bCnt] = [];
		for(my $i = 0; $i <= $xPch; $i++) {

			## ���_���o�b�t�@�ɓ���ւ���
			my @vertBuff = @{$trVec->[$bCnt]};
			## ��Ԋ��������߂�B
			my $t = $i/$xPch;

			## �Ȑ���̒��_�̍��W�����߂�B
			for (1..$#{$trVec->[$bCnt]}) {
				for(my $j = 0; $j < $#vertBuff; $j++) {
					## �e���_�v�f�ɂ��ĕ�Ԃ���
					$vertBuff[$j] = [ $vertBuff[$j]->[0] * (1 - $t) + $vertBuff[$j+1]->[0] * $t,
									  $vertBuff[$j]->[1] * (1 - $t) + $vertBuff[$j+1]->[1] * $t,
									  $vertBuff[$j]->[2] * (1 - $t) + $vertBuff[$j+1]->[2] * $t];
				}
				pop(@vertBuff);
			}

			## ���߂��Ȑ���̓_���i�[����B
			push(@{$bezierBox[$bCnt]}, $vertBuff[0]);
		}
	}

	## ��Q�i�K�x�W�F�Ȑ������߂�
	my @bezier2Box = ();
	my @normalBox = ();
	for(my $b2Cnt = 0; $b2Cnt <= $xPch; $b2Cnt++) {
		for(my $i = 0; $i <= $yPch; $i++) {

			## ���_���o�b�t�@�ɓ���ւ���
			my @vertBuff = ();
			map { push(@vertBuff, $_->[$b2Cnt]) } @bezierBox;

			## ��Ԋ��������߂�B
			my $t = $i/$yPch;

			## �Ȑ���̒��_�̍��W�����߂�B
			for (1..$#bezierBox) {
				for(my $j = 0; $j < $#vertBuff; $j++) {
					## �e���_�v�f�ɂ��ĕ�Ԃ���
					$vertBuff[$j] = [ $vertBuff[$j]->[0] * (1 - $t) + $vertBuff[$j+1]->[0] * $t,
									  $vertBuff[$j]->[1] * (1 - $t) + $vertBuff[$j+1]->[1] * $t,
									  $vertBuff[$j]->[2] * (1 - $t) + $vertBuff[$j+1]->[2] * $t];
				}
				pop(@vertBuff);
			}

			## ���߂��Ȑ���̓_���i�[����B(���̂Ƃ��Ή��@���x�N�g�������������Ă���)
			push(@bezier2Box, $vertBuff[0]);
			push(@normalBox, [0,0,0]);
		}
	}

	## �e���_�̖@���x�N�g�������߂�
	for (my $i = 0; $i < $xPch; $i++) {
		my $ind1 = 0;
		my $ind2 = $i * ($yPch + 1);
		my $ind3 = $ind2 + $yPch + 1;

		for ( my $j = 0; $j < $yPch * 2; $j++) {
			## �v���~�e�B�u���擾���邽�߂̃C���f�b�N�X�����߂�B
			$ind1 = $ind2;
			$ind2 = $ind3;
			$ind3 = ( $ind2 < ($i + 1) * ($yPch + 1) ? $ind2 + $yPch + 1 : $ind2 - $yPch );

			## �O�p�`�̖@���x�N�g�������߂�
			my $vAx = $bezier2Box[$ind1]->[0] - $bezier2Box[$ind2]->[0];
			my $vAy = $bezier2Box[$ind1]->[1] - $bezier2Box[$ind2]->[1];
			my $vAz = $bezier2Box[$ind1]->[2] - $bezier2Box[$ind2]->[2];

			my $vBx = $bezier2Box[$ind3]->[0] - $bezier2Box[$ind2]->[0];
			my $vBy = $bezier2Box[$ind3]->[1] - $bezier2Box[$ind2]->[1];
			my $vBz = $bezier2Box[$ind3]->[2] - $bezier2Box[$ind2]->[2];

			## �O�ς����߂�
			my $cVx = $vAy * $vBz - $vAz * $vBy;
			my $cVy = $vAz * $vBx - $vAx * $vBz;
			my $cVz = $vAx * $vBy - $vAy * $vBx;

			## ���K������
			my $len = sqrt($cVx**2 + $cVy**2 + $cVz**2);
			$cVx = $cVx / $len;
			$cVy = $cVy / $len;
			$cVz = $cVz / $len;

			## �@���x�N�g�����O�p�`�̏������钸�_�ɑ�������
			if ( $j % 2 == 1 ) {
				$normalBox[$ind1]->[0] += $cVx;
				$normalBox[$ind1]->[1] += $cVy;
				$normalBox[$ind1]->[2] += $cVz;
				$normalBox[$ind2]->[0] += $cVx;
				$normalBox[$ind2]->[1] += $cVy;
				$normalBox[$ind2]->[2] += $cVz;
				$normalBox[$ind3]->[0] += $cVx;
				$normalBox[$ind3]->[1] += $cVy;
				$normalBox[$ind3]->[2] += $cVz;
			} else {
				$normalBox[$ind1]->[0] -= $cVx;
				$normalBox[$ind1]->[1] -= $cVy;
				$normalBox[$ind1]->[2] -= $cVz;
				$normalBox[$ind2]->[0] -= $cVx;
				$normalBox[$ind2]->[1] -= $cVy;
				$normalBox[$ind2]->[2] -= $cVz;
				$normalBox[$ind3]->[0] -= $cVx;
				$normalBox[$ind3]->[1] -= $cVy;
				$normalBox[$ind3]->[2] -= $cVz;
			}

		}
	}

	my $vertexBuff = VTX_CreateVertexBuffer();
	## �e�N�X�`�������݂���ꍇ�̒��_�쐬
	if ($texV) {
		my $indexCounta = 0;
		for( my $i = 0; $i <= $xPch ; $i++) {
			for( my $j = 0; $j <= $yPch ; $j++) {
				my $tpX = $i / $xPch;
				my $tpY = $j / $yPch;

				my @texBuff = ();
				map { push(@texBuff, [$tpX * $_->[0], $tpY * $_->[1]]) } @$texV;
				VTX_PushVertex( $vertexBuff,
					VTX_MakeUnlitVertex( $bezier2Box[$indexCounta], $normalBox[$indexCounta], [@texBuff] ));
				$indexCounta++;
			}
		}

	## �e�N�X�`�������݂��Ȃ��ꍇ�̒��_�쐬
	} else {
		for my $i (0..$#bezier2Box) {
			VTX_PushVertex( $vertexBuff, VTX_MakeUnlitVertex( $bezier2Box[$i], $normalBox[$i]));
		}
	}

	## ���_�o�b�t�@�A�v���~�e�B�u�^�C�v�A�I�v�V������ݒ肷��B
	return ($vertexBuff, 'D3DPT_MSH_PLANERECT', [$xPch, $yPch]);

}


####
## �t���N�^���ȎR�x�n�`���쐬����B
## �o�b�t�@�̐�����n�����߂�B
##
sub MSH_CreateMountains {
	my ($vBuff) = @_;

	## �o�b�t�@�̗v�f�����猻�݂� n �����߂�B�A���An=1,2,3,4�`
	my $En = $#$vBuff + 1;
	my ($n, $Dn);
	for($n = 1; $n < 100 ; $n++) {
		$Dn = 2**($n-1);
		last if ($En == ($Dn+1)*($Dn+2)/2);
	}

	## ����ȏ�̍ו����͕s�\�Ȃ̂ŏI��
	return if ($n >= 100);

	## VECTOR�i�[�p�z��
	my @wBuff = ();
	for(my $i=0; $i<$Dn ;$i++) {
		for(my $j=0; $j<=$i ;$j++) {
			my $r1 = $i*($i+1)/2+$j;
			my $r2 = ($i+1)*($i+2)/2+$j;
			my $r3 = ($i+1)*($i+2)/2+$j+1;
			my $s1 = $i*(2*$i+1)+2*$j;
			my $s2 = ($i+1)*(2*$i+3)+2*$j;
			my $s3 = ($i+1)*(2*$i+3)+2*$j+2;
			my $s4 = ($i+1)*(2*$i+1)+2*$j;
			my $s5 = ($i+1)*(2*$i+1)+2*$j+1;
			my $s6 = ($i+1)*(2*$i+3)+2*$j+1;
			$wBuff[$s1] = $vBuff->[$r1]->{"VECTOR"};
			$wBuff[$s2] = $vBuff->[$r2]->{"VECTOR"};
			$wBuff[$s3] = $vBuff->[$r3]->{"VECTOR"};

			## �O�p�`�̖@���x�N�g�������߂�B(Y���ɑΉ�)
			my ($nX, $nY, $nZ) = triangleNorm($wBuff[$s1], $wBuff[$s2], $wBuff[$s3]);
			## �O�p�`�̕ӂ�\���x�N�g�����擾����B(Z���ɑΉ�)
			my $vR1R2 = VEC_Vec3Normalize(VEC_Vec3Subtract($wBuff[$s2], $wBuff[$s1]));
			my $vR2R3 = VEC_Vec3Normalize(VEC_Vec3Subtract($wBuff[$s3], $wBuff[$s2]));
			my $vR3R1 = VEC_Vec3Normalize(VEC_Vec3Subtract($wBuff[$s1], $wBuff[$s3]));
			## �@���x�N�g���ƕӃx�N�g���̊O�ς����߂�B(X���ɑΉ�)
			my $cR1R2 = VEC_Vec3Normalize(VEC_Vec3Cross([$nX, $nY, $nZ], $vR1R2));
			my $cR2R3 = VEC_Vec3Normalize(VEC_Vec3Cross([$nX, $nY, $nZ], $vR2R3));
			my $cR3R1 = VEC_Vec3Normalize(VEC_Vec3Cross([$nX, $nY, $nZ], $vR3R1));
			## �e�ӂ̒��_�����߂�B
			my $mR1R2 = VEC_Vec3Scale(VEC_Vec3Add($vBuff->[$r1]->{"VECTOR"}, $vBuff->[$r2]->{"VECTOR"}), 0.5);
			my $mR2R3 = VEC_Vec3Scale(VEC_Vec3Add($vBuff->[$r1]->{"VECTOR"}, $vBuff->[$r3]->{"VECTOR"}), 0.5);
			my $mR3R1 = VEC_Vec3Scale(VEC_Vec3Add($vBuff->[$r2]->{"VECTOR"}, $vBuff->[$r3]->{"VECTOR"}), 0.5);
			## �ϊ��s������߂�B
			my $matR1R2 =  [[$cR1R2->[0], $cR1R2->[1], $cR1R2->[2], 0.0], [$nX, $nY, $nZ, 0.0],
							[$vR1R2->[0], $vR1R2->[1], $vR1R2->[2], 0.0], [$mR1R2->[0], $mR1R2->[1], $mR1R2->[2], 1.0]];
			my $matR2R3 =  [[$cR2R3->[0], $cR2R3->[1], $cR2R3->[2], 0.0], [$nX, $nY, $nZ, 0.0],
							[$vR2R3->[0], $vR2R3->[1], $vR2R3->[2], 0.0], [$mR2R3->[0], $mR2R3->[1], $mR2R3->[2], 1.0]];
			my $matR3R1 =  [[$cR3R1->[0], $cR3R1->[1], $cR3R1->[2], 0.0], [$nX, $nY, $nZ, 0.0],
							[$vR3R1->[0], $vR3R1->[1], $vR3R1->[2], 0.0], [$mR3R1->[0], $mR3R1->[1], $mR3R1->[2], 1.0]];
			## �e�ӂ̒��������߂�B
			my $lenR1R2 = VEC_Vec3Length(VEC_Vec3Subtract($wBuff[$s2], $wBuff[$s1]));
			my $lenR2R3 = VEC_Vec3Length(VEC_Vec3Subtract($wBuff[$s3], $wBuff[$s2]));
			my $lenR3R1 = VEC_Vec3Length(VEC_Vec3Subtract($wBuff[$s1], $wBuff[$s3]));

			## �����_���Ȋp�x���擾����B
			my $jigen = 2.08;
			my $tbt = (($lenR1R2**2)*(2**((-1)*(4/$jigen))-2**((-1)*2)))**(1/2);
			my $rad1 = MAT_DegToRad(rand(360));
			## my $rad1 = MAT_DegToRad(40);
			my $x11 = $tbt * sin($rad1);
			my $y11 = $tbt * cos($rad1);
			my $rad2 = MAT_DegToRad(rand(360));
			## my $rad2 = MAT_DegToRad(40);
			my $x22 = $tbt * sin($rad2);
			my $y22 = $tbt * cos($rad2);
			my $rad3 = MAT_DegToRad(rand(360));
			## my $rad3 = MAT_DegToRad(40);
			my $x33 = $tbt * sin($rad3);
			my $y33 = $tbt * cos($rad3);
			$wBuff[$s4] = VEC_Vec3TransformCoord([$x11,$y11,0], $matR1R2);
			$wBuff[$s5] = VEC_Vec3TransformCoord([$x22,$y22,0], $matR2R3);
			$wBuff[$s6] = VEC_Vec3TransformCoord([$x33,$y33,0], $matR3R1);
		}
	}

	## �@���x�N�g���i�[�p�o�b�t�@�̏�����
	my @wNormBuff = ();
	for(0..$#wBuff){
		push(@wNormBuff, [0,0,0]);
	}

	## �@���x�N�g�������߂�B
	my $Dn1 = 2*$Dn;
	for(my $i=0; $i<$Dn1 ;$i++) {
		for(my $j=0; $j<=$i ;$j++) {
			my $r1 = $i*($i+1)/2+$j;
			my $r2 = ($i+1)*($i+2)/2+$j;
			my $r3 = ($i+1)*($i+2)/2+$j+1;

			## TriangleB�̖@�������߂�B
			if ($j > 0) {
				my $r4 = $i*($i+1)/2+$j-1;
				my ($nX,$nY,$nZ) = triangleNorm($wBuff[$r4], $wBuff[$r2], $wBuff[$r1]);
				$wNormBuff[$r4]->[0] += $nX;
				$wNormBuff[$r4]->[1] += $nY;
				$wNormBuff[$r4]->[2] += $nZ;
				$wNormBuff[$r2]->[0] += $nX;
				$wNormBuff[$r2]->[1] += $nY;
				$wNormBuff[$r2]->[2] += $nZ;
				$wNormBuff[$r1]->[0] += $nX;
				$wNormBuff[$r1]->[1] += $nY;
				$wNormBuff[$r1]->[2] += $nZ;

			}

			## TriangleA�̖@�������߂�B
			my ($nX,$nY,$nZ) = triangleNorm($wBuff[$r1], $wBuff[$r2], $wBuff[$r3]);
			$wNormBuff[$r1]->[0] += $nX;
			$wNormBuff[$r1]->[1] += $nY;
			$wNormBuff[$r1]->[2] += $nZ;
			$wNormBuff[$r2]->[0] += $nX;
			$wNormBuff[$r2]->[1] += $nY;
			$wNormBuff[$r2]->[2] += $nZ;
			$wNormBuff[$r3]->[0] += $nX;
			$wNormBuff[$r3]->[1] += $nY;
			$wNormBuff[$r3]->[2] += $nZ;

		}
	}

	my $vertexBuff = VTX_CreateVertexBuffer();
	## �e�N�X�`�������݂��Ȃ��ꍇ�̒��_�쐬
	for my $i (0..$#wBuff) {
		VTX_PushVertex( $vertexBuff, VTX_MakeUnlitVertex( $wBuff[$i], $wNormBuff[$i]));
	}

	## ���_�o�b�t�@�A�v���~�e�B�u�^�C�v�A�I�v�V������ݒ肷��B
	return ($vertexBuff, 'D3DPT_MSH_MOUNTAINS', [$Dn1]);

}



####
## �t���N�^���ȎR�x�n�`���쐬����B
## �o�b�t�@�̐�����n�����߂�B
##
sub MSH_CreateMountainsLast {
	my ($vBuff) = @_;

	## �o�b�t�@�̗v�f�����猻�݂� n �����߂�B�A���An=1,2,3,4�`
	my $En = $#$vBuff + 1;
	my ($n, $Dn);
	for($n = 1; $n < 100 ; $n++) {
		$Dn = 2**($n-1);
		last if ($En == ($Dn+1)*($Dn+2)/2);
	}

	## ����ȏ�̍ו����͕s�\�Ȃ̂ŏI��
	return if ($n >= 100);

	## VECTOR�i�[�p�z��
	my @wBuff = ();
	for(my $i=0; $i<$Dn ;$i++) {
		for(my $j=0; $j<=$i ;$j++) {
			my $r1 = $i*($i+1)/2+$j;
			my $r2 = ($i+1)*($i+2)/2+$j;
			my $r3 = ($i+1)*($i+2)/2+$j+1;
			my $s1 = $i*(2*$i+1)+2*$j;
			my $s2 = ($i+1)*(2*$i+3)+2*$j;
			my $s3 = ($i+1)*(2*$i+3)+2*$j+2;
			my $s4 = ($i+1)*(2*$i+1)+2*$j;
			my $s5 = ($i+1)*(2*$i+1)+2*$j+1;
			my $s6 = ($i+1)*(2*$i+3)+2*$j+1;
			$wBuff[$s1] = $vBuff->[$r1]->{"VECTOR"};
			$wBuff[$s2] = $vBuff->[$r2]->{"VECTOR"};
			$wBuff[$s3] = $vBuff->[$r3]->{"VECTOR"};

			## �O�p�`�̖@���x�N�g�������߂�B(Y���ɑΉ�)
			my ($nX, $nY, $nZ) = triangleNorm($wBuff[$s1], $wBuff[$s2], $wBuff[$s3]);
			## �O�p�`�̕ӂ�\���x�N�g�����擾����B(Z���ɑΉ�)
			my $vR1R2 = VEC_Vec3Normalize(VEC_Vec3Subtract($wBuff[$s2], $wBuff[$s1]));
			my $vR2R3 = VEC_Vec3Normalize(VEC_Vec3Subtract($wBuff[$s3], $wBuff[$s2]));
			my $vR3R1 = VEC_Vec3Normalize(VEC_Vec3Subtract($wBuff[$s1], $wBuff[$s3]));
			## �@���x�N�g���ƕӃx�N�g���̊O�ς����߂�B(X���ɑΉ�)
			my $cR1R2 = VEC_Vec3Normalize(VEC_Vec3Cross([$nX, $nY, $nZ], $vR1R2));
			my $cR2R3 = VEC_Vec3Normalize(VEC_Vec3Cross([$nX, $nY, $nZ], $vR2R3));
			my $cR3R1 = VEC_Vec3Normalize(VEC_Vec3Cross([$nX, $nY, $nZ], $vR3R1));
			## �e�ӂ̒��_�����߂�B
			my $mR1R2 = VEC_Vec3Scale(VEC_Vec3Add($vBuff->[$r1]->{"VECTOR"}, $vBuff->[$r2]->{"VECTOR"}), 0.5);
			my $mR2R3 = VEC_Vec3Scale(VEC_Vec3Add($vBuff->[$r1]->{"VECTOR"}, $vBuff->[$r3]->{"VECTOR"}), 0.5);
			my $mR3R1 = VEC_Vec3Scale(VEC_Vec3Add($vBuff->[$r2]->{"VECTOR"}, $vBuff->[$r3]->{"VECTOR"}), 0.5);
			## �ϊ��s������߂�B
			my $matR1R2 =  [[$cR1R2->[0], $cR1R2->[1], $cR1R2->[2], 0.0], [$nX, $nY, $nZ, 0.0],
							[$vR1R2->[0], $vR1R2->[1], $vR1R2->[2], 0.0], [$mR1R2->[0], $mR1R2->[1], $mR1R2->[2], 1.0]];
			my $matR2R3 =  [[$cR2R3->[0], $cR2R3->[1], $cR2R3->[2], 0.0], [$nX, $nY, $nZ, 0.0],
							[$vR2R3->[0], $vR2R3->[1], $vR2R3->[2], 0.0], [$mR2R3->[0], $mR2R3->[1], $mR2R3->[2], 1.0]];
			my $matR3R1 =  [[$cR3R1->[0], $cR3R1->[1], $cR3R1->[2], 0.0], [$nX, $nY, $nZ, 0.0],
							[$vR3R1->[0], $vR3R1->[1], $vR3R1->[2], 0.0], [$mR3R1->[0], $mR3R1->[1], $mR3R1->[2], 1.0]];
			## �e�ӂ̒��������߂�B
			my $lenR1R2 = VEC_Vec3Length(VEC_Vec3Subtract($wBuff[$s2], $wBuff[$s1]));
			my $lenR2R3 = VEC_Vec3Length(VEC_Vec3Subtract($wBuff[$s3], $wBuff[$s2]));
			my $lenR3R1 = VEC_Vec3Length(VEC_Vec3Subtract($wBuff[$s1], $wBuff[$s3]));

			## �����_���Ȋp�x���擾����B
			my $jigen = 2.08;
			my $tbt = (($lenR1R2**2)*(2**((-1)*(4/$jigen))-2**((-1)*2)))**(1/2);
			my $rad1 = MAT_DegToRad(rand(360));
			## my $rad1 = MAT_DegToRad(40);
			my $x11 = $tbt * sin($rad1);
			my $y11 = $tbt * cos($rad1);
			my $rad2 = MAT_DegToRad(rand(360));
			## my $rad2 = MAT_DegToRad(40);
			my $x22 = $tbt * sin($rad2);
			my $y22 = $tbt * cos($rad2);
			my $rad3 = MAT_DegToRad(rand(360));
			## my $rad3 = MAT_DegToRad(40);
			my $x33 = $tbt * sin($rad3);
			my $y33 = $tbt * cos($rad3);
			$wBuff[$s4] = VEC_Vec3TransformCoord([$x11,$y11,0], $matR1R2);
			$wBuff[$s5] = VEC_Vec3TransformCoord([$x22,$y22,0], $matR2R3);
			$wBuff[$s6] = VEC_Vec3TransformCoord([$x33,$y33,0], $matR3R1);
		}
	}

	my $primCnt = 0;
	my $vertexBuff = VTX_CreateVertexBuffer();
	## �@���x�N�g�������߂�B
	my $Dn1 = 2*$Dn;
	for(my $i=0; $i<$Dn1 ;$i++) {
		for(my $j=0; $j<=$i ;$j++) {
			my $r1 = $i*($i+1)/2+$j;
			my $r2 = ($i+1)*($i+2)/2+$j;
			my $r3 = ($i+1)*($i+2)/2+$j+1;

			## TriangleB�̖@�������߂�B
			if ($j > 0) {
				my $r4 = $i*($i+1)/2+$j-1;
				my ($nX,$nY,$nZ) = triangleNorm($wBuff[$r4], $wBuff[$r2], $wBuff[$r1]);
				VTX_PushVertex( $vertexBuff, VTX_MakeUnlitVertex( [@{$wBuff[$r4]}], [$nX, $nY, $nZ]));
				VTX_PushVertex( $vertexBuff, VTX_MakeUnlitVertex( [@{$wBuff[$r2]}], [$nX, $nY, $nZ]));
				VTX_PushVertex( $vertexBuff, VTX_MakeUnlitVertex( [@{$wBuff[$r1]}], [$nX, $nY, $nZ]));
				$primCnt++;
			}

			## TriangleA�̖@�������߂�B
			my ($nX,$nY,$nZ) = triangleNorm($wBuff[$r1], $wBuff[$r2], $wBuff[$r3]);
			VTX_PushVertex( $vertexBuff, VTX_MakeUnlitVertex( [@{$wBuff[$r1]}], [$nX, $nY, $nZ]));
			VTX_PushVertex( $vertexBuff, VTX_MakeUnlitVertex( [@{$wBuff[$r2]}], [$nX, $nY, $nZ]));
			VTX_PushVertex( $vertexBuff, VTX_MakeUnlitVertex( [@{$wBuff[$r3]}], [$nX, $nY, $nZ]));
			$primCnt++;
		}
	}

	return ($vertexBuff, 'D3DPT_TRIANGLELIST' ,$primCnt);
}



####
##
## �O�p�`ABC�̖@���x�N�g�������߂�B
## @param1 VECTOR3 �_A
## @param2 VECTOR3 �_B
## @param3 VECTOR3 �_C
##
sub triangleNorm {
	my ($vA, $vB, $vC) = @_;

	## �O�p�`�̖@���x�N�g�������߂�
	my $vABx = $vC->[0] - $vA->[0];
	my $vABy = $vC->[1] - $vA->[1];
	my $vABz = $vC->[2] - $vA->[2];
	my $vACx = $vB->[0] - $vA->[0];
	my $vACy = $vB->[1] - $vA->[1];
	my $vACz = $vB->[2] - $vA->[2];

	## �O�ς����߂�
	my $vNx = $vABy * $vACz - $vABz * $vACy;
	my $vNy = $vABz * $vACx - $vABx * $vACz;
	my $vNz = $vABx * $vACy - $vABy * $vACx;

	## ���K������
	my $len = sqrt($vNx**2 + $vNy**2 + $vNz**2);
	return ($vNx/$len, $vNy/$len, $vNz/$len);

}

1;

