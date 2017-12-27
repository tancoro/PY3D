##_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
## Prefix Is VEC
##_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
use strict;


###########################################################
## �x�N�g����`
##�y�P�z2D�x�N�g��
##    �� : VECTOR2
##    �^ : [x, y]
##
##�y�Q�z3D�x�N�g��
##    �� : VECTOR3
##    �^ : [x, y, z]
##
##�y�R�z4D�x�N�g��
##    �� : VECTOR4
##    �^ : [x, y, z, w]
###########################################################


##
## VECTOR2���쐬����
## @param1 X�l
## @param2 Y�l
##
sub VEC_ToVector2 {
	my ($x, $y) = @_;
	return [$x, $y];
}

##
## VECTOR3���쐬����
## @param1 X�l
## @param2 Y�l
## @param3 Z�l
##
sub VEC_ToVector3 {
	my ($x, $y, $z) = @_;
	return [$x, $y, $z];
}

##
## VECTOR4���쐬����
## @param1 X�l
## @param2 Y�l
## @param3 Z�l
## @param4 W�l
##
sub VEC_ToVector4 {
	my ($x, $y, $z, $w) = @_;
	return [$x, $y, $z, $w];
}

##
## VECTOR2�̒��������߂�
##
sub VEC_Vec2Length {
	my ($v) = @_;
	return sqrt($v->[0]**2+$v->[1]**2);
}

##
## VECTOR3�̒��������߂�
##
sub VEC_Vec3Length {
	my ($v) = @_;
	return sqrt($v->[0]**2+$v->[1]**2+$v->[2]**2);
}

##
## VECTOR4�̒��������߂�
##
sub VEC_Vec4Length {
	my ($v) = @_;
	return sqrt($v->[0]**2+$v->[1]**2+$v->[2]**2+$v->[3]**2);
}

##
## VECTOR2�̐��K�������x�N�g����Ԃ�
##
sub VEC_Vec2Normalize {
	my ($v) = @_;

	my $len = sqrt($v->[0]**2+$v->[1]**2);
	return ([$v->[0]/$len, $v->[1]/$len]);
}

##
## VECTOR3�̐��K�������x�N�g����Ԃ�
##
sub VEC_Vec3Normalize {
	my ($v) = @_;

	my $len = sqrt($v->[0]**2+$v->[1]**2+$v->[2]**2);
	if ($len != 0) {
		return ([$v->[0]/$len, $v->[1]/$len, $v->[2]/$len]);
	} else {
		return ([$v->[0], $v->[1], $v->[2]]); 
	}
}

##
## VECTOR4�̐��K�������x�N�g����Ԃ�
##
sub VEC_Vec4Normalize {
	my ($v) = @_;

	my $len = sqrt($v->[0]**2+$v->[1]**2+$v->[2]**2+$v->[3]**2);
	return ([$v->[0]/$len, $v->[1]/$len, $v->[2]/$len, $v->[3]/$len]);
}

##
## 2��VECTOR3�����Z����B
## 
sub VEC_Vec3Add {
	my ($vA, $vB) = @_;

	return [$vA->[0]+$vB->[0], $vA->[1]+$vB->[1], $vA->[2]+$vB->[2]];
}

##
## 2��VECTOR3�����Z����B
## �x�N�g��A�A�x�N�g��B ���� �x�N�g��BA �����߂�B
##
sub VEC_Vec3Subtract {
	my ($vA, $vB) = @_;

	return [$vA->[0]-$vB->[0], $vA->[1]-$vB->[1], $vA->[2]-$vB->[2]];
}

##
## VECTOR3���X�P�[�����O����
## VECTOR3�̊e�v�f��$s�{����B
##
sub VEC_Vec3Scale {
	my ($v, $s) = @_;

	return [$v->[0]*$s,$v->[1]*$s,$v->[2]*$s];
}

##
## 2��VECTOR2�̓��ς��Z�o����B
##
sub VEC_Vec2Dot {
	my ($vA, $vB) = @_;
	return ($vA->[0]*$vB->[0]+$vA->[1]*$vB->[1]);
}

##
## 2��VECTOR3�̓��ς��Z�o����B
##
sub VEC_Vec3Dot {
	my ($vA, $vB) = @_;
	return ($vA->[0]*$vB->[0]+$vA->[1]*$vB->[1]+$vA->[2]*$vB->[2]);
}

##
## 2��VECTOR4�̓��ς��Z�o����B
##
sub VEC_Vec4Dot {
	my ($vA, $vB) = @_;
	return ($vA->[0]*$vB->[0]+$vA->[1]*$vB->[1]+$vA->[2]*$vB->[2]+$vA->[3]*$vB->[3]);
}

##
## 2��VECTOR2�̊O��(AXB)���Z�o���� z �v�f��Ԃ��B
## z �v�f�̒l�����̏ꍇ�AvB �� vA �ɑ΂��Ĕ����v���ł���B
##
sub VEC_Vec2CCW {
	my ($vA, $vB) = @_;
	return ($vA->[0]*$vB->[1]-$vA->[1]*$vB->[0]);
}

