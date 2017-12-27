##_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
## Prefix Is PL2
##_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
use strict;
require '..\PY3D\makeBMP2D.pl';


##/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
## XY平面オブジェクト作成関数
##
##【メソッド説明】
## $obj->{'setcolor'}->(c)         /* DotColor を cに変更する                       */
## $obj->{'setbackcolor'}->(c)     /* BackColor を cに変更する                      */
## $obj->{'setxrate'}->(xmax,xmin) /* xMax, xMin をそれぞれ xmax, xmin に変更する   */
## $obj->{'setyrate'}->(ymax,ymin) /* yMax, yMin をそれぞれ ymax, ymin に変更する   */
## $obj->{'point'}->(x,y)          /* (x,y)に点を打つ                               */
## $obj->{'polpt'}->(r,θ)         /* 極座標値(r,θ)に点を打つ(θはラジアン)        */
## $obj->{'line'}->(x1,y1,x2,y2)   /* (x1,y1)-(x2,y2)に線を引く                     */
## $obj->{'circle'}->(x,y,r)       /* (x,y)に半径rの円を描く                        */
## $obj->{'cleartable'}->()        /* XY平面をクリアする                            */
## $obj->{'print'}->(filename)     /* filenameのファイルにbmpを出力する             */
##
##/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
sub PL2_MakeXYPane {
	my ($bmpWidth, $bmpHeight, $xMax, $xMin, $yMax, $yMin, $backColor, $lineColor, $dotColor, $lineFlag) = @_;

	## set private properties
	my $prop = {};
	$prop->{'BmpWidth'} = $bmpWidth;
	$prop->{'BmpHeight'} = $bmpHeight;
	$prop->{'XMax'} = $xMax;
	$prop->{'XMin'} = $xMin;
	$prop->{'YMax'} = $yMax;
	$prop->{'YMin'} = $yMin;
	$prop->{'BackColor'} = $backColor;
	$prop->{'LineColor'} = $lineColor;
	$prop->{'DotColor'} = $dotColor;
	$prop->{'LineFlag'} = $lineFlag;
	$prop->{'CTable'} = MBF_GetNewColorTable($bmpWidth, $bmpHeight, $backColor);
	$prop->{'XRate'} = $bmpWidth/($xMax - $xMin);
	$prop->{'YRate'} = $bmpHeight/($yMax - $yMin);
	$prop->{'CW'} = sub { int(($_[0] - $prop->{'XMin'}) * $prop->{'XRate'}) };
	$prop->{'CH'} = sub { int(($_[0] - $prop->{'YMin'}) * $prop->{'YRate'}) };

	## XY軸を描画する。
	drawXYline($prop);

	my $planeObj = {};
	$planeObj->{'setcolor'} = setcolorMeth($prop);
	$planeObj->{'setbackcolor'} = setbackcolorMeth($prop);
	$planeObj->{'setxrate'} = setxrateMeth($prop);
	$planeObj->{'setyrate'} = setyrateMeth($prop);
	$planeObj->{'point'} = pointMeth($prop);
	$planeObj->{'line'} = lineMeth($prop);
	$planeObj->{'circle'} = circleMeth($prop);
	$planeObj->{'polpt'} = polptMeth($prop);
	$planeObj->{'cleartable'} = cleartableMeth($prop);
	$planeObj->{'print'} = printMeth($prop);
	return $planeObj;
}


sub setcolorMeth {
	my ($prop) = @_;
	return sub { $prop->{'DotColor'} = $_[0] };
}

sub setbackcolorMeth {
	my ($prop) = @_;
	return sub { $prop->{'BackColor'} = $_[0] };
}

sub setxrateMeth {
	my ($prop) = @_;
	return sub { $prop->{'XMax'} = $_[0]; 
				 $prop->{'XMin'} = $_[1];
				 $prop->{'XRate'} = $prop->{'BmpWidth'}/($_[0] - $_[1]);
			};
}

sub setyrateMeth {
	my ($prop) = @_;
	return sub { $prop->{'YMax'} = $_[0]; 
				 $prop->{'YMin'} = $_[1];
				 $prop->{'YRate'} = $prop->{'BmpHeight'}/($_[0] - $_[1]);
			};
}

sub pointMeth {
	my ($prop) = @_;
	return sub { MBF_SetColorData( $prop->{'CW'}->($_[0]), $prop->{'CH'}->($_[1]), $prop->{'DotColor'}, $prop->{'CTable'}) };
}

sub lineMeth {
	my ($prop) = @_;
	return sub { MBF_DrawLine( $prop->{'CW'}->($_[0]), $prop->{'CH'}->($_[1]), $prop->{'CW'}->($_[2]), $prop->{'CH'}->($_[3]), $prop->{'DotColor'}, $prop->{'CTable'}) };
}

sub circleMeth {
	my ($prop) = @_;
	return sub { MBF_DrawEllipse( $prop->{'CW'}->($_[0]), $prop->{'CH'}->($_[1]), $_[2]*$prop->{'XRate'}, $_[2]*$prop->{'YRate'}, $prop->{'DotColor'}, $prop->{'CTable'}) };
}

sub polptMeth {
	my ($prop) = @_;
	return sub { MBF_SetColorData( $prop->{'CW'}->($_[0]*cos($_[1])), $prop->{'CH'}->($_[0]*sin($_[1])), $prop->{'DotColor'}, $prop->{'CTable'}) };
}

sub cleartableMeth {
	my ($prop) = @_;
	return sub { MBF_ClearColorTable( $prop->{'BackColor'}, $prop->{'CTable'}); drawXYline($prop); };
}

sub printMeth {
	my ($prop) = @_;
	return sub { MBF_PrintToBmp($_[0], $prop->{'CTable'}) };
}

sub drawXYline {
	my ($prop) = @_;
	if ($prop->{LineFlag}) {
		## X軸を描画する。
		MBF_DrawLine($prop->{'CW'}->($prop->{'XMin'}), $prop->{'CH'}->(0), $prop->{'CW'}->($prop->{'XMax'}), $prop->{'CH'}->(0), $prop->{'LineColor'}, $prop->{'CTable'});
		## Y軸を描画する。
		MBF_DrawLine($prop->{'CW'}->(0), $prop->{'CH'}->($prop->{'YMin'}), $prop->{'CW'}->(0), $prop->{'CH'}->($prop->{'YMax'}), $prop->{'LineColor'}, $prop->{'CTable'});
	}
}

1;
