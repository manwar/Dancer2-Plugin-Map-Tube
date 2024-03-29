package Dancer2::Plugin::Map::Tube::Error;

$Dancer2::Plugin::Map::Tube::Error::VERSION   = '0.04';
$Dancer2::Plugin::Map::Tube::Error::AUTHORITY = 'cpan:MANWAR';

=head1 NAME

Dancer2::Plugin::Map::Tube::Error - Error codes for Map::Tube API.

=head1 VERSION

Version 0.04

=cut

use 5.006;
use strict; use warnings;
use parent 'Exporter';

our @EXPORT = qw(
    $BAD_REQUEST
    $TOO_MANY_REQUEST

    $MEMCACHE_SERVER_ERROR
    $MEMCACHE_SERVER_UNREACHABLE

    $REACHED_REQUEST_LIMIT

    $MISSING_MAP_NAME
    $RECEIVED_INVALID_MAP_NAME
    $RECEIVED_UNSUPPORTED_MAP_NAME

    $MISSING_START_STATION_NAME
    $RECEIVED_INVALID_START_STATION_NAME

    $MISSING_END_STATION_NAME
    $RECEIVED_INVALID_END_STATION_NAME

    $MISSING_LINE_NAME
    $RECEIVED_INVALID_LINE_NAME

    $MAP_NOT_INSTALLED
);

=head1 DESCRIPTION

=head1 ERROR MESSAGES

=over 2

=item MEMCACHE SERVER UNREACHABLE

=item REACHED REQUEST LIMIT

=item MISSING MAP NAME

=item RECEIVED INVALID MAP NAME

=item RECEIVED UNSUPPORTED MAP NAME

=item MISSING START STATION NAME

=item RECEIVED INVALID START STATION NAME

=item MISSING END STATION NAME

=item RECEIVED INVALID END STATION NAME

=item MISSING LINE NAME

=item RECEIVED INVALID LINE NAME

=item MAP NOT INSTALLED

=back

=cut

our $BAD_REQUEST      = 400;
our $TOO_MANY_REQUEST = 429;
our $MEMCACHE_SERVER_ERROR = 430;

our $MEMCACHE_SERVER_UNREACHABLE         = 'Memcache server is unreachable.';
our $REACHED_REQUEST_LIMIT               = 'Reached request limit.';
our $MISSING_MAP_NAME                    = 'Missing map name.';
our $RECEIVED_INVALID_MAP_NAME           = 'Received invalid map name.';
our $RECEIVED_UNSUPPORTED_MAP_NAME       = 'Received unsupported map name.';
our $MISSING_START_STATION_NAME          = 'Missing start station name.';
our $RECEIVED_INVALID_START_STATION_NAME = 'Received invalid start station name.';
our $MISSING_END_STATION_NAME            = 'Missing end station name.';
our $RECEIVED_INVALID_END_STATION_NAME   = 'Received invalid end station name.';
our $MISSING_LINE_NAME                   = 'Missing line name.';
our $RECEIVED_INVALID_LINE_NAME          = 'Received invalid line name.';
our $MAP_NOT_INSTALLED                   = 'Map not installed';

=head1 AUTHOR

Mohammad Sajid Anwar, C<< <mohammad.anwar at yahoo.com> >>

=head1 REPOSITORY

L<https://github.com/manwar/Dancer2-Plugin-Map-Tube>

=head1 BUGS

Please report any bugs or feature requests through the web interface at L<https://metacpan.org/pod/Dancer2::Plugin::Map::Tube>.
I will  be notified and then you'll automatically be notified of progress on your
bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Dancer2::Plugin::Map::Tube::Error

You can also look for information at:

=over 4

=item * BUGS / ISSUES

L<https://metacpan.org/pod/Dancer2::Plugin::Map::Tube>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Dancer2-Plugin-Map-Tube>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Dancer2-Plugin-Map-Tube>

=item * Search MetaCPAN

L<https://metacpan.org/pod/Dancer2::Plugin::Map::Tube>

=back

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2024 Mohammad Sajid Anwar.

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

1; # End of Dancer2::Plugin::Map::Tube::Error
