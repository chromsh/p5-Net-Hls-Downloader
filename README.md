# NAME

Net::Hls::Downloader - It's new $module

# SYNOPSIS

    use Net::Hls::Downloader;

    my $client    = Net::Hls::Downloader->new;
    $client->download(
        url         => "http://example.com/playlist.m3u8",
        save_dir    => "video1",
    );

# DESCRIPTION

Net::Hls::Downloader is a client of HTTP Live Streaming.

# METHOD

## new(%args)

creates object

- agent :Str = "UA"

    user agent

- timeout :Int = 10

    timeout seconds

## download(%args)

start downloading

- url :Str = "master/media playlist url"

    HLS endpoint url

- save\_dir :Str = "path/to/dir"

    save directory

# LICENSE

Copyright (C) chrom.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

chrom
