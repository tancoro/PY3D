##_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
## Prefix Is LIT
##_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
use strict;
require '..\PY3D\vector3D.pl';


##########################################
##�y Light �̒�` �z
##
##  Light->{"TYPE"} = 'LIGHT_POINT' or 'LIGHT_DIRECTIONAL';
##  Light->{"DIFFUSE"} = [r, g, b, a];
##  Light->{"SPECULAR"} = [r, g, b, a];
##  Light->{"AMBIENT"} = [r, g, b, a];
##  Light->{"POSITION"} = [x, y, z]; ���[���h��Ԃł̌����̈ʒu (LIGHT_POINT�̏ꍇ�̂݌��ʂ���)
##  Light->{"DIRECTION"} = [x, y, z]; ���[���h��Ԃł̌����x�N�g�� (LIGHT_DIRECTIONAL�̏ꍇ�̂݌��ʂ���)
##  Light->{"ATTENUATION"} = [a0, a1, a2];  ���̋P�x�̋����ɑ΂��錸���x�B(LIGHT_POINT�̏ꍇ�̂݌��ʂ���)
##
##�y Material �̒�` �z
##
##  Material->{"DIFFUSE"} = [r, g, b, a];
##  Material->{"SPECULAR"} = [r, g, b, a];
##  Material->{"AMBIENT"} = [r, g, b, a];
##  Material->{"EMISSIVE"} = [r, g, b, a];
##  Material->{"POWER"} = flot; �X�y�L�����n�C���C�g�̑N���x���w�肷�镂�������_�l�B
##
##########################################


###
## �V�K�̃f�B���N�V���i�����C�g���쐬���܂��B
##
## @param1 $diffuse [r,g,b,a]
## @param2 $specular [r,g,b,a]
## @param3 $ambient [r,g,b,a]
## @param4 $direction [x, y, z]
## @return �f�B���N�V���i�����C�g�I�u�W�F�N�g
##
sub LIT_CreateDirectionalLight {
	my ($diffuse, $specular, $ambient, $direction) = @_;

	my $light = {	TYPE=>'LIGHT_DIRECTIONAL',
					DIFFUSE=>[@$diffuse],
					SPECULAR=>[@$specular],
					AMBIENT=>[@$ambient],
					DIRECTION=>[@$direction] };
	return $light;
}


###
## �V�K�̃|�C���g���C�g���쐬���܂��B
##
## @param1 $diffuse [r,g,b,a]
## @param2 $specular [r,g,b,a]
## @param3 $ambient [r,g,b,a]
## @param4 $position [x, y, z]
## @param5 $attenuation = [a0, a1, a2]
## @return �|�C���g���C�g�I�u�W�F�N�g
##
sub LIT_CreatePointLight {
	my ($diffuse, $specular, $ambient, $position, $attenuation) = @_;

	my $light = {	TYPE=>'LIGHT_POINT',
					DIFFUSE=>[@$diffuse],
					SPECULAR=>[@$specular],
					AMBIENT=>[@$ambient],
					POSITION=>[@$position],
					ATTENUATION=>[@$attenuation] };
	return $light;
}


###
## �V�K�̃}�e���A�����쐬���܂��B
##
## @param1 $diffuse [r,g,b,a]
## @param2 $specular [r,g,b,a]
## @param3 $ambient [r,g,b,a]
## @param4 $emissive [r,g,b,a]
## @param5 $power = ���������l �X�y�L�����n�C���C�g�̑N���x
## @return �}�e���A���I�u�W�F�N�g
##
sub LIT_CreateMaterial {
	my ($diffuse, $specular, $ambient, $emissive, $power) = @_;

	my $material = {DIFFUSE=>[@$diffuse],
					SPECULAR=>[@$specular],
					AMBIENT=>[@$ambient],
					EMISSIVE=>[@$emissive],
					POWER=>$power};

	return $material;
}


