package Net::Hls::Downloader::Tool;
use strict;
use warnings;
use 5.010;

use Exporter qw/import/;

our @EXPORT	= qw/parse_non_value parse_number parse_comma_separated_values/;

sub parse_non_value {
}

sub parse_number {
	my ($str)	= @_;
	return $str - 0;
}


# BANDWIDTH=940598,CODECS="avc1.66.30,mp4a.40.2",RESOLUTION=640x360
# とかに対応できるようにする
sub parse_comma_separated_values {
	my ($str)	= @_;

	my @ret;

	my $in_quote	= 0;
	my $val	= "";
	for my $ch (split(//, $str)) {
		if ($in_quote) {
			if ($ch eq '"') {
				$in_quote	= 0;
			}
			else {
				$val	.= $ch;
			}
			next;
		}

		if ($ch eq '"') {
			$in_quote	= 1;
			next;
		}

		if ($ch eq "=" or $ch eq ",") {
			push @ret, $val;
			$val	= "";
			next;
		}
		$val	.= $ch;
	}
	
	push @ret, $val if (@ret % 2 == 1);

	return {@ret};
}


1;
