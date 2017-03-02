#!/usr/bin/perl -w

# papabank.pl -- data structure and main program
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
use Class::Struct;
use lib '.';
use papabank_writetex;
use papabank_readdata;
use papabank_backend;
use papabank_frontend;

struct Bank => {
  # [bank]
  name => '$',
  street => '$',
  number => '$',
  zip => '$',
  town => '$',
};

struct Account => {
  accountname => '$',

  # [customer]
  name => '$',
  firstname => '$',
  street => '$',
  number => '$',
  zip => '$',
  town => '$',

  # [account]
  startingday => '@',
  weeklypayment => '$',
  fourweekinterest => '$',
};

struct Week => {
  firstday => '@',
  lastusedday => '$',

  # [week]
  status => '$', # '0' week file missing; '1' not final; '2' final
  initialamount => '$',
  finalamount => '$',

  # lines after [transactions]
  day => '@',
  type => '@',
  amount => '@',
  description => '@',
};

if (@ARGV<1) {die "Invoke \"./statement.pl ACCOUNTNAME\".";}

my @week;
my $bank = Bank->new();
my $account = Account->new();
$account->accountname($ARGV[0]);

Papabank::ReadData::read_bank_dat($bank);
Papabank::ReadData::read_account_dat($account);
Papabank::ReadData::read_weeks(\@week,$account);

Papabank::Backend::update_weeks(\@week,$account);
Papabank::Backend::update_pdfs($bank,$account,\@week);

Papabank::Frontend::main_loop($bank,$account,\@week);
