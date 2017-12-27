##_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
## Prefix Is VTX
##_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
use strict;

###########################################################
##     頂点定義
##
##【１】未トランスフォーム・未ライティングの頂点
##   名 : UNLITVERTEX
##
##   UNLITVERTEX->{"TYPE"} = 'UNLITVERTEX' (固定)     (必須)
##   UNLITVERTEX->{"VECTOR"} = [x, y, z] (VECTOR3)    (必須)
##   UNLITVERTEX->{"NORMAL"} = [nx, ny, nz] (VECTOR3) (必須)
##   UNLITVERTEX->{"TEX"} = [[tu1, tv1], [tu2, tv2]...] (VECTOR2配列) (テクスチャが存在する場合のみ)
##
##
##【２】未トランスフォーム・ライティング済みの頂点
##   名 : LITVERTEX
##
##   LITVERTEX->{"TYPE"} = 'LITVERTEX' (固定)       (必須)
##   LITVERTEX->{"VECTOR"} = [x, y, z] (VECTOR3)    (必須)
##   LITVERTEX->{"DIFFUSE"} = [r, g, b, a] (COLOR)  (必須)
##   LITVERTEX->{"SPECULAR"} = [r, g, b, a] (COLOR) (必須)
##   LITVERTEX->{"TEX"} = [[tu1, tv1], [tu2, tv2]...] (VECTOR2配列) (テクスチャが存在する場合のみ)
##
##
##【３】トランスフォーム済み・ライティング済みの頂点
##   名 : TRANSLITVERTEX
##
##   TRANSLITVERTEX->{"TYPE"} = 'TRANSLITVERTEX' (固定)   (必須)
##   TRANSLITVERTEX->{"VECTOR"} = [x, y, z, w] (VECTOR4)  (必須)
##   TRANSLITVERTEX->{"DIFFUSE"} = [r, g, b, a] (COLOR)   (必須)
##   TRANSLITVERTEX->{"SPECULAR"} = [r, g, b, a] (COLOR)  (必須)
##   TRANSLITVERTEX->{"TEX"} = [[tu1, tv1], [tu2, tv2]...] (VECTOR2配列) (テクスチャが存在する場合のみ)
##
##
##【４】トランスフォーム済み・ライティング済み・クリッピング済み・Ｗ除算済み・ビューポート変換済みの頂点
##    名 : VEWPORTVERTEX
##
##   VEWPORTVERTEX->{"TYPE"} = 'VEWPORTVERTEX' (固定)   (必須)
##   VEWPORTVERTEX->{"VECTOR"} = [x, y] (VECTOR2)       (必須)
##   VEWPORTVERTEX->{"Z"} = z (float) (Zバファ値)       (必須)
##   VEWPORTVERTEX->{"RHW"} = rhw (float) (同次の逆数)  (必須)
##   VEWPORTVERTEX->{"DIFFUSE"} = [r, g, b, a] (COLOR)  (必須)
##   VEWPORTVERTEX->{"SPECULAR"} = [r, g, b, a] (COLOR) (必須)
##   VEWPORTVERTEX->{"TEX"} = [[tu1, tv1], [tu2, tv2]...] (VECTOR2配列) (テクスチャが存在する場合のみ)
##
##
###########################################################


###
## 頂点バッファを作成する
##
sub VTX_CreateVertexBuffer {
	return [];
}

###
## 頂点バッファの最後尾に頂点を追加する。
## @param1 VertexBuffer
## @param2 Vertex
##
sub VTX_PushVertex {
	my ($vB, $v ) = @_;
	push(@$vB,$v);
	return $vB;
}

###
## 頂点バッファの最前項に頂点を追加する。
## @param1 VertexBuffer
## @param2 Vertex
##
sub VTX_UnshiftVertex {
	my ($vB, $v ) = @_;

	unshift(@$vB,$v);
	return $vB;
}

###
## UNLITVERTEX(未トランスフォーム・未ライティングの頂点)を作成する。
## @param1 VECTOR3 頂点座標(必須)
## @param2 VECTOR3 頂点法線ベクトル(必須)
## @param3 VECTOR2 テクスチャ座標１(テクスチャが存在する場合のみ)
## @param4 VECTOR2 テクスチャ座標２(テクスチャが存在する場合のみ)
## @param5 VECTOR2 テクスチャ座標３(テクスチャが存在する場合のみ)
##
sub VTX_CreateUnlitVertex {
	my $v = shift;
	my $n = shift;
	my $vertex = { TYPE => 'UNLITVERTEX', VECTOR => [@$v], NORMAL => [@$n] };
	map { push( @{$vertex->{'TEX'}}, [$_->[0],$_->[1]]) } @_;

	return $vertex;
}

