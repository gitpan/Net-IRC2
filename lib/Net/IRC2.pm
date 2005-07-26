#
#.Copyright 2005, Karl Y. Pradene <knotty@cpan.org> All rights reserved.
#

package Net::IRC2;

use strict;      use warnings   ;
use Exporter                    ;
use Carp                        ;

our @ISA       = qw( Exporter ) ;
our @EXPORT_OK = qw( new      ) ;
our @Export    = qw( new      ) ;

use vars qw( $VERSION $DEBUG )  ;
$VERSION =                             '0.00_04' ;
$DEBUG   =                   10 ;

=head1 NAME

Net::IRC2 - Client interface to the Internet Relay Chat protocol.

=cut
#=head1 VERSION

#This is the documentation for the Version 0.00_04 of Net::IRC2 , released July 26, 2005.

=pod

=head1 SYNOPSIS

 use Net::IRC2                                                        ;
 my $bot  = new Net::IRC2                                             ;
 my $conn = $bot->newconn( uri => 'irc://Nick!User@localhost:6667/' ) ; 
 $conn->mode(    $conn->nick, '+B' )                                  ;
 $conn->mode(    '#Ailleurs +m'    )                                  ;
 $bot->callback( \&process_event   )                                  ;
 $bot->start                                                          ;
 ...

=head1 DESCRIPTION

This module will provide you an access to the IRC protocol suitable to write your own IRC-Bots, or your
IRC Client. The API will provide you the sames functions than Net::IRC, so change should be trivial.

=head1 FUNCTIONS

=over

=item new

The constructor, takes no argument. Return a Net::IRC2 object. It's your IRC-Bot.

=cut

sub new         { shift and return bless {@_} } ;

=pod

=item newconn

Make a new connection. Like Net::IRC + can process an URI : irc://Nick!User@localhost:6667/ 

=item callback

=item start

=back

=cut



sub newconn     {
    use Net::IRC2::Connection;
    my $self = shift;
    return $self->connections( Net::IRC2::Connection->new( @_ ) );
}
sub start       {
    use threads;
    my $self = shift;
    my @threads = map { threads->create( { $_->start( $self->irc_grammar ) } ) } @{$self->connections};
    map {$_->join} @threads;
}

sub connections {
    my $self  = shift                          ;
    my $param = shift                          ;
    if ( defined $param ) {
	push @{$self->{'connections'}}, $param ;
	return $param                          ;
    }else{
	return $self->{'connections'}          ;
    }
                                               }
sub callback    {
    my $self  = shift                                          ;
    my $param = shift                                          ;
    if ( ref $param eq 'CODE' ) {
	map { $_->callback( $param ) } @{ $self->connections } ;
	return 0                                               ;
    }
    return $_[0]->{'callback'}( $param ) if defined $param     ;
                                                               }
sub add_handler {
    my $self = shift ;
    map { $_->add_handler( @_ ) } @{ $self->connections } ; }

sub irc_grammar { local $/ ; return <DATA> ; }

1; # End of Net::IRC2


=head1 AUTHOR

Karl Y. Pradene, C<< <knotty@cpan.org>, irc://knotty@freenode.org/ >> 

=head1 BUGS

Please report any bugs or feature requests to
C<bug-net-irc2@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Net-IRC2>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SEE ALSO

Perl modules working with IRC connections: Net::IRC, POE::Component::IRC

IRC Request For Comment 1459 L<http://www.ietf.org/rfc/rfc1459.txt?number=1459>

=head1 COPYRIGHT & LICENSE

Copyright 2005, Karl Y. Pradene <knotty@cpan.org> All rights reserved.

This program is released under the following license: GPL v2

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











#------------------------
# The IRC grammar
# Read by sub irc_grammar
#

__DATA__

{
    use Net::IRC2::Event;
    my $Event = undef;
    my $DEBUG = 10;
}

message: 
       { $Event = new Net::IRC2::Event( 'orig' => $text ) }
       prefix(?) command middle(s?) (':')(?) trailing(?)
       {
	   $Event->prefix(   $item{ 'prefix(?)' }[0] ) ;
	   $Event->middle(   $item{'middle(s?)' }    ) ;
	   $Event->command(  $item{  'command'  }    ) ;
	   $Event->trailing( $item{'trailing(?)'}    ) ;
	   $return = $Event;
        }
prefix: ':' <commit> from
from: servername
        {
            $Event->servername($item[1]);
            $return = $item[1]
        }
      | nick ('!' user)(?) ('@' host)(?) 
	{ 
	    $Event->nick( $item[1]    || 'UNDEF' );
	    $Event->user( $item[2][0] || 'UNDEF' );
	    $Event->host( $item[3][0] || 'UNDEF' );
	    $return =     $item[1]                                 .
		      ( ( $item[2][0] ) ? '!' . $item[2][0] : '' ) .
		      ( ( $item[3][0] ) ? '@' . $item[3][0] : '' ) ;
	 }
servername: /[\w\.\-]+/
command: /\d{3}/ | /[a-z]+/i
middle: /[^\:\s\x00\x20\x0A\x0D]+/
trailing: /[^\x00\x0A\x0D]+/
target: to(s /,/) 
to: channel 
  | ( user '@' servername )
  | nick
  | mask
channel: ( '#' | '&' ) chstring
host: /[\w\-\.]+/
nick: /[\w\-\\\[\]\`\{\}\^]+/
mask: ('#' | '$') chstring
chstring: /^[^\s ,\x00 \x0A \x0D \x07]+/ 
user: /[\w\-]+/
special: /^[\\\-\[\]\`\^\{\}]/
nonwhite: /^[^\x20 \x00 \x0D \x0A]/
