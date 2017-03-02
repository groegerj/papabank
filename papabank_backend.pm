package Papabank::Backend;

# papabank_backend.pm -- update and write week data
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

sub update_pdfs
{
  my $bank=shift;
  my $account=shift;
  my $week=shift; # array of weeks

  my $tmp_dir="accounts/".$account->accountname."/tmp";
  
  foreach(@$week)
  {
    my ($year,$month,$day)=@{$_->firstday};
    my $week_pdf="accounts/".$account->accountname."/statements/week_$year-$month-$day.pdf";
    if ($_->status eq "2" and not -f $week_pdf)
      {Papabank::WriteTex::make_pdf($bank,$account,$_,$tmp_dir,$week_pdf);}
  }
}

sub update_weeks
{
  my $week=shift; # array of weeks...
  my $account=shift;

  my $i=0;
  my $origstatus;
  foreach(@$week)
  {
    $origstatus=$_->status;
    if ($_->status eq "0") # write initialamount
    {
      if ($i==0) {$_->initialamount(0.00);}
      else {$_->initialamount(@$week[$i-1]->finalamount);}
    }

    if ($_->status ne "2" and $_ != @$week[-1])
    {
      push @{$_->day}, 6;
      push @{$_->type}, "INTRANS";
      push @{$_->amount}, $account->weeklypayment;
      push @{$_->description}, "Taschengeld";

      my $thisweekfinal=$_->initialamount;
      my $j=0;
      foreach(@{@$week[$i]->type})
      {
        if (@{@$week[$i]->type}[$j] eq "OUTPAY" or @{@$week[$i]->type}[$j] eq "OUTTRANS")
          {$thisweekfinal-=@{@$week[$i]->amount}[$j];}
        else
          {$thisweekfinal+=@{@$week[$i]->amount}[$j];}
        $j++;
      }

      if ($i%4==3) # every fourth week is interest time
      {
        my $interest=sprintf("%.2f",$account->fourweekinterest*(@$week[$i-3]->finalamount+@$week[$i-2]->finalamount+@$week[$i-1]->finalamount+$thisweekfinal)/400);
        $thisweekfinal+=$interest;

        push @{$_->day}, 6;
        push @{$_->type}, "INTEREST";
        push @{$_->amount}, $interest;
        push @{$_->description}, "Zinsen"; # TODO datum
      }

      $_->finalamount($thisweekfinal);
      $_->status(2);
      $_->lastusedday(6);
    }
    if ($_ == @$week[-1]) {$_->status(1);}

    if ($origstatus eq "0" or $origstatus ne $_->status) # write week file
    {
      my ($year,$month,$day)=@{$_->firstday};
      my $week_dat="accounts/".$account->accountname."/transactions/week_$year-$month-$day.dat";
      write_week($_,$week_dat);
    }
    $i++;
  }
}

sub write_week
{
  my $week=shift;
  my $week_dat=shift;

  open("outfile", ">$week_dat");
  write_week_contents($week,\*outfile);
  close("outfile");
}

sub write_week_contents
{
  my $week=shift;
  my $HANDLE=shift;

  print $HANDLE "[week]\n\nstatus;".$week->status.";\ninitialamount;".$week->initialamount.";\n";
  if ($week->status eq "2")
    {print $HANDLE "finalamount;".$week->finalamount.";\n";}
  print $HANDLE "\n[transactions]\n\n";
  my $i=0;
  foreach (@{$week->day})
  {
    print $HANDLE @{$week->day}[$i].";".@{$week->type}[$i].";".@{$week->amount}[$i].";".@{$week->description}[$i].";\n";
    $i++;
  }
}

1;
