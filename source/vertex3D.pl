##_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
## Prefix Is VTX
##_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
use strict;

###########################################################
##     ���_��`
##
##�y�P�z���g�����X�t�H�[���E�����C�e�B���O�̒��_
##   �� : UNLITVERTEX
##
##   UNLITVERTEX->{"TYPE"} = 'UNLITVERTEX' (�Œ�)     (�K�{)
##   UNLITVERTEX->{"VECTOR"} = [x, y, z] (VECTOR3)    (�K�{)
##   UNLITVERTEX->{"NORMAL"} = [nx, ny, nz] (VECTOR3) (�K�{)
##   UNLITVERTEX->{"TEX"} = [[tu1, tv1], [tu2, tv2]...] (VECTOR2�z��) (�e�N�X�`�������݂���ꍇ�̂�)
##
##
##�y�Q�z���g�����X�t�H�[���E���C�e�B���O�ς݂̒��_
##   �� : LITVERTEX
##
##   LITVERTEX->{"TYPE"} = 'LITVERTEX' (�Œ�)       (�K�{)
##   LITVERTEX->{"VECTOR"} = [x, y, z] (VECTOR3)    (�K�{)
##   LITVERTEX->{"DIFFUSE"} = [r, g, b, a] (COLOR)  (�K�{)
##   LITVERTEX->{"SPECULAR"} = [r, g, b, a] (COLOR) (�K�{)
##   LITVERTEX->{"TEX"} = [[tu1, tv1], [tu2, tv2]...] (VECTOR2�z��) (�e�N�X�`�������݂���ꍇ�̂�)
##
##
##�y�R�z�g�����X�t�H�[���ς݁E���C�e�B���O�ς݂̒��_
##   �� : TRANSLITVERTEX
##
##   TRANSLITVERTEX->{"TYPE"} = 'TRANSLITVERTEX' (�Œ�)   (�K�{)
##   TRANSLITVERTEX->{"VECTOR"} = [x, y, z, w] (VECTOR4)  (�K�{)
##   TRANSLITVERTEX->{"DIFFUSE"} = [r, g, b, a] (COLOR)   (�K�{)
##   TRANSLITVERTEX->{"SPECULAR"} = [r, g, b, a] (COLOR)  (�K�{)
##   TRANSLITVERTEX->{"TEX"} = [[tu1, tv1], [tu2, tv2]...] (VECTOR2�z��) (�e�N�X�`�������݂���ꍇ�̂�)
##
##
##�y�S�z�g�����X�t�H�[���ς݁E���C�e�B���O�ς݁E�N���b�s���O�ς݁E�v���Z�ς݁E�r���[�|�[�g�ϊ��ς݂̒��_
##    �� : VEWPORTVERTEX
##
##   VEWPORTVERTEX->{"TYPE"} = 'VEWPORTVERTEX' (�Œ�)   (�K�{)
##   VEWPORTVERTEX->{"VECTOR"} = [x, y] (VECTOR2)       (�K�{)
##   VEWPORTVERTEX->{"Z"} = z (float) (Z�o�t�@�l)       (�K�{)
##   VEWPORTVERTEX->{"RHW"} = rhw (float) (�����̋t��)  (�K�{)
##   VEWPORTVERTEX->{"DIFFUSE"} = [r, g, b, a] (COLOR)  (�K�{)
##   VEWPORTVERTEX->{"SPECULAR"} = [r, g, b, a] (COLOR) (�K�{)
##   VEWPORTVERTEX->{"TEX"} = [[tu1, tv1], [tu2, tv2]...] (VECTOR2�z��) (�e�N�X�`�������݂���ꍇ�̂�)
##
##
###########################################################


###
## ���_�o�b�t�@���쐬����
##
sub VTX_CreateVertexBuffer {
	return [];
}

###
## ���_�o�b�t�@�̍Ō���ɒ��_��ǉ�����B
## @param1 VertexBuffer
## @param2 Vertex
##
sub VTX_PushVertex {
	my ($vB, $v ) = @_;
	push(@$vB,$v);
	return $vB;
}

###
## ���_�o�b�t�@�̍őO���ɒ��_��ǉ�����B
## @param1 VertexBuffer
## @param2 Vertex
##
sub VTX_UnshiftVertex {
	my ($vB, $v ) = @_;

	unshift(@$vB,$v);
	return $vB;
}

###
## UNLITVERTEX(���g�����X�t�H�[���E�����C�e�B���O�̒��_)���쐬����B
## @param1 VECTOR3 ���_���W(�K�{)
## @param2 VECTOR3 ���_�@���x�N�g��(�K�{)
## @param3 VECTOR2 �e�N�X�`�����W�P(�e�N�X�`�������݂���ꍇ�̂�)
## @param4 VECTOR2 �e�N�X�`�����W�Q(�e�N�X�`�������݂���ꍇ�̂�)
## @param5 VECTOR2 �e�N�X�`�����W�R(�e�N�X�`�������݂���ꍇ�̂�)
##
sub VTX_CreateUnlitVertex {
	my $v = shift;
	my $n = shift;
	my $vertex = { TYPE => 'UNLITVERTEX', VECTOR => [@$v], NORMAL => [@$n] };
	map { push( @{$vertex->{'TEX'}}, [$_->[0],$_->[1]]) } @_;

	return $vertex;
}

