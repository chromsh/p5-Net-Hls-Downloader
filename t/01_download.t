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

my $httpd	= run_http_server {
	my ($req)	= @_;

	my $uri		= $req->uri;
	my $filename	= basename($uri);
	my $file	= file(__FILE__)->dir->subdir("sample")->file($filename);

	return [200, ["Content-Type" => "application/vnd.apple.mpegurl"], [$file->slurp]];
};

my $tempdir	= tempdir(CLEANUP => 1);

my $d	= Net::Hls::Downloader->new;
$d->download(url => $httpd->endpoint . "/1_relative_master.m3u8", save_dir => $tempdir);

is(-e dir($tempdir)->file("media_0.ts"), 1);
is(-e dir($tempdir)->file("media_1.ts"), 1);


done_testing;

