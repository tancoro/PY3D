##_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
## Prefix Is VEC
##_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
use strict;


###########################################################
## ベクトル定義
##【１】2Dベクトル
##    名 : VECTOR2
##    型 : [x, y]
##
##【２】3Dベクトル
##    名 : VECTOR3
##    型 : [x, y, z]
##
##【３】4Dベクトル
##    名 : VECTOR4
##    型 : [x, y, z, w]
###########################################################


##
## VECTOR2を作成する
## @param1 X値
## @param2 Y値
##
sub VEC_ToVector2 {
	my ($x, $y) = @_;
	return [$x, $y];
}

##
## VECTOR3を作成する
## @param1 X値
## @param2 Y値
## @param3 Z値
##
sub VEC_ToVector3 {
	my ($x, $y, $z) = @_;
	return [$x, $y, $z];
}

##
## VECTOR4を作成する
## @param1 X値
## @param2 Y値
## @param3 Z値
## @param4 W値
##
sub VEC_ToVector4 {
	my ($x, $y, $z, $w) = @_;
	return [$x, $y, $z, $w];
}

##
## VECTOR2の長さを求める
##
sub VEC_Vec2Length {
	my ($v) = @_;
	return sqrt($v->[0]**2+$v->[1]**2);
}

##
## VECTOR3の長さを求める
##
sub VEC_Vec3Length {
	my ($v) = @_;
	return sqrt($v->[0]**2+$v->[1]**2+$v->[2]**2);
}

##
## VECTOR4の長さを求める
##
sub VEC_Vec4Length {
	my ($v) = @_;
	return sqrt($v->[0]**2+$v->[1]**2+$v->[2]**2+$v->[3]**2);
}

##
## VECTOR2の正規化したベクトルを返す
##
sub VEC_Vec2Normalize {
	my ($v) = @_;

	my $len = sqrt($v->[0]**2+$v->[1]**2);
	return ([$v->[0]/$len, $v->[1]/$len]);
}

##
## VECTOR3の正規化したベクトルを返す
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
## VECTOR4の正規化したベクトルを返す
##
sub VEC_Vec4Normalize {
	my ($v) = @_;

	my $len = sqrt($v->[0]**2+$v->[1]**2+$v->[2]**2+$v->[3]**2);
	return ([$v->[0]/$len, $v->[1]/$len, $v->[2]/$len, $v->[3]/$len]);
}

##
## 2つのVECTOR3を加算する。
## 
sub VEC_Vec3Add {
	my ($vA, $vB) = @_;

	return [$vA->[0]+$vB->[0], $vA->[1]+$vB->[1], $vA->[2]+$vB->[2]];
}

##
## 2つのVECTOR3を減算する。
## ベクトルA、ベクトルB から ベクトルBA を求める。
##
sub VEC_Vec3Subtract {
	my ($vA, $vB) = @_;

	return [$vA->[0]-$vB->[0], $vA->[1]-$vB->[1], $vA->[2]-$vB->[2]];
}

##
## VECTOR3をスケーリングする
## VECTOR3の各要素を$s倍する。
##
sub VEC_Vec3Scale {
	my ($v, $s) = @_;

	return [$v->[0]*$s,$v->[1]*$s,$v->[2]*$s];
}

##
## 2つのVECTOR2の内積を算出する。
##
sub VEC_Vec2Dot {
	my ($vA, $vB) = @_;
	return ($vA->[0]*$vB->[0]+$vA->[1]*$vB->[1]);
}

##
## 2つのVECTOR3の内積を算出する。
##
sub VEC_Vec3Dot {
	my ($vA, $vB) = @_;
	return ($vA->[0]*$vB->[0]+$vA->[1]*$vB->[1]+$vA->[2]*$vB->[2]);
}

##
## 2つのVECTOR4の内積を算出する。
##
sub VEC_Vec4Dot {
	my ($vA, $vB) = @_;
	return ($vA->[0]*$vB->[0]+$vA->[1]*$vB->[1]+$vA->[2]*$vB->[2]+$vA->[3]*$vB->[3]);
}

##
## 2つのVECTOR2の外積(AXB)を算出して z 要素を返す。
## z 要素の値が正の場合、vB は vA に対して反時計回りである。
##
sub VEC_Vec2CCW {
	my ($vA, $vB) = @_;
	return ($vA->[0]*$vB->[1]-$vA->[1]*$vB->[0]);
}

##
## 2つのVECTOR3の外積(AXB)を算出する。
##
sub VEC_Vec3Cross {
	my ($vA, $vB) = @_;

	return ([ $vA->[1]*$vB->[2] - $vA->[2]*$vB->[1],
			  $vA->[2]*$vB->[0] - $vA->[0]*$vB->[2],
			  $vA->[0]*$vB->[1] - $vA->[1]*$vB->[0]]);
}

##
## 指定されたMATRIXによりVECTOR3をトランスフォームする。
## この関数は、VECTOR3を[x,y,z,1]としてトランスフォームする。
## VECTOR4を返す。
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
## 指定されたMATRIXによりVECTOR3をトランスフォームし、その結果を w = 1 に射影する。
## その結果のVECTOR3を返す(同次は常に1 となるため VECTOR3 の形で返す)。
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
## 指定されたMATRIXによりVECTOR3(ベクトル法線)をトランスフォームする。
## この関数は、VECTOR3を[x,y,z,0]としてトランスフォームする。
## VECTOR3を返す。
sub VEC_Vec3TransformNormal {
	my ($v, $m) = @_;

	my $x = $v->[0]*$m->[0][0] + $v->[1]*$m->[1][0] + $v->[2]*$m->[2][0];
	my $y = $v->[0]*$m->[0][1] + $v->[1]*$m->[1][1] + $v->[2]*$m->[2][1];
	my $z = $v->[0]*$m->[0][2] + $v->[1]*$m->[1][2] + $v->[2]*$m->[2][2];

	return [$x,$y,$z];
}

##
## 指定されたMATRIXによりVECTOR4をトランスフォームする。
## VECTOR4を返す。
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
## VECTOR(VECTOR2,VECTOR3,VECTOR4自動認識) を標準出力に出力する
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
