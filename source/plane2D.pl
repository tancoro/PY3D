##_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
## Prefix Is PL2
##_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
use strict;
require '..\PY3D\makeBMP2D.pl';


##/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
## XY���ʃI�u�W�F�N�g�쐬�֐�
##
##�y���\�b�h�����z
## $obj->{'setcolor'}->(c)         /* DotColor �� c�ɕύX����                       */
## $obj->{'setbackcolor'}->(c)     /* BackColor �� c�ɕύX����                      */
## $obj->{'setxrate'}->(xmax,xmin) /* xMax, xMin �����ꂼ�� xmax, xmin �ɕύX����   */
## $obj->{'setyrate'}->(ymax,ymin) /* yMax, yMin �����ꂼ�� ymax, ymin �ɕύX����   */
## $obj->{'point'}->(x,y)          /* (x,y)�ɓ_��ł�                               */
## $obj->{'polpt'}->(r,��)         /* �ɍ��W�l(r,��)�ɓ_��ł�(�Ƃ̓��W�A��)        */
## $obj->{'line'}->(x1,y1,x2,y2)   /* (x1,y1)-(x2,y2)�ɐ�������                     */
## $obj->{'circle'}->(x,y,r)       /* (x,y)�ɔ��ar�̉~��`��                        */
## $obj->{'cleartable'}->()        /* XY���ʂ��N���A����                            */
## $obj->{'print'}->(filename)     /* filename�̃t�@�C����bmp���o�͂���             */
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

	## XY����`�悷��B
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
		## X����`�悷��B
		MBF_DrawLine($prop->{'CW'}->($prop->{'XMin'}), $prop->{'CH'}->(0), $prop->{'CW'}->($prop->{'XMax'}), $prop->{'CH'}->(0), $prop->{'LineColor'}, $prop->{'CTable'});
		## Y����`�悷��B
		MBF_DrawLine($prop->{'CW'}->(0), $prop->{'CH'}->($prop->{'YMin'}), $prop->{'CW'}->(0), $prop->{'CH'}->($prop->{'YMax'}), $prop->{'LineColor'}, $prop->{'CTable'});
	}
}

1;
