package Papabank::ReadData;

# papabank_readdata.pm -- read data files
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

sub read_bank_dat
{
  my $bank=shift;

  my $bank_dat="bank.dat";

  if (not -f $bank_dat) {die "file \"$bank_dat\" does not exist";} 
  open(FILE, "<$bank_dat") || die "file \"$bank_dat\" not found";
  my @contents=<FILE>;
  close(FILE);
  
  my $section="";
  foreach(@contents)
  {
    if (substr($_,0,1) eq "[")
    {
      $section = $_;
      $section =~ s/\n//;
    }
  
    if ($section eq "[bank]")
    {
      my @entry= split(/ *; */,$_);
      if ($entry[0] eq "name") {$bank->name($entry[1]);}
      if ($entry[0] eq "street") {$bank->street($entry[1]);}
      if ($entry[0] eq "number") {$bank->number($entry[1]);}
      if ($entry[0] eq "zip") {$bank->zip($entry[1]);}
      if ($entry[0] eq "town") {$bank->town($entry[1]);}
    }
  }
}

sub read_account_dat
{
  my $account=shift;

  my $account_dat="accounts/".$account->accountname."/account.dat";

  if (not -f $account_dat) {die "file \"$account_dat\" does not exist";}
  open("file", "<$account_dat") || die "file \"$account_dat\" not found";
  my @contents=<file>;
  close("file");
  
  my $section="";
  foreach(@contents)
  {
    if (substr($_,0,1) eq "[")
    {
      $section = $_;
      $section =~ s/\n//;
    }
  
    if ($section eq "[customer]")
    {
      my @entry= split(/ *; */,$_);
      if ($entry[0] eq "name") {$account->name($entry[1]);}
      if ($entry[0] eq "firstname") {$account->firstname($entry[1]);}
      if ($entry[0] eq "street") {$account->street($entry[1]);}
      if ($entry[0] eq "number") {$account->number($entry[1]);}
      if ($entry[0] eq "zip") {$account->zip($entry[1]);}
      if ($entry[0] eq "town") {$account->town($entry[1]);}
    }
    elsif ($section eq "[account]")
    {
      my @entry= split(/ *; */,$_);
      if ($entry[0] eq "startingday") {@{$account->startingday}=split(/ *- */,$entry[1]);}
      if ($entry[0] eq "weeklypayment") {$account->weeklypayment($entry[1]);}
      if ($entry[0] eq "fourweekinterest") {$account->fourweekinterest($entry[1]);}
    }
  }
}

sub read_week_dat
{
  my $week=shift;
  my $week_dat=shift;

  if (not -f $week_dat) {die "file \"$week_dat\" does not exist";}
  open("file", "<$week_dat") || die "file \"$week_dat\" not found";
  my @contents=<file>;
  close("file");
  
  my $transaction_number=0;
  my $section="";
  foreach(@contents)
  {
    if (substr($_,0,1) eq "[")
    {
      $section = $_;
      $section =~ s/\n//;
    }
    elsif ($_ ne "" && $_ ne "\n")
    {
      if ($section eq "[week]")
      {
        my @entry= split(/ *; */,$_);
        if ($entry[0] eq "status") {$week->status($entry[1]);}
        if ($entry[0] eq "initialamount") {$week->initialamount($entry[1]);}
        if ($entry[0] eq "finalamount") {$week->finalamount($entry[1]);}
      }
      elsif ($section eq "[transactions]")
      {
        my @entry= split(/ *; */,$_);
        ${$week->day}[$transaction_number]=$entry[0];
        $week->lastusedday($entry[0]);
        ${$week->type}[$transaction_number]=$entry[1];
        ${$week->amount}[$transaction_number]=$entry[2];
        ${$week->description}[$transaction_number]=$entry[3];
        $transaction_number=$transaction_number+1;
      }
    }  
  }
  if ($week->status==2) {$week->lastusedday(6);}
}

sub read_weeks
{
  my $week=shift; # here array of weeks, bad naming...
  my $account=shift;

  # retrieve current date
  my ($localyear,$localmonth,$localday)=(localtime)[5,4,3];
  $localyear+=1900;
  $localmonth+=1;

  # loop over all dates (mod 7) starting with startingday until today
  my ($year,$month,$day)=@{$account->startingday};
  my $i=0;
  my $week_dat;
  my $gap=0;
  my $prefinal=0;
  my $prev_finalamount=0;
  while (
    $year<$localyear or
    $year==$localyear and $month<$localmonth or
    $year==$localyear and $month==$localmonth and $day<=$localday)
  {
    @$week[$i] = Week->new();
    @{@$week[$i]->firstday}=($year,$month,$day);
    $week_dat="accounts/".$account->accountname."/transactions/week_$year-$month-$day.dat";

    if (not -f $week_dat)
    {
      $gap=1;
      @$week[$i]->status(0);
    }
    else # week file exists
    {
      if ($gap==1) # 
        {die "data inconsistency: file \"$week_dat\" exists, but some previous week file does not (gap)";}
      read_week_dat(@$week[$i],$week_dat);

      if (@$week[$i]->status!=1 and $prefinal==1)
        {die "data inconsistency: file \"$week_dat\" marked \"final\" but some previous week file not";}
      if (@$week[$i]->status==1) {$prefinal=1;} # not final

      if (@$week[$i]->initialamount != $prev_finalamount)
        {die "data inconsistency: initialamount in file \"$week_dat\" different from finalamount in previous week!";}
      $prev_finalamount=@$week[$i]->finalamount;
    }

    # end part of loop
    ($year,$month,$day)=Add_Delta_Days($year,$month,$day,7);
    $month=sprintf("%02d",$month);
    $day=sprintf("%02d",$day);
    $i+=1;
  }

  if (@$week[-1]->status==2)
    {die "data inconsistency: current week file should be marked \"prefinal\".";}
}

1;