###
## UNLITVERTEX(���g�����X�t�H�[���E�����C�e�B���O�̒��_)���쐬����B
## �e��p�����[�^�͎Q�Ɛݒ�̂݁B
## @param1 VECTOR3      ���_���W(�K�{)
## @param2 VECTOR3      ���_�@���x�N�g��(�K�{)
## @param3 VECTOR2�z��  �e�N�X�`�����W(�e�N�X�`�������݂���ꍇ�̂�)
##
sub VTX_MakeUnlitVertex {
	my $v = shift;
	my $n = shift;
	my $vertex = { TYPE => 'UNLITVERTEX', VECTOR => $v, NORMAL => $n };
	$vertex->{'TEX'} = shift if (@_);

	return $vertex;
}

###
## UNLITVERTEX(���g�����X�t�H�[���E�����C�e�B���O�̒��_)�ɑ΂���
## �e�N�X�`�����W��ݒ肷��B
## @param1 UnlitVertex  UNLITVERTEX���w�肷��B
## @param3 VECTOR2�z��  �e�N�X�`�����W
##
sub VTX_SetTexUnlitVertex {
	my $vertex = shift;
	$vertex->{'TEX'} = shift if (@_);

	return $vertex;
}

###
## LITVERTEX(���g�����X�t�H�[���E���C�e�B���O�ς݂̒��_)���쐬����B
## @param1 VECTOR3 ���_���W(�K�{)
## @param2 COLOR   ���_�̃f�B�t�F�[�Y�F(�K�{)
## @param3 COLOR   ���_�̃X�y�L�����[�F(�K�{)
## @param4 VECTOR2 �e�N�X�`�����W�P(�e�N�X�`�������݂���ꍇ�̂�)
## @param5 VECTOR2 �e�N�X�`�����W�Q(�e�N�X�`�������݂���ꍇ�̂�)
## @param6 VECTOR2 �e�N�X�`�����W�R(�e�N�X�`�������݂���ꍇ�̂�)
##
sub VTX_CreateLitVertex {
	my $v = shift;
	my $df = shift;
	my $sp = shift;
	my $vertex = { TYPE => 'LITVERTEX', VECTOR => [@$v], DIFFUSE => [@$df], SPECULAR => [@$sp] };
	map { push( @{$vertex->{'TEX'}}, [$_->[0],$_->[1]]) } @_;

	return $vertex;
}

###
## LITVERTEX(���g�����X�t�H�[���E���C�e�B���O�ς݂̒��_)���쐬����B
## �e��p�����[�^�͎Q�Ɛݒ�̂݁B
## @param1 VECTOR3      ���_���W(�K�{)
## @param2 COLOR        ���_�̃f�B�t�F�[�Y�F(�K�{)
## @param3 COLOR        ���_�̃X�y�L�����[�F(�K�{)
## @param4 VECTOR2�z��  �e�N�X�`�����W(�e�N�X�`�������݂���ꍇ�̂�)
##
sub VTX_MakeLitVertex {
	my $v = shift;
	my $df = shift;
	my $sp = shift;
	my $vertex = { TYPE => 'LITVERTEX', VECTOR => $v, DIFFUSE => $df, SPECULAR => $sp };
	$vertex->{'TEX'} = shift if (@_);

	return $vertex;
}

###
## TRANSLITVERTEX(�g�����X�t�H�[���ς݁E���C�e�B���O�ς݂̒��_)���쐬����B
## @param1 VECTOR4 ���_���W(�K�{)
## @param2 COLOR   ���_�̃f�B�t�F�[�Y�F(�K�{)
## @param3 COLOR   ���_�̃X�y�L�����[�F(�K�{)
## @param4 VECTOR2 �e�N�X�`�����W�P(�e�N�X�`�������݂���ꍇ�̂�)
## @param5 VECTOR2 �e�N�X�`�����W�Q(�e�N�X�`�������݂���ꍇ�̂�)
## @param6 VECTOR2 �e�N�X�`�����W�R(�e�N�X�`�������݂���ꍇ�̂�)
##
sub VTX_CreateTransLitVertex {
	my $v = shift;
	my $df = shift;
	my $sp = shift;
	my $vertex = { TYPE => 'TRANSLITVERTEX', VECTOR => [@$v], DIFFUSE => [@$df], SPECULAR => [@$sp] };
	map { push( @{$vertex->{'TEX'}}, [$_->[0],$_->[1]]) } @_;

	return $vertex;
}

