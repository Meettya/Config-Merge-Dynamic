package Config::Merge::Dynamic;

use 5.008;
use strict;
use warnings FATAL => 'all', NONFATAL => 'redefine';
use utf8;

use parent 'Config::Merge';

use Carp qw/croak/;             # die beautiful
use Data::Diver qw/DiveVal/;    # its for correct path creation

=head1 NAME

Config::Merge::Dynamic - load a configuration directory tree containing
YAML, JSON, XML, Perl, INI or Config::General files AND alter it in runtime.

=head1 VERSION

Version 0.06

=cut

our $VERSION = '0.06';
$VERSION = eval $VERSION;

=head1 SYNOPSIS

Example how to add (or replace, if values exists) values in config object:

	use Config::Merge::Dynamic;
	my $config = Config::Merge->new('/path/to/config');	
	my $all_data = $config->inject( 'key_one.key_two.keyn', { foo =>'bar' } );
	
Or available one-argument calling, without 'path', all data will injected to root:

	my $all_data2 = $config->inject(
	  {
	    key_one => {
	      key_two => {
	        keyn => {
	          foo => 'bar'
	        }
	      }
	    }
	  }
	);

Also available to change single scalar value

	my $all_data3 = $config->inject( 'key_one.key_two.keyn.foo', 'bar' );

And deal with array like this
	
	my $all_data3 = $config->inject( 'key_three.1', 'bar' );
	# now $all_data3 = { key_three => [ undef, 'bar' ], ... };

=head1 DESCRIPTION

This module expand L<Config::Merge> to make available to add/replace config data in config object in runtime.
	
=head1 SUBROUTINES/METHODS

L<Config::Merge::Dynamic> inherits all methods from L<Config::Merge> and implements
the following new ones.

=head2 C<inject()>

   $config = $config->inject( 'key_one.key_two.keyn', { foo =>'bar' } );

inject() are insert to object config new data,
and context-sensetive returns of all config data, or nothing if called in void context.

First argument - path is optional, second may be any type.

=cut

#===================================
sub inject {
#===================================
    my $self = shift;
    my $what = pop; # this is for optional arguments, with /where/ and without it
    my $where = shift;

    unless ( defined $what ) {    # NOP in void args
        return &_context_sensetive_return($self);
    }

    if ( defined $where ) {

        my @data_path = $self->_path_resolution($where);
        if ( $#data_path < 0 ) {
            croak sprintf qq(path |%s| can`t be resoluted, die ), $where;
        }

        # move data to /where/ place
        my $new_what = {};
        DiveVal( $new_what, @data_path ) = $what;
        $what = $new_what;
    }

    # merge together
    my $config = \%{ $self->C() };
    $config = $self->_merge_hash( $config, $what );
    $self->clear_cache();

    return &_context_sensetive_return($self);
}

=begin comment _path_resolution

subroutine resolve path from dot-notation to list for DiveVal.
May be laiter you are want to use another one delimetter, so it`s there.

=end comment

=cut

#===================================
sub _path_resolution {
#===================================
    my $self        = shift;
    my $path_string = shift;

    return split /\./, $path_string;
}

=begin comment _context_sensetive_return

subroutine for context-sensetive returns
any subs use goto &_context_sensetive_return to handle caller livel
its a little black magic

=end comment

=cut

#===================================
sub _context_sensetive_return {
#===================================
    my $self = shift;

    return unless defined wantarray;    # void call

    my $config = \%{ $self->C() };

    return
        wantarray && ref($config) eq 'HASH'  ? %{$config}
      : wantarray && ref($config) eq 'ARRAY' ? @{$config}
      :                                        $config;

}

=head1 CAVEAT

All may go strange if you inject mismatch type of values in wrong place - handle your data with care.

=head1 EXPORT

Nothing by default.

=head1 AUTHOR

Meettya, C<< <meettya at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-config-merge-dynamic at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Config-Merge-Dynamic>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 DEVELOPMENT

=head2 Repository

    https://github.com/Meettya/Config-Merge-Dynamic
    
=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Config::Merge::Dynamic


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Config-Merge-Dynamic>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Config-Merge-Dynamic>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Config-Merge-Dynamic>

=item * Search CPAN

L<http://search.cpan.org/dist/Config-Merge-Dynamic/>

=back


=head1 ACKNOWLEDGEMENTS

Thanks to Clinton Gormley, E<lt>clinton@traveljury.comE<gt> for original Config::Merge.

=head1 LICENSE AND COPYRIGHT

Copyright 2011 Meettya.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1;    # End of Config::Merge::Dynamic
