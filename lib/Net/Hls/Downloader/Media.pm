package Net::Hls::Downloader::Media;
use strict;
use warnings;
use 5.010;


use Smart::Args;
use Class::Accessor::Lite(
	new => 0,
	ro	=> [qw/segment/],
);

use Net::Hls::Downloader::Tool;

sub new {
	args
	my $class,
		my $base_url	=> "Str",
		my $content		=> "Str",
	;
	my $self	= _parse(base_url => $base_url, content => $content) || {};
	return bless $self, $class;
}


sub _parse {
	args
		my $base_url	=> "Str",
		my $content		=> "Str",
	;

	my $lines	= [split(/\n/, $content)];
	return if not $lines->[0] =~ /^#EXTM3U/;

	my $defined_tags	= {
		# basic tags
		"EXT-X-VERSION"				=> \&parse_number,

		# media only tags
		"EXT-X-TARGETDURATION"		=> \&parse_number,
		"EXT-X-MEDIA-SEQUENCE"		=> \&parse_number,
		"EXTINF"					=> \&parse_comma_separated_values,
		"EXT-X-KEY"					=> \&parse_comma_separated_values,

		# media or master tags
	};

	my $version		= 1;
	my $segments	= [];
	my $key;
	my $tags		= {};
	my $follow_media	= 0;
	for my $line (@$lines) {
		chomp($line);
		next if $line =~ /^\w+$/;
		if ($line =~ /^#([^:]+):(.+)$/) {
			# tag
			my $tag		= $1;
			my $value	= $2;

			my $func	= $defined_tags->{ $tag };
			# skip unknown tags
			next if not $func;
			my $parsed_value	= $func->($value);
			if ($tag eq "EXT-X-VERSION") {
				$version	= $parsed_value;
			}
			elsif ($tag eq "EXTINF") {
				$follow_media	= 1;
			}
			elsif ($tag eq "EXT-X-KEY") {
				$key	= $parsed_value;
			}
			else {
				$tags->{ $tag }	||= [];
				push @{$tags->{ $tag }}, $parsed_value;
			}
		}
		elsif ($follow_media) {
			# segment file
			if ($line !~ /^http/) {
				$line	= $base_url	. $line;
			}
			push @$segments, $line;
			$follow_media	= 0;
		}
	}

	return {
		version	=> $version,
		segment	=> $segments,
		key		=> $key,
	};
}


1;