###
## TRANSLITVERTEX(�g�����X�t�H�[���ς݁E���C�e�B���O�ς݂̒��_)���쐬����B
## �e��p�����[�^�͎Q�Ɛݒ�̂݁B
## @param1 VECTOR4      ���_���W(�K�{)
## @param2 COLOR        ���_�̃f�B�t�F�[�Y�F(�K�{)
## @param3 COLOR        ���_�̃X�y�L�����[�F(�K�{)
## @param4 VECTOR2�z��  �e�N�X�`�����W(�e�N�X�`�������݂���ꍇ�̂�)
##
sub VTX_MakeTransLitVertex {
	my $v = shift;
	my $df = shift;
	my $sp = shift;
	my $vertex = { TYPE => 'TRANSLITVERTEX',  VECTOR => $v, DIFFUSE => $df, SPECULAR => $sp };
	$vertex->{'TEX'} = shift if (@_);

	return $vertex;
}

###
## VEWPORTVERTEX(�g�����X�t�H�[���ς݁E���C�e�B���O�ς݁E
## �N���b�s���O�ς݁E�v���Z�ς݁E�r���[�|�[�g�ϊ��ς݂̒��_)���쐬����B
## @param1 VECTOR2 ���_���W(�K�{)
## @param2 float   Z�o�b�t�@�l(�K�{)
## @param3 float   rhw�l(�����̋t��)(�K�{)
## @param4 COLOR   ���_�̃f�B�t�F�[�Y�F(�K�{)
## @param5 COLOR   ���_�̃X�y�L�����[�F(�K�{)
## @param6 VECTOR2 �e�N�X�`�����W�P(�e�N�X�`�������݂���ꍇ�̂�)
## @param7 VECTOR2 �e�N�X�`�����W�Q(�e�N�X�`�������݂���ꍇ�̂�)
## @param8 VECTOR2 �e�N�X�`�����W�R(�e�N�X�`�������݂���ꍇ�̂�)
##
sub VTX_CreateVewportVertex {
	my $v = shift;
	my $z = shift;
	my $rhw = shift;
	my $df = shift;
	my $sp = shift;
	my $vertex = { TYPE => 'VEWPORTVERTEX', VECTOR => [@$v], Z => $z, RHW => $rhw, DIFFUSE => [@$df], SPECULAR => [@$sp] };
	map { push( @{$vertex->{'TEX'}}, [$_->[0],$_->[1]]) } @_;

	return $vertex;
}

###
## VEWPORTVERTEX(�g�����X�t�H�[���ς݁E���C�e�B���O�ς݁E
## �N���b�s���O�ς݁E�v���Z�ς݁E�r���[�|�[�g�ϊ��ς݂̒��_)���쐬����B
## �e��p�����[�^�͎Q�Ɛݒ�̂݁B
## @param1 VECTOR2      ���_���W(�K�{)
## @param2 float        Z�o�b�t�@�l(�K�{)
## @param3 float        rhw�l(�����̋t��)(�K�{)
## @param4 COLOR        ���_�̃f�B�t�F�[�Y�F(�K�{)
## @param5 COLOR        ���_�̃X�y�L�����[�F(�K�{)
## @param6 VECTOR2�z��  �e�N�X�`�����W(�e�N�X�`�������݂���ꍇ�̂�)
##
sub VTX_MakeVewportVertex {
	my $v = shift;
	my $z = shift;
	my $rhw = shift;
	my $df = shift;
	my $sp = shift;
	my $vertex = { TYPE => 'VEWPORTVERTEX', VECTOR => $v, Z => $z, RHW => $rhw, DIFFUSE => $df, SPECULAR => $sp };
	$vertex->{'TEX'} = shift if (@_);

	return $vertex;
}

###
## Vertex��W���o�͂ɏo�͂���B
## UNLITVERTEX, LITVERTEX, TRANSLITVERTEX, VEWPORTVERTEX�������F��
## @param Vertex ���_�^
##
sub VTX_VertexPrint {
	my ($v) = @_;

	print 'Type     [' . $v->{'TYPE'}                   . ']', "\n";
	print 'Vector   [' . join(',', @{$v->{'VECTOR'}})   . ']', "\n" if ($v->{'VECTOR'});
	print 'Normal   [' . join(',', @{$v->{'NORMAL'}})   . ']', "\n" if ($v->{'NORMAL'});
	print 'Z        [' . $v->{'Z'}                      . ']', "\n" if ($v->{'Z'});
	print 'RHW      [' . $v->{'RHW'}                    . ']', "\n" if ($v->{'RHW'});
	print 'DIFFUSE  [' . join(',', @{$v->{'DIFFUSE'}})  . ']', "\n" if ($v->{'DIFFUSE'});
	print 'SPECULAR [' . join(',', @{$v->{'SPECULAR'}}) . ']', "\n" if ($v->{'SPECULAR'});
	my $i = 1;
	map { print 'TEX' . $i++ . '     [' . $_->[0] . ',' . $_->[1] .  ']', "\n" } @{$v->{'TEX'}} if ($v->{'TEX'});
}

###
## VertexBuffer��W���o�͂ɏo�͂���B
## UNLITVERTEX, LITVERTEX, TRANSLITVERTEX, VEWPORTVERTEX�������F��
## @param VertexBuffer ���_�o�b�t�@�^
##
sub VTX_VertexBufferPrint {
	my ($v) = @_;

	for my $index (0..$#$v) {
		print 'Index    [' . $index . ']', "\n";
		VTX_VertexPrint($v->[$index]);
		print "\n";
	}
}

1;
