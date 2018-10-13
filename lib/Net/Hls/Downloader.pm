package Net::Hls::Downloader;
use 5.008001;
use strict;
use warnings;
our $VERSION = "0.01";

use Furl;
use Smart::Args;
use Crypt::CBC;
use Path::Class;
use Class::Accessor::Lite(
	new	=> 0,
	ro	=> [qw/agent timeout/],

);


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

	my $f	= Furl->new(
		agent	=> $self->agent,
		timeout	=> $self->timeout,
	);

	my $res	= $f->get($url);
	return if not $res->is_success;

	my $master	= Net::Hls::Downloader::Master->new($res->body);
	# check if master playlist
	
	if ($master->is_master_playlist) {
		my $media_playlist_urls	= $master->playlist;
		# choose most high quality video/audio
	}

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

