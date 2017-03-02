package Papabank::Output;

# papabank_output.pm -- print date etc.
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

use Date::Calc qw(Add_Delta_Days);

our %transactiontypes= (
  "INPAY"    => "Einzahlung",
  "OUTPAY"   => "Auszahlung",
  "INTRANS"  => "Gutschrift",
  "OUTTRANS" => "Überweisung",
  "INTEREST" => "Zinsen",
);

sub print_date
{
  my ($year,$month,$day,$offset)=@_;
  my ($year_off,$month_off,$day_off)=Add_Delta_Days($year,$month,$day,$offset);
  my $weekday=Date::Day::day($month_off,$day_off,$year_off);

  return "$weekday, $day_off.$month_off.$year_off";
}

sub print_date_weekday
{
  my ($year,$month,$day,$offset)=@_;
  my ($year_off,$month_off,$day_off)=Add_Delta_Days($year,$month,$day,$offset);
  my $weekday=Date::Day::day($month_off,$day_off,$year_off);

  return "$weekday";
}

1;