##
## 2��VECTOR3�̊O��(AXB)���Z�o����B
##
sub VEC_Vec3Cross {
	my ($vA, $vB) = @_;

	return ([ $vA->[1]*$vB->[2] - $vA->[2]*$vB->[1],
			  $vA->[2]*$vB->[0] - $vA->[0]*$vB->[2],
			  $vA->[0]*$vB->[1] - $vA->[1]*$vB->[0]]);
}

##
## �w�肳�ꂽMATRIX�ɂ��VECTOR3���g�����X�t�H�[������B
## ���̊֐��́AVECTOR3��[x,y,z,1]�Ƃ��ăg�����X�t�H�[������B
## VECTOR4��Ԃ��B
##
sub VEC_Vec3Transform {
	my ($v, $m) = @_;

	my $x = $v->[0]*$m->[0][0] + $v->[1]*$m->[1][0] + $v->[2]*$m->[2][0] + $m->[3][0];
	my $y = $v->[0]*$m->[0][1] + $v->[1]*$m->[1][1] + $v->[2]*$m->[2][1] + $m->[3][1];
	my $z = $v->[0]*$m->[0][2] + $v->[1]*$m->[1][2] + $v->[2]*$m->[2][2] + $m->[3][2];
	my $w = $v->[0]*$m->[0][3] + $v->[1]*$m->[1][3] + $v->[2]*$m->[2][3] + $m->[3][3];

	return [$x,$y,$z,$w];
}

##
## �w�肳�ꂽMATRIX�ɂ��VECTOR3���g�����X�t�H�[�����A���̌��ʂ� w = 1 �Ɏˉe����B
## ���̌��ʂ�VECTOR3��Ԃ�(�����͏��1 �ƂȂ邽�� VECTOR3 �̌`�ŕԂ�)�B
##
sub VEC_Vec3TransformCoord {
	my ($v, $m) = @_;

	my $x = $v->[0]*$m->[0][0] + $v->[1]*$m->[1][0] + $v->[2]*$m->[2][0] + $m->[3][0];
	my $y = $v->[0]*$m->[0][1] + $v->[1]*$m->[1][1] + $v->[2]*$m->[2][1] + $m->[3][1];
	my $z = $v->[0]*$m->[0][2] + $v->[1]*$m->[1][2] + $v->[2]*$m->[2][2] + $m->[3][2];
	my $w = $v->[0]*$m->[0][3] + $v->[1]*$m->[1][3] + $v->[2]*$m->[2][3] + $m->[3][3];

	if ($w != 1 && $w != 0) {
		$x = $x/$w;
		$y = $y/$w;
		$z = $z/$w;
	}

	return [$x, $y, $z];
}

##
## �w�肳�ꂽMATRIX�ɂ��VECTOR3(�x�N�g���@��)���g�����X�t�H�[������B
## ���̊֐��́AVECTOR3��[x,y,z,0]�Ƃ��ăg�����X�t�H�[������B
## VECTOR3��Ԃ��B
sub VEC_Vec3TransformNormal {
	my ($v, $m) = @_;

	my $x = $v->[0]*$m->[0][0] + $v->[1]*$m->[1][0] + $v->[2]*$m->[2][0];
	my $y = $v->[0]*$m->[0][1] + $v->[1]*$m->[1][1] + $v->[2]*$m->[2][1];
	my $z = $v->[0]*$m->[0][2] + $v->[1]*$m->[1][2] + $v->[2]*$m->[2][2];

	return [$x,$y,$z];
}

##
## �w�肳�ꂽMATRIX�ɂ��VECTOR4���g�����X�t�H�[������B
## VECTOR4��Ԃ��B
##
sub VEC_Vec4Transform {
	my ($v, $m) = @_;

	my $x = $v->[0]*$m->[0][0] + $v->[1]*$m->[1][0] + $v->[2]*$m->[2][0] + $v->[3]*$m->[3][0];
	my $y = $v->[0]*$m->[0][1] + $v->[1]*$m->[1][1] + $v->[2]*$m->[2][1] + $v->[3]*$m->[3][1];
	my $z = $v->[0]*$m->[0][2] + $v->[1]*$m->[1][2] + $v->[2]*$m->[2][2] + $v->[3]*$m->[3][2];
	my $w = $v->[0]*$m->[0][3] + $v->[1]*$m->[1][3] + $v->[2]*$m->[2][3] + $v->[3]*$m->[3][3];

	return [$x,$y,$z,$w];
}

##
## VECTOR(VECTOR2,VECTOR3,VECTOR4�����F��) ��W���o�͂ɏo�͂���
## @param $v VECTOR2 or VECTOR3 or VECTOR4
##
sub VEC_VecPrint {
	my ($v) = @_;

	print 'VECTOR' . ($#$v+1);
	print ' [ ';
	print join(',', @{$v});
	print ' ] ', "\n";

	return $v;
}

1;
