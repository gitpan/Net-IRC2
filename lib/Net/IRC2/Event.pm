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
$VERSION = '0.00_03'            ;

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
sub orig       { return $_[0]->{   'orig'   }                                  }
sub prefix     { return $_[0]->{  'prefix'  } = $_[1] || $_[0]->{  'prefix  '} }

sub servername { return $_[0]->{'servername'} = $_[1] || $_[0]->{'servername'} }
sub nick       { return $_[0]->{   'nick'   } = $_[1] || $_[0]->{   'nick'   } }
sub user       { return $_[0]->{   'user'   } = $_[1] || $_[0]->{   'user'   } }
sub host       { return $_[0]->{   'host'   } = $_[1] || $_[0]->{   'host'   } }

sub command    { return $_[0]->{'command'}    = $_[1] || $_[0]->{'command'}    }

sub middle     {
    $_[0]->{'middle'}    = $_[1] || $_[0]->{'middle'}   || 'NOMIDDLE'          ;
    return ( wantarray ) ? $_[0]->{'middle'}   : "@{$_[0]->{'middle'}}"        ;
}
sub trailing   {
    $_[0]->{'trailing'}  = $_[1] || $_[0]->{'trailing'} || 'NOTRAILING'        ;
    return ( wantarray ) ? $_[0]->{'trailing'} : "@{$_[0]->{'trailing'}}"      ;
                                                                               }
sub time       { return $_[0]->{'timestamp'}                                   }
sub userhost   { warn 'TODO: userhost for Event'                               }

1;
