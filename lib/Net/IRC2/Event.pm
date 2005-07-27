#
# Copyright 2005, Karl Y. Pradene <knotty@cpan.org> All rights reserved.
#

package Net::IRC2::Event        ;

use strict;      use warnings   ;
use Exporter                    ;

our @ISA       = qw( Exporter ) ;
our @EXPORT_OK = qw( new      ) ;
our @Export    = qw( new      ) ;

use vars qw( $VERSION )         ;
$VERSION =                          '0.01' ;

sub new        { shift and return bless { @_, 'timestamp'=>time }              }

sub dump       {
    my $self = shift                                                           ;
    print "------------\n"                                                     .
          ' Time     : ' .   $self->time.                    "\n"              .
          ' Orig     : ' .   $self->orig                                       .
          ' Prefix   : ' . ( $self->prefix     || 'UNDEF' ) ."\n"              .
          ' Server   : ' . ( $self->servername || 'UNDEF' ) ."\n"              . 
          ' Nick     : ' . ( $self->nick       || 'UNDEF' ) ."\n"              . 
          ' User     : ' . ( $self->user       || 'UNDEF' ) ."\n"              . 
          ' Host     : ' . ( $self->host       || 'UNDEF' ) ."\n"              .
          ' Command  : ' .   $self->command.                 "\n"              .
          ' Middle   : ' .   $self->middle.                  "\n"              . 
          ' Trailing : ' .   $self->trailing.              "\n\n"              ;
                                                                               }
 ##########
# Accessor #
 ##########
sub time       { return $_[0]->{'timestamp' }                                  }
sub orig       { return $_[0]->{   'orig'   }                                  }
sub prefix     { return $_[0]->{  'prefix'  } = $_[1] || $_[0]->{  'prefix'  } }

sub servername { return $_[0]->{'servername'} = $_[1] || $_[0]->{'servername'} }
sub nick       { return $_[0]->{   'nick'   } = $_[1] || $_[0]->{   'nick'   } }
sub user       { return $_[0]->{   'user'   } = $_[1] || $_[0]->{   'user'   } }
sub host       { return $_[0]->{   'host'   } = $_[1] || $_[0]->{   'host'   } }

sub command    { return $_[0]->{ 'command'  } = $_[1] || $_[0]->{ 'command'  } }

sub middle     {
    $_[0]->{ 'middle'  } = $_[1] || $_[0]->{'middle'}   || 'NOMIDDLE'          ;
    return ( wantarray ) ? $_[0]->{'middle'}   : "@{$_[0]->{'middle'}}"        ;
}
sub trailing   {
    $_[0]->{'trailing' } = $_[1] || $_[0]->{'trailing'} || 'NOTRAILING'        ;
    return ( wantarray ) ? $_[0]->{'trailing'} : "@{$_[0]->{'trailing'}}"      ;
                                                                               }
sub userhost   { warn 'TODO: userhost for '. ref $_[0]                         }

1;


__END__

=head1 NAME

Net::IRC2::Event - All messages are split and return as Event.

!!! UNDER PROGRAMMING !!! Wait a moment, please hold the line ...

Documentation in progress ...

=over

=item command

=item dump

=item host

=item middle

=item new

=item nick

=item orig

=item prefix

=item servername

=item time

=item trailing

=item user

=item userhost

=back

=head1 SEE ALSO

Perl modules working with IRC connections: Net::IRC, POE::Component::IRC

IRC Request For Comment 1459 L<http://www.ietf.org/rfc/rfc1459.txt?number=1459>

=head1 COPYRIGHT & LICENSE

Copyright 2005, Karl Y. Pradene <knotty@cpan.org> All rights reserved.

This program is released under the following license: GNU General Public License, version 2

This program is free software; you can redistribute it and/or modify it under the terms
of the GNU General Public License version 2 as published by the Free Software Foundation.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program;
if not, write to the 

 Free Software Foundation,
 Inc., 51 Franklin St, Fifth Floor,
 Boston, MA  02110-1301 USA

See L<http://www.fsf.org/licensing/licenses/gpl.html>

=cut
