package Date::Day;

# Day.pm -- a GPL drop-in replacement for John Von Essen's Date::Day.
#
# Copyright (C) 2016-2017 Josua Groeger.
#
# papabank is a perl program with an ncurses GUI for managing
# something like a bank account, mainly intended for pocket money.
#
#
# LICENSE
#
# papabank is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# papabank is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with papabank.  If not, see <http://www.gnu.org/licenses/>.

use strict;
require Exporter;
our @ISA      = qw(Exporter);
our @EXPORT   = qw(day);
our @EXPORT_OK= qw();

sub day
{
  my $m=int($_[0]);
  my $d=int($_[1]);
  my $y=int($_[2]);

  if ($m<1 or $m>12 or $d<1 or $d>31 or $y<1) {return "Er.";}

  # numbers of days for the first n month, for n=0,...11
  my @moffset=(0,31,59,90,120,151,181,212,243,273,304,334);
  my @weekday=('Mo.','Di.','Mi.','Do.','Fr.','Sa.','So.');

  my $yy=($m<3)?$y-1:$y;
  my $w=$d-1+$moffset[$m-1]+$y-1+int($yy/4)-int($yy/100)+int($yy/400);
  return $weekday[$w%7];
}

1;

