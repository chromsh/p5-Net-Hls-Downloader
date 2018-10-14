requires 'perl', '5.010';
requires 'Furl';
requires 'Smart::Args';
requires 'Class::Accessor::Lite';
requires 'Path::Class';
requires 'Crypt::CBC';
requires 'Test::Fake::HTTPD';


on 'test' => sub {
    requires 'Test::More', '0.98';
};

