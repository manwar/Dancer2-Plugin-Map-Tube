package Dancer2::Plugin::Map::Tube::API;

$Dancer2::Plugin::Map::Tube::API::VERSION   = '0.01';
$Dancer2::Plugin::Map::Tube::API::AUTHORITY = 'cpan:MANWAR';

=head1 NAME

Dancer2::Plugin::Map::Tube::API - API for Map::Tube.

=head1 VERSION

Version 0.01

=cut

use 5.006;
use JSON;
use Data::Dumper;
use Cache::Memcached::Fast;

use Map::Tube::Delhi;
use Map::Tube::London;
use Map::Tube::Kolkatta;
use Map::Tube::Barcelona;

use Moo;
use namespace::clean;

our $SUPPORTED_MAPS = {
    'London'    => Map::Tube::London->new,
    'Delhi'     => Map::Tube::Delhi->new,
    'Kolkatta'  => Map::Tube::Kolkatta->new,
    'Barcelona' => Map::Tube::Barcelona->new,
};

has 'map_name'          => (is => 'ro');
has 'supported_maps'    => (is => 'ro', default => sub { $SUPPORTED_MAPS });
has 'request_period'    => (is => 'ro', default => sub { 60 });
has 'request_threshold' => (is => 'ro', default => sub { 30 });
has 'memcache_host'     => (is => 'ro', default => sub { 'localhost' });
has 'memcache_port'     => (is => 'ro', default => sub { 11211       });
has 'memcached'         => (is => 'rw');
has 'map_object'        => (is => 'rw');

=head1 DESCRIPTION

=cut

sub BUILD {
    my ($self, $arg) = @_;

    my $address = sprintf("%s:%d", $self->memcache_host, $self->memcache_port);
    $self->{memcached}  = Cache::Memcached::Fast->new({ servers => [{ address => $address }] });
    $self->{map_object} = _get_map_object($self->map_name);
}

=head1 METHODS

=head2 shortest_route($client_ip, $start, $end)

=cut

sub shortest_route {
    my ($self, $client_ip, $start, $end) = @_;

    return { error_code    => 401,
             error_message => 'You have reached the threshold, please try later.'
    } unless $self->_is_authorized($client_ip);

    my $map_name = $self->{map_name};
    return { error_code    => 402,
             error_message => 'Missing map name.'
    } unless (defined $map_name);

    return { error_code    => 403,
             error_message => "Unsupported map [$map_name]."
    } unless (defined $self->{map_object});

    my $route    = $self->map_object->get_shortest_route($start, $end);
    my $stations = [ map { sprintf("%s", $_) } @{$route->nodes} ];

    return _jsonified_content($stations);
};

=head2 line_stations($client_ip, $line)

=cut

sub line_stations {
    my ($self, $client_ip, $line) = @_;

    return { error_code    => 401,
             error_message => 'You have reached the threshold, please try later.'
    } unless $self->_is_authorized($client_ip);

    my $map_name = $self->{map_name};
    return { error_code    => 402,
             error_message => 'Missing map name.'
    } unless (defined $map_name);

    return { error_code    => 403,
             error_message => "Unsupported map [$map_name]."
    } unless (defined $self->{map_object});

    my $object   = $self->map_object;
    my $stations = $object->get_stations($object->get_line_by_id($line)->name);

    return _jsonified_content([ map { sprintf("%s", $_) } @{$stations} ]);
};

=head2 map_stations($client_ip)

=cut

sub map_stations {
    my ($self, $client_ip) = @_;

    return { error_code    => 401,
             error_message => 'You have reached the threshold, please try later.'
    } unless $self->_is_authorized($client_ip);

    my $map_name = $self->{map_name};
    return { error_code    => 402,
             error_message => 'Missing map name.'
    } unless (defined $map_name);

    return { error_code    => 403,
             error_message => "Unsupported map [$map_name]."
    } unless (defined $self->{map_object});

    my $object   = $self->map_object;
    my $lines    = $object->get_lines;
    my $stations = {};
    foreach my $line (@$lines) {
        foreach my $station (@{$object->get_stations($line->name)}) {
            $stations->{sprintf("%s", $station)} = 1;
        }
    }

    return _jsonified_content([ sort keys %$stations ]);
};

=head2 available_maps($client)

=cut

