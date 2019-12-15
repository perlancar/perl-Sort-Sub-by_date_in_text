package Sort::Sub::by_date_in_text;

# AUTHORITY
# DATE
# DIST
# VERSION

use 5.010001;
use strict;
use warnings;

use DateTime;

our $DATE_EXTRACT_MODULE = $ENV{PERL_DATE_EXTRACT_MODULE} // "Date::Extract";

sub meta {
    return {
        v => 1,
        summary => 'Sort by date found in text or (if no date is found) ascibetically',
    };
}

sub gen_sorter {
    my ($is_reverse, $is_ci) = @_;

    my $re_is_num = qr/\A
                       [+-]?
                       (?:\d+|\d*(?:\.\d*)?)
                       (?:[Ee][+-]?\d+)?
                       \z/x;

    my ($parser, $code_parse);
    my $module = $DATE_EXTRACT_MODULE;
    $module = "Date::Extract::$module" unless $module =~ /::/;
    if ($module eq 'Date::Extract') {
        require Date::Extract;
        $parser = Date::Extract->new();
        $code_parse = sub { $parser->extract($_[0]) };
    } elsif ($module eq 'Date::Extract::ID') {
        require Date::Extract::ID;
        $parser = Date::Extract::ID->new();
        $code_parse = sub { $parser->extract($_[0]) };
    } elsif ($module eq 'DateTime::Format::Alami::EN') {
        require DateTime::Format::Alami::EN;
        $parser = DateTime::Format::Alami::EN->new();
        $code_parse = sub { my $h; eval { $h = $parser->parse_datetime($_[0]) }; $h };
    } elsif ($module eq 'DateTime::Format::Alami::ID') {
        require DateTime::Format::Alami::ID;
        $parser = DateTime::Format::Alami::ID->new();
        $code_parse = sub { my $h; eval { $h = $parser->parse_datetime($_[0]) }; $h };
    } else {
        die "Invalid date extract module '$module'";
    }
    eval "use $module"; die if $@;

    sub {
        no strict 'refs';

        my $caller = caller();
        my $a = @_ ? $_[0] : ${"$caller\::a"};
        my $b = @_ ? $_[1] : ${"$caller\::b"};

        my $cmp;

        # XXX cache

        my $dt_a = $code_parse->($a);
        warn "Found date $dt_a in $a\n" if $ENV{DEBUG} && $dt_a;
        my $dt_b = $code_parse->($b);
        warn "Found date $dt_b in $b\n" if $ENV{DEBUG} && $dt_b;

        {
            if ($dt_a && $dt_b) {
                $cmp = DateTime->compare($dt_a, $dt_b);
                last if $cmp;
            } elsif ($dt_a && !$dt_b) {
                $cmp = -1;
                last;
            } elsif (!$dt_a && $dt_b) {
                $cmp = 1;
                last;
            }

            if ($is_ci) {
                $cmp = lc($a) cmp lc($b);
            } else {
                $cmp = $a cmp $b;
            }
        }

        $is_reverse ? -1*$cmp : $cmp;
    };
}

1;
# ABSTRACT:

=for Pod::Coverage ^(gen_sorter|meta)$

=head1 DESCRIPTION

The generated sort routine will sort by date found in text (extracted using
L<Date::Extract>) or (f no date is found in text) ascibetically. Items that have
a date will sort before items that do not.


=head1 ENVIRONMENT

=head2 DEBUG => bool

If set to true, will print stuffs to stderr.

=head2 PERL_DATE_EXTRACT_MODULE => str

Can be set to L<Date::Extract>, L<Date::Extract::ID>, or
L<DateTime::Format::Alami::EN>, L<DateTime::Format::Alami::ID>.