###
## UNLITVERTEX(未トランスフォーム・未ライティングの頂点)を作成する。
## 各種パラメータは参照設定のみ。
## @param1 VECTOR3      頂点座標(必須)
## @param2 VECTOR3      頂点法線ベクトル(必須)
## @param3 VECTOR2配列  テクスチャ座標(テクスチャが存在する場合のみ)
##
sub VTX_MakeUnlitVertex {
	my $v = shift;
	my $n = shift;
	my $vertex = { TYPE => 'UNLITVERTEX', VECTOR => $v, NORMAL => $n };
	$vertex->{'TEX'} = shift if (@_);

	return $vertex;
}

###
## UNLITVERTEX(未トランスフォーム・未ライティングの頂点)に対して
## テクスチャ座標を設定する。
## @param1 UnlitVertex  UNLITVERTEXを指定する。
## @param3 VECTOR2配列  テクスチャ座標
##
sub VTX_SetTexUnlitVertex {
	my $vertex = shift;
	$vertex->{'TEX'} = shift if (@_);

	return $vertex;
}

###
## LITVERTEX(未トランスフォーム・ライティング済みの頂点)を作成する。
## @param1 VECTOR3 頂点座標(必須)
## @param2 COLOR   頂点のディフェーズ色(必須)
## @param3 COLOR   頂点のスペキュラー色(必須)
## @param4 VECTOR2 テクスチャ座標１(テクスチャが存在する場合のみ)
## @param5 VECTOR2 テクスチャ座標２(テクスチャが存在する場合のみ)
## @param6 VECTOR2 テクスチャ座標３(テクスチャが存在する場合のみ)
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
## LITVERTEX(未トランスフォーム・ライティング済みの頂点)を作成する。
## 各種パラメータは参照設定のみ。
## @param1 VECTOR3      頂点座標(必須)
## @param2 COLOR        頂点のディフェーズ色(必須)
## @param3 COLOR        頂点のスペキュラー色(必須)
## @param4 VECTOR2配列  テクスチャ座標(テクスチャが存在する場合のみ)
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
## TRANSLITVERTEX(トランスフォーム済み・ライティング済みの頂点)を作成する。
## @param1 VECTOR4 頂点座標(必須)
## @param2 COLOR   頂点のディフェーズ色(必須)
## @param3 COLOR   頂点のスペキュラー色(必須)
## @param4 VECTOR2 テクスチャ座標１(テクスチャが存在する場合のみ)
## @param5 VECTOR2 テクスチャ座標２(テクスチャが存在する場合のみ)
## @param6 VECTOR2 テクスチャ座標３(テクスチャが存在する場合のみ)
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
## TRANSLITVERTEX(トランスフォーム済み・ライティング済みの頂点)を作成する。
## 各種パラメータは参照設定のみ。
## @param1 VECTOR4      頂点座標(必須)
## @param2 COLOR        頂点のディフェーズ色(必須)
## @param3 COLOR        頂点のスペキュラー色(必須)
## @param4 VECTOR2配列  テクスチャ座標(テクスチャが存在する場合のみ)
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
## VEWPORTVERTEX(トランスフォーム済み・ライティング済み・
## クリッピング済み・Ｗ除算済み・ビューポート変換済みの頂点)を作成する。
## @param1 VECTOR2 頂点座標(必須)
## @param2 float   Zバッファ値(必須)
## @param3 float   rhw値(同次の逆数)(必須)
## @param4 COLOR   頂点のディフェーズ色(必須)
## @param5 COLOR   頂点のスペキュラー色(必須)
## @param6 VECTOR2 テクスチャ座標１(テクスチャが存在する場合のみ)
## @param7 VECTOR2 テクスチャ座標２(テクスチャが存在する場合のみ)
## @param8 VECTOR2 テクスチャ座標３(テクスチャが存在する場合のみ)
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
## VEWPORTVERTEX(トランスフォーム済み・ライティング済み・
## クリッピング済み・Ｗ除算済み・ビューポート変換済みの頂点)を作成する。
## 各種パラメータは参照設定のみ。
## @param1 VECTOR2      頂点座標(必須)
## @param2 float        Zバッファ値(必須)
## @param3 float        rhw値(同次の逆数)(必須)
## @param4 COLOR        頂点のディフェーズ色(必須)
## @param5 COLOR        頂点のスペキュラー色(必須)
## @param6 VECTOR2配列  テクスチャ座標(テクスチャが存在する場合のみ)
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
## Vertexを標準出力に出力する。
## UNLITVERTEX, LITVERTEX, TRANSLITVERTEX, VEWPORTVERTEXを自動認識
## @param Vertex 頂点型
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
## VertexBufferを標準出力に出力する。
## UNLITVERTEX, LITVERTEX, TRANSLITVERTEX, VEWPORTVERTEXを自動認識
## @param VertexBuffer 頂点バッファ型
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
