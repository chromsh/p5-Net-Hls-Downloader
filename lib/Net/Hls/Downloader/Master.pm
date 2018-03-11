package Net::Hls::Downloader::Master;
use strict;
use warnings;
use 5.010;


use Smart::Args;
use Class::Accessor::Lite(
	new => 0,
	ro	=> [qw/playlist/],
);


sub new {
	args
	my $class,
		my $content	=> "Str",
	;
	my $self	= _parse($content) || {};
	return bless $self, $class;
}


sub is_master_playlist {
	args
	my $self,
	;

	return defined $self->playlist && @{$self->playlist} > 0;
}


sub _parse {
	my ($content)	= @_;

	my $lines	= [split(/\n/, $content)];
	return if not $lines->[0] =~ /^#EXTM3U/;

	my $defined_tags	= {
		# basic tags
		"EXT-X-VERSION"				=> \&_parse_number,

		# master only tags
		"EXT-X-MEDIA"				=> \&_parse_comma_separated_values,
		"EXT-X-STREAM-INF"			=> \&_parse_comma_separated_values,
		"EXT-X-I-FRAME-STREAM-INF"	=> \&_parse_comma_separated_values,
		"EXT-X-SESSION-DATA"		=> \&_parse_comma_separated_values,
		"EXT-X-SESSION-KEY"			=> \&_parse_comma_separated_values,

		# media or master tags
		"EXT-X-INDEPENDENT-SEGMENTS"=> \&_parse_non_value, # has no value
		"EXT-X-START"				=> \&_parse_comma_separated_values,
	};

	my $version		= 1;
	my $playlists	= [];
	my $tags		= [];
	for my $line (@$lines) {
		chomp($line);
		next if $line =~ /^\w+/;
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
			else {
				$tags->{ $tag }	||= [];
				push @{$tags->{ $tag }}, $parsed_value;
			}
		}
		elsif ($line =~ /\.m3u8?$/) {
			push @$playlists, {
				url	=> $line,
				tag	=> $tags,
			}
		}
		else {
			# maybe not master playlist
			return;
		}
	}

	return {
		version		=> $version,
		playlist	=> $playlists,
	};
}


sub _parse_number {
	my ($str)	= @_;
	return $str - 0;
}


sub _parse_comma_separated_values {
	my ($str)	= @_;

	#note, if values have comma, will occurs error
	
	return {
		map {split(/=/, $_)}
		split(/,/, $str)
	};
}
