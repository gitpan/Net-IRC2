#
# Copyright 2005, Karl Y. Pradene <knotty@cpan.org> All rights reserved.
#
#

package Net::IRC2::Connection   ;

use strict;      use warnings   ;
use Exporter                    ;
use IO::Socket::INET ()         ;
use Parse::RecDescent           ;
use Net::IRC2::Event            ;

our @ISA       = qw( Exporter ) ;
our @EXPORT_OK = qw( new      ) ;
our @Export    = qw( new      ) ;

use vars qw( $VERSION $DEBUG)   ;
$VERSION =                          '0.07' ;
$DEBUG   =                               0 ;
$::RD_HINT  =   $DEBUG         ? 1 : undef ;
$::RD_TRACE = ( $DEBUG >= 10 ) ? 1 : undef ;


sub new {
    my $class = shift                         ;
    my $self = bless {@_}                     ;
    $self->split_uri if exists $self->{'uri'} ;

    my $sock = $self->socket( IO::Socket::INET->new( PeerAddr => $self->server ,
						     PeerPort => $self->port   ,
						     Proto    => 'tcp'         )
			    ) or ( warn "Can't bind : $@\n" and return undef ) ;
    $sock->send( 'PASS ' . $self->pass . "\n"                    .
                 'NICK ' . $self->nick . "\n"                    .
                 'USER ' . $self->nick . ' foo.bar.quux '        .
		 $self->server . ' :' . $self->realname . "\n" ) ;
    $self->parser(  new Parse::RecDescent( $self->grammar ) ) ;

    return $self                                                 ;
}

sub start {
#    my ( $self, $grammar, $event ) = ( @_, undef ) ;
#    my $sock = $self->socket;
#    1 while $self->do_one_loop ;
    1 while $_[0]->do_one_loop ;
}
sub do_one_loop {
    my $self = shift;
    my ( $sock, $parser ) = ( $self->socket, $self->parser );
    my $line = <$sock>;
    my $event = $parser->message( $line ) || warn "Parse error\n$line" ;
    if ( $event->command eq 'PING' ) {
	$sock->send( 'PONG ' . $sock->sockhost . ' ' . $event->middle. "\n" );
    }
    if ( $event->command eq '001' ) {
	$parser->Replace( "servername: '" . $event->servername . "'" ) ;
    }
    if (      defined $self->{ 'callback' }{ $event->command } ) {
	           &{ $self->{ 'callback' }{ $event->command } } ( $self, $event ) ;
    } elsif ( defined $self->{ 'callback' }{      'ALL'      } ) {
	           &{ $self->{ 'callback' }{      'ALL'      } } ( $self, $event ) ;
    }
    no strict 'refs';
    &{'cb'.$event->command}($self, $event) if defined &{'cb'.$event->command} ;
    return $event;
}


# http://www.w3.org/Addressing/draft-mirashi-url-irc-01.txt
# http://www.mozilla.org/projects/rt-messaging/chatzilla/irc-urls.html
# irc:[<connect-to>[(/<target>[<modifiers>][<query-string>]|<modifiers>)]]
# http://www.gbiv.com/protocols/uri/rfc/rfc3986.html
# irc://nick!user@server:port/
sub split_uri {
    my $self = shift                                                             ;
    if ( exists $self->{'uri'} ) {
	$self->{'uri'} =~ m|^irc://(.+?)!(.+?)@(.+?):(\d+)/|                     ;
	$self->nick($1); $self->user($2); $self->server($3); $self->port($4)     ;
	return 0                                                                 ;
    }
                                                                                 }

 ##############
# Commands IRC #
 ##############
sub mode    {
    my $sock = $_[0]->socket                                                     ;
    shift and $sock->send( 'MODE ' . "@_\n" )                                    }
sub join    {
    my $sock = $_[0]->socket                                                     ;
    shift and $sock->send( 'JOIN ' . "@_\n" )                                    }
sub privmsg {
    my $sock = $_[0]->socket                                                     ;
    shift and $sock->send( 'PRIVMSG ' . "@_\n" )                                 }
sub sl      {
    my $sock = $_[0]->socket                                                     ;
    shift and $sock->send( "@_\n" )                                              }



############
# Accessor #
############
sub nick     { return   $_[0]->{'Nick'}     = $_[1] || $_[0]->{'Nick'}     || die 'no nick'    }
sub pass     { return   $_[0]->{'Password'} = $_[1] || $_[0]->{'Password'} || '2 young 2 die'  }
sub port     { return   $_[0]->{'Port'}     = $_[1] || $_[0]->{'Port'}     || 6667             }
sub user     { return   $_[0]->{'user'}     = $_[1] || $_[0]->{'user'}     || 'void'           }
sub realname { return   $_[0]->{'realname'} = $_[1] || $_[0]->{'realname'} || 'use Net::IRC2'  }
sub server   { return   $_[0]->{'Server'}   = $_[1] || $_[0]->{'Server'}   || 'localhost'      }
sub socket   { return   $_[0]->{'socket'}   = $_[1] || $_[0]->{'socket'}   || undef            }
sub parser   { return   $_[0]->{'parser'}   = $_[1] || $_[0]->{'parser'}                       }
sub grammar  { return   $_[0]->{'grammar'}  = $_[1] || $_[0]->{'grammar'}                      }
sub callback { return   $_[0]->{'callback'} = $_[1]   if ref $_[1] eq 'CODE'                   ;
               return &{$_[0]->{'callback'}}( $_[1] ) if ref $_[1] eq 'Net::IRC2::Events'      ;
                                                                                               }



sub dispatch {
    
}

sub add_default_handler { 
    $_[0]->add_handler( [ 'ALL' ], $_[1] )  }

sub add_handler { 
    my ( $self, $commands, $callback ) = @_ ;
    $commands = [ $commands ] unless ref $commands eq 'ARRAY';
    print 'Mapping callback : ' .
	( map { $self->{'callback'}{$_} = $callback } @$commands ).
	"\n";
#    print CORE::join ( ' , ', keys ( %{$self->{'callback'}} ) ) . "\n";
}
*add_global_handler = \&Net::IRC2::add_handler;

1;


__END__

=head1 NAME

Net::IRC2::Connection - One connection to an IRC server.

!!! UNDER PROGRAMMING !!! Wait a moment, please hold the line ...

Documentation in progress ...

=over

=item new

=item add_handler

=item add_default_handler

=item callback

=item start

=item do_one_loop

=item grammar

=item parser

=item sl

=item nick

=item pass

=item port

=item realname

=item server

=item socket

=item split_uri

=item user

=item join

=item mode

=item privmsg

=item dispatch

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
