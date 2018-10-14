use strict;
use warnings;
use Data::Dumper;
use Test::More 0.98;
use Test::Fake::HTTPD;
use Path::Class;
use File::Spec;
use File::Basename;
use File::Temp qw/tempdir/;

use Net::Hls::Downloader;

my $httpd;
$httpd	= run_http_server {
	my ($req)	= @_;

	my $uri		= $req->uri;
	my $filename	= basename($uri);
	my $file	= file(__FILE__)->dir->subdir("sample")->file($filename);
	my $body	= $file->slurp;

	if ($uri =~ /chunklist/) {
		# aes-key url
		my $host	= $req->headers->{host};
		$body	=~ s|__KEY_URL__|http://${host}/key.m3u8key|m;
	}

	return [200, ["Content-Type" => "application/vnd.apple.mpegurl"], [$body]];
};

my $tempdir	= tempdir(CLEANUP => 1);

my $d	= Net::Hls::Downloader->new(decrypt => 0);
$d->download(url => $httpd->endpoint . "/1_relative_master.m3u8", save_dir => $tempdir);

is(-e dir($tempdir)->file("media_0.ts"), 1);
is(-e dir($tempdir)->file("media_1.ts"), 1);


done_testing;