###
## ���C�e�B���O���s���B
##
## @param1 VECTOR3 �J������Ԃł̒��_���W
## @param2 VECTOR3 �J������Ԃł̒��_�̖@��(���K�����ꂽ���́j
## @param3 RenderState �����_�����O�X�e�[�g�I�u�W�F�N�g
## @return (Diffuse, Specular) ���C�e�B���O��̒��_�̐F
##
sub LIT_Lighting {
	my ($v, $n, $rs) = @_;

	## �}�e���A�����擾����B
	my $material = $rs->{"RS_MATERIAL"};

	## ���C�g����e�������e�F��p�ӂ���B
	my ($lightDiffRed, $lightDiffGreen, $lightDiffBlue) = (0,0,0);
	my ($lightSpecRed, $lightSpecGreen, $lightSpecBlue) = (0,0,0);

	## ���C�g�̌�������������B
	foreach my $light (@{$rs->{"RS_LIGHT"}}) {

		## �ϐ��錾
		my $ld = [0,0,1]; my $att= 1;

		## �f�B���N�V���i�����C�g�̏ꍇ
		if ($light->{"TYPE"} eq 'LIGHT_DIRECTIONAL') {
			## ���C�g�ւ̕����x�N�g�������߂�B
			$ld = VEC_Vec3Scale(
						VEC_Vec3Normalize(
							VEC_Vec3TransformNormal($light->{"DIRECTION"}, $rs->{"RS_TS_VIEW"})), -1);

		## �|�C���g���C�g�̏ꍇ
		} elsif ($light->{"TYPE"} eq 'LIGHT_POINT') {

			## ���_���烉�C�g�֌����x�N�g�������߂�B
			my $vLp = VEC_Vec3Subtract( VEC_Vec3TransformCoord($light->{"POSITION"}, $rs->{"RS_TS_VIEW"}), $v);
			## ���_ - ���C�g�Ԃ̋��������߂�B
			my $d = VEC_Vec3Length($vLp);

			## ���C�g�ւ̕����x�N�g�������߂�B
			## VEC_VecPrint($vLp) if ($vLp->[0] == 0 && $vLp->[1] == 0 && $vLp->[2] == 0);
			$ld = VEC_Vec3Normalize($vLp);
			## ���C�g�̌����W�������߂�B
			$att = 1 / ( $light->{"ATTENUATION"}->[0] + 
							$light->{"ATTENUATION"}->[1] * $d + 
								$light->{"ATTENUATION"}->[2] * $d**2 );
		}

		## ���_�ւ̃x�N�g�������߂�B
		my $vPe = VEC_Vec3Normalize( VEC_Vec3Scale($v, -1));
		## ���C�g�ւ̃x�N�g���Ǝ��_�ւ̃x�N�g���̊Ԃ̒��ԃx�N�g�������߂�B
		my $h = VEC_Vec3Normalize( VEC_Vec3Add($vPe, $ld));
		## �X�y�L�������˗�(���ԃx�N�g���Ɩ@���x�N�g���̓���)�����߂�B
		my $rSp = VEC_Vec3Dot($n, $h);
		$rSp = 1 if ($rSp > 1);
		$rSp = 0 if ($rSp < 0);

		## ���C�g�ւ̕����x�N�g���Ɩ@���x�N�g���̓��ς����߂�B
		my $nldcos = VEC_Vec3Dot($n, $ld);
		$nldcos = 1 if ($nldcos > 1);
		$nldcos = 0 if ($nldcos < 0);

		## ���C�g�̉e������󂯂�f�B�t�F�[�Y�F�����߂�B
		$lightDiffRed += $att * ($material->{"DIFFUSE"}->[0] * $light->{"DIFFUSE"}->[0] * $nldcos + 
											$material->{"AMBIENT"}->[0] * $light->{"AMBIENT"}->[0]);
		$lightDiffGreen += $att * ($material->{"DIFFUSE"}->[1] * $light->{"DIFFUSE"}->[1] * $nldcos + 
											$material->{"AMBIENT"}->[1] * $light->{"AMBIENT"}->[1]);
		$lightDiffBlue += $att * ($material->{"DIFFUSE"}->[2] * $light->{"DIFFUSE"}->[2] * $nldcos + 
											$material->{"AMBIENT"}->[2] * $light->{"AMBIENT"}->[2]);

		## ���C�g�̉e������󂯂�X�y�L�����F�����߂�B
		$lightSpecRed += $att * ($rSp**$material->{"POWER"}) * $light->{"SPECULAR"}->[0];
		$lightSpecGreen += $att * ($rSp**$material->{"POWER"}) * $light->{"SPECULAR"}->[1];
		$lightSpecBlue += $att * ($rSp**$material->{"POWER"}) * $light->{"SPECULAR"}->[2];

	}

	## �f�B�t�F�[�Y�F���i�[����B
	my $vtxDiffuse = [		$material->{"AMBIENT"}->[0] * $rs->{"RS_AMBIENT"}->[0] + 
										$material->{"EMISSIVE"}->[0] + $lightDiffRed ,
							$material->{"AMBIENT"}->[1] * $rs->{"RS_AMBIENT"}->[1] + 
										$material->{"EMISSIVE"}->[1] + $lightDiffGreen ,
							$material->{"AMBIENT"}->[2] * $rs->{"RS_AMBIENT"}->[2] + 
										$material->{"EMISSIVE"}->[2] + $lightDiffBlue ,
							$material->{"DIFFUSE"}->[3] ];

	## �X�y�L�����F���i�[����B
	my $vtxSpecular = [		$material->{"SPECULAR"}->[0] * $lightSpecRed,
							$material->{"SPECULAR"}->[1] * $lightSpecGreen,
							$material->{"SPECULAR"}->[2] * $lightSpecBlue,
							$material->{"SPECULAR"}->[3]];


	return ($vtxDiffuse, $vtxSpecular);
}

1;
