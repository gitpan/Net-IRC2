#
# Copyright 2005, Karl Y. Pradene <knotty@cpan.org> All rights reserved.
#
#

package Net::IRC2::Connection   ;

use strict;      use warnings   ;
use Exporter                    ;
use IO::Socket::INET            ;
use Parse::RecDescent           ;
use Net::IRC2::Event            ;

our @ISA       = qw( Exporter ) ;
our @EXPORT_OK = qw( new      ) ;
our @Export    = qw( new      ) ;

use vars qw( $VERSION )         ;
$VERSION = '0.00_03'            ;

my $DEBUG = 10 ;
$::RD_HINT  =   $DEBUG        ? 1 : undef     ;
$::RD_TRACE = ( $DEBUG > 10 ) ? 1 : undef     ;


sub new {
    my $class = shift                         ;
    my $self = bless {@_}                     ;
    $self->split_uri if exists $self->{'uri'} ;

    my $sock = $self->socket( IO::Socket::INET->new( PeerAddr => $self->server ,
						     PeerPort => $self->port   ,
						     Proto    => 'tcp'         ) ) ;
    $sock->send( 'PASS ' . $self->pass . "\n"                    .
                 'NICK ' . $self->nick . "\n"                    .
                 'USER ' . $self->nick . ' foo.bar.quux '        .
		 $self->server . ' :' . $self->realname . "\n" ) ;
    return $self                                                 ;
}

sub start {
    my ( $self, $grammar, $event ) = ( @_, undef ) ;
    my $sock = $self->socket;
    my $parser = new Parse::RecDescent( $grammar ) ;
    while ( <$sock> ) {
	$event = $parser->message( $_ ) or die 'Parse error';
	if ( $event->command eq 'PING' ) {
	    $sock->send( 'PONG ' . $sock->sockhost . ' ' . $event->middle. "\n" );
	}
	next if $event->command eq '372' and $DEBUG ;
	$event->dump if $DEBUG ;
	if ( $event->command eq '001' ) {
	    $parser->Replace( "servername: '" . $event->servername . "'" ) ;
	}
	$self->callback( $event ) ;
    }
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
sub mode {
    my $sock = $_[0]->socket                                                     ;
    shift and $sock->send( 'MODE ' . "@_\n" )                                    ;
                                                                                 }
sub join {
    my $sock = $_[0]->socket                                                     ;
    shift and $sock->send( 'JOIN ' . "@_\n" )                                    ;
                                                                                 }



############
# Accessor #
############
sub nick     { return   $_[0]->{'nick'}     = $_[1] || $_[0]->{'nick'}     || die 'no nick'    }
sub pass     { return   $_[0]->{'pass'}     = $_[1] || $_[0]->{'pass'}     || '2 young 2 die'  }
sub port     { return   $_[0]->{'port'}     = $_[1] || $_[0]->{'port'}     || 6667             }
sub user     { return   $_[0]->{'user'}     = $_[1] || $_[0]->{'user'}     || 'void'           }
sub realname { return   $_[0]->{'realname'} = $_[1] || $_[0]->{'realname'} || 'use Net::IRC-2' }
sub server   { return   $_[0]->{'server'}   = $_[1] || $_[0]->{'server'}   || 'localhost'      }
sub socket   { return   $_[0]->{'socket'}   = $_[1] || $_[0]->{'socket'}   || undef            }
sub callback { return   $_[0]->{'callback'} = $_[1]   if ref $_[1] eq 'CODE'                   ;
               return &{$_[0]->{'callback'}}( $_[1] ) if ref $_[1] eq 'Net::IRC2::Events'      ;
                                                                                               }
sub add_handler { }
*add_global_handler = \&Net::IRC2::add_handler;

1;