sub available_maps {
    my ($self, $client_ip) = @_;

    return { error_code    => 401,
             error_message => 'You have reached the threshold, please try later.'
    } unless $self->_is_authorized($client_ip);

    my $maps = [ join(", ", sort keys %{$self->{supported_maps}}) ];

    return _jsonified_content($maps);
};

#
#
# PRIVATE METHODS

sub _jsonified_content {
    my ($data) = @_;

    return { content => JSON->new->allow_nonref->utf8(1)->encode($data) };
}

sub _is_authorized {
    my ($self, $client_ip) = @_;

    my $userdata = $self->memcached->get('userdata');
    my $now = time;

    if (defined $userdata) {
        if (exists $userdata->{$client_ip}) {
            my $old = $userdata->{$client_ip}->{last_access_time};
            my $cnt = $userdata->{$client_ip}->{count};
            if (($now - $old) < $self->request_period) {
                if (($cnt + 1) > $self->request_threshold) {
                    return 0;
                }
                else {
                    $userdata->{$client_ip}->{last_access_time} = $now;
                    $userdata->{$client_ip}->{count} = $cnt + 1;
                }
            }
            else {
                $userdata->{$client_ip}->{last_access_time} = $now;
                $userdata->{$client_ip}->{count} = 1;
            }
        }
        else {
            $userdata->{$client_ip}->{last_access_time} = $now;
            $userdata->{$client_ip}->{count} = 1;
        }

        $self->memcached->replace('userdata', $userdata);
    }
    else {
        $userdata->{$client_ip}->{last_access_time} = $now;
        $userdata->{$client_ip}->{count} = 1;

        $self->memcached->add('userdata', $userdata);
    }

    return 1;
}

sub _get_map_object {
    my ($map) = @_;
    return unless defined $map;

    if ($map =~ /\s/) {
        my @parts = split(/\s/, $map);
        my @map   = ();
        foreach my $part (@parts) {
            push @map, ucfirst(lc($part));
        }

        $map = join(" ", @map);
    }
    else {
        $map = ucfirst(lc($map));
    }

    return $SUPPORTED_MAPS->{$map};
}

=head1 AUTHOR

Mohammad S Anwar, C<< <mohammad.anwar at yahoo.com> >>

=head1 REPOSITORY

L<https://github.com/manwar/Dancer2-Plugin-Map-Tube>

=head1 BUGS

Please report any bugs or feature requests to C<bug-dancer2-plugin-map-tube at rt.cpan.org>,
or through the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Dancer2-Plugin-Map-Tube>.
I will  be notified and then you'll automatically be notified of progress on your
bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Dancer2::Plugin::Map::Tube::API

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Dancer2-Plugin-Map-Tube>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Dancer2-Plugin-Map-Tube>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Dancer2-Plugin-Map-Tube>

=item * Search CPAN

L<http://search.cpan.org/dist/Dancer2-Plugin-Map-Tube/>

=back

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2017 Mohammad S Anwar.

This program  is  free software; you can redistribute it and / or modify it under
the  terms  of the the Artistic License (2.0). You may obtain  a copy of the full
license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any  use,  modification, and distribution of the Standard or Modified Versions is
governed by this Artistic License.By using, modifying or distributing the Package,
you accept this license. Do not use, modify, or distribute the Package, if you do
not accept this license.

If your Modified Version has been derived from a Modified Version made by someone
other than you,you are nevertheless required to ensure that your Modified Version
 complies with the requirements of this license.

This  license  does  not grant you the right to use any trademark,  service mark,
tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge patent license
to make,  have made, use,  offer to sell, sell, import and otherwise transfer the
Package with respect to any patent claims licensable by the Copyright Holder that
are  necessarily  infringed  by  the  Package. If you institute patent litigation
(including  a  cross-claim  or  counterclaim) against any party alleging that the
Package constitutes direct or contributory patent infringement,then this Artistic
License to you shall terminate on the date that such litigation is filed.

Disclaimer  of  Warranty:  THE  PACKAGE  IS  PROVIDED BY THE COPYRIGHT HOLDER AND
CONTRIBUTORS  "AS IS'  AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES. THE IMPLIED
WARRANTIES    OF   MERCHANTABILITY,   FITNESS   FOR   A   PARTICULAR  PURPOSE, OR
NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY YOUR LOCAL LAW. UNLESS
REQUIRED BY LAW, NO COPYRIGHT HOLDER OR CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL,  OR CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE
OF THE PACKAGE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=cut

1; # End of Dancer2::Plugin::Map::Tube::API
