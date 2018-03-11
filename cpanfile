requires 'perl', '5.008001';
requires 'Furl';
requires 'Smart::Args';
requires 'Class::Accessor::Lite';
requires 'Path::Class';
requires 'Crypt::CBC';


on 'test' => sub {
    requires 'Test::More', '0.98';
};

