package Net::Hls::Downloader;
use 5.008001;
use strict;
use warnings;
our $VERSION = "0.01";

use Furl;
use File::Basename;
use Smart::Args;
use Crypt::CBC;
use Path::Class;
use Class::Accessor::Lite(
	new	=> 0,
	ro	=> [qw/agent timeout/],

);

use Net::Hls::Downloader::Master;
use Net::Hls::Downloader::Media;


sub new {
	args
	my $class,
		my $agent	=> {isa => "Maybe[Str]", optional => 1, default => "net-hls-downloader/$VERSION"},
		my $timeout	=> {isa => "Maybe[Int]", optional => 1, default => 10},
	;

	my $self	= {
		agent	=> $agent,
		timeout	=> $timeout,
	};

	return bless $self, $class;
}

sub download {
	args
	my $self,
		my $url			=> "Str",
		my $save_dir	=> "Str",
	;

	my $content	= $self->_get_content(url => $url);
	return if not $content;

	my $base_url	= $self->_base_url(url => $url);
	my $master	= Net::Hls::Downloader::Master->new(base_url => $base_url, content => $content);
	# check if master playlist
	
	my $media_playlist;
	if ($master->is_master_playlist) {
		my $media_playlist_urls	= $master->playlist;
		# choose most high quality video/audio
		$media_playlist	= $media_playlist_urls->[0]->{ url };
	}
	else {
		$media_playlist	= $url;
	}

	# download
	$self->_download_media(url => $media_playlist, save_dir => $save_dir);
}

sub _get_content {
	args
	my $self,
		my $url	=> "Str",
	;

	my $f	= Furl->new(
		agent	=> $self->agent,
		timeout	=> $self->timeout,
	);
	my $res	= $f->get($url);
	return if not $res->is_success;
	return $res->body;
}

sub _download_media {
	args
	my $self,
		my $url			=> "Str",
		my $save_dir	=> "Str",
	;

	my $content	= $self->_get_content(url => $url);
	return if not $content;

	my $base_url	= $self->_base_url(url => $url);
	my $media	= Net::Hls::Downloader::Media->new(base_url => $base_url, content => $content);

	my $dir	= dir($save_dir);
	$dir->mkpath;

	for my $segment_url (@{ $media->segment }) {
		my $content	= $self->_get_content(url => $segment_url);
		return if not $content;
		my $filename	= basename($segment_url);
		$dir->file($filename)->spew($content);
	}
}

sub _base_url {
	args
	my $self,
		my $url	=> "Str",
	;
	my ($base_url)	= ($url =~ m|(^.*/)#?.*|);
	return $base_url;
}


sub _is_master {
	my $content	= shift;

	die "neend impl";
}


sub _parse_master_playlist {
	my $content	= shift;

	die "need impl";
}


1;
__END__

=encoding utf-8

=head1 NAME

Net::Hls::Downloader - It's new $module

=head1 SYNOPSIS

    use Net::Hls::Downloader;

    my $client    = Net::Hls::Downloader->new;
    $client->download(
        url         => "http://example.com/playlist.m3u8",
        save_dir    => "video1",
    );

=head1 DESCRIPTION

Net::Hls::Downloader is a client of HTTP Live Streaming.

=head1 METHOD

=head2 new(%args)

creates object

=over 4

=item agent :Str = "UA"

user agent

=item timeout :Int = 10

timeout seconds

=back


=head2 download(%args)

start downloading

=over 4

=item url :Str = "master/media playlist url"

HLS endpoint url

=item save_dir :Str = "path/to/dir"

save directory

=back


=head1 LICENSE

Copyright (C) chrom.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

chrom

=cut

