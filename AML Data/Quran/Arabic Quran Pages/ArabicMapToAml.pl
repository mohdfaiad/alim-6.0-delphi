use strict;

my $inputFile = 'e:\projects\alim\aml data\quran\Arabic Quran Pages\ArabicQuranMap.txt';
my $outputFile = 'e:\projects\alim\aml data\quran\Arabic Quran Pages.aml';

my $suras = {};
my $pages = {};
my $maxPage = 0;

open(MAP, $inputFile) || die "Couldn't open $inputFile: $!\n";

# skip the first line (it's the header)
my $ignore = <MAP>;

while(<MAP>)
{
	next if m/^\s*$/;
	
	my ($page, $sura, $ayah, $ruku, $xstart, $ystart, $xend, $yend) =
		split(/\s+/);

	my $data =
	{
		page => $page,
		sura => $sura,
		ayah => $ayah,
		xstart => $xstart,
		ystart => $ystart,
		xend => $xend,
		yend => $yend,
	};
	$suras->{$sura}->{$ayah} = $data;
	push(@{$pages->{$page}}, $data);
	
	my $pageNum = int($page);
	$maxPage = $pageNum if $pageNum > $maxPage;
}
close(MAP);

open(AML, ">$outputFile") || die "Couldn't create $outputFile: $!\n";
print AML "<?xml version=\"1.0\"?>\n";
print AML "<aml comment=\"Generated by ArabicMapToAml.pl. Do not modify.\">\n";
print AML <<'END_AML';
<quran>
	<catalog id="QAP">
		<names full="Al-Qur'an in Arabic (Page Images)" short="Quran Pages" />
		<content type="quran" subtype="images" imgfmt="QPage%.3d.gif" imgwidth="456" lineheight="45" minlineheight="25" />
		<shortcuts type="external">
			<category name="Quran">
				<shortcut sortkey="001"/>
			</category>
		</shortcuts>
	</catalog>
	
END_AML

for(my $s = 1; $s <= 114; $s++)
{
	print AML "\t<sura num=\"$s\">\n";
	for(my $a = 1; $a <= 286; $a++)
	{
		goto NOMORE if ! exists $suras->{$s}->{$a};
		my $d = $suras->{$s}->{$a};
  		print AML "\t\t<ayah num=\"$a\" page=\"$d->{'page'}\" xstart=\"$d->{'xstart'}\" ystart=\"$d->{'ystart'}\" xend=\"$d->{'xend'}\" yend=\"$d->{'yend'}\"/>\n";
	}
	
	NOMORE:
	print AML "\t</sura>\n";
}

for(my $p = 1; $p <= $maxPage; $p++)
{
	print AML "\t<page num=\"$p\">\n";
	foreach (@{$pages->{$p}})
	{
		my $d = $_;
  		print AML "\t\t<ayah sura=\"$d->{'sura'}\" num=\"$d->{'ayah'}\" xstart=\"$d->{'xstart'}\" ystart=\"$d->{'ystart'}\" xend=\"$d->{'xend'}\" yend=\"$d->{'yend'}\"/>\n";
	}
	print AML "\t</page>\n";
}

print AML "</quran>\n";
print AML "</aml>\n";

close(AML);