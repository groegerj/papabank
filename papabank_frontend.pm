package Papabank::Frontend;

# papabank_frontend.pm -- the ncurses gui
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

use POSIX;
use Curses::UI;
use Date::Calc qw(Add_Delta_Days);

my $ui;
my $listbox;

my $bank;
my $account;
my $week; # array

sub main_loop
{
  $bank=shift;
  $account=shift;
  $week=shift; # array of weeks

$ui = new Curses::UI( -color_support => 1, -compat => 1, -clear_on_exit => 1,);

my $window_menu = $ui->add(undef, 'Window', -border => 1, -y => -1, -height => 3, -bfg => "blue",);

my $window_transactions = $ui->add(undef, 'Window', -border => 1, -title => $account->accountname."@".$bank->name.": Transaktionen", -padbottom => 2, -ipad => 1, -bfg => "blue", -tbg => "blue");
my $window_info = $ui->add(undef, 'Window', -border => 1, -title => $account->accountname."@".$bank->name.": Konto", -padbottom => 2, -ipad => 1, -bfg => "blue", -tbg => "blue");
my $window_booking = $ui->add(undef, 'Window', -border => 1, -title => $account->accountname."@".$bank->name.": Buchung", -padbottom => 0, -ipad => 1, -bfg => "red", -tbg => "red");

# -----------------------------------------------------
# menu
# -----------------------------------------------------

$window_menu->add('info', "Buttonbox", -buttons => [ { -label => " |Transaktionen| ", -onpress => sub {$window_transactions->focus();} },
{ -label => " |Konto| "   , -onpress => sub {$window_info->focus();} },
                                                     { -label => " |Beenden| " , -onpress => sub {exit(0);} }]
                  , -y => 0, -x => 1,);


# ----------------------------------------------------
# Konfoinformationen
# ----------------------------------------------------

my ($year,$month,$day)=@{$account->startingday};
my $weekday=Date::Day::day($month,$day,$year);

my $infotext="Kontoeröffnung       : ".$weekday.", ".$day.".".$month.".".$year."\nWöchentl. Taschengeld: ".$account->weeklypayment." EUR\n4-wöchentl. Zinssatz : ".$account->fourweekinterest." %\n\n       ".$account->firstname." ".$account->name."\nKunde: ".$account->street." ".$account->number."\n       ".$account->zip." ".$account->town."\n\n       ".$bank->name."\nBank:  ".$bank->street." ".$bank->number."\n       ".$bank->zip." ".$bank->town;


$window_info->add(
  undef, 'TextViewer',
  -x    => 0,
  -y    => 0,
  -text => $infotext,
);

# ----------------------------------------------------
# Buchung
# ----------------------------------------------------

my $thisweekfinal=0;

my $input_amount=$window_booking->add(
  undef, 'TextViewer',
  -x    => 0,
  -y    => 0,
  -height => 1,
);

my $booking_euro=0;
my $booking_cent=0;
my $booking_type="";

my $input_euro=$window_booking->add(
  undef, 'TextViewer',
  -x    => 18,
  -y    => 11,
  -height => 1,
  -width => 11,
);

my $input_cent=$window_booking->add(
  undef, 'TextViewer',
  -x    => 18,
  -y    => 13,
  -height => 1,
  -width => 11,
);

sub update_booking
{
  my $type=shift;
  my $new_euro=shift;
  my $new_cent=shift;
  $booking_type=$type;

  my $available_euro=POSIX::floor($thisweekfinal);
  my $available_cent=100*($thisweekfinal-$available_euro);

  if ($new_cent<0)
  {
    $new_euro--;
    $new_cent=100+$new_cent;
  }
  if ($new_cent>99)
  {
    $new_euro++;
    $new_cent-=100;
  }
  my $new_total=100*$new_euro+$new_cent;
  my $available_total=100*$available_euro+$available_cent;
  $booking_euro=$new_euro;
  $booking_cent=$new_cent;
  if ($new_total<0)
  {
    $booking_euro=0;
    $booking_cent=0;
  }

  if (($type==1 or $type==3) and $new_total>$available_total)
  {
    $booking_euro=$available_euro;
    $booking_cent=$available_cent;
  }

  $input_euro->text("Euro: ".$booking_euro);
  $input_cent->text("Cent: ".sprintf("%02u",$booking_cent));
}

my $input_type=$window_booking->add(
    undef, 'Radiobuttonbox',
    -y          => 2,
    -x          => 0,
    -values => [0,1,2,3],
    -labels     => {0=>$Papabank::Output::transactiontypes{INPAY},
                    1=>$Papabank::Output::transactiontypes{OUTPAY},
                    2=>$Papabank::Output::transactiontypes{INTRANS},
                    3=>$Papabank::Output::transactiontypes{OUTTRANS}},

  -height => 8,
  -ipad => 1,
    -border     => 1,
    -title      => 'Buchungsart',
    -onchange   => sub
      {
        my $listbox = shift;
        my @sel = $listbox->get;
        @sel = ('<none>') unless @sel;
        my $sel = join (", ", @sel);
        update_booking($sel,$booking_euro,$booking_cent);},
);

$window_booking->add(undef, "Buttonbox", -buttons => [
{ -label => " << "   , -onpress => sub {update_booking($booking_type,$booking_euro-10,$booking_cent);} },
{ -label => " < "   , -onpress => sub {update_booking($booking_type,$booking_euro-1,$booking_cent);} },
{ -label => " > "   , -onpress => sub {update_booking($booking_type,$booking_euro+1,$booking_cent);} },
{ -label => " >> "   , -onpress => sub {update_booking($booking_type,$booking_euro+10,$booking_cent);} },]
                  , -y => 11, -x => 0, -width => 17);

$window_booking->add(undef, "Buttonbox", -buttons => [
{ -label => " << "   , -onpress => sub {update_booking($booking_type,$booking_euro,$booking_cent-10);} },
{ -label => " < "   , -onpress => sub {update_booking($booking_type,$booking_euro,$booking_cent-1);} },
{ -label => " > "   , -onpress => sub {update_booking($booking_type,$booking_euro,$booking_cent+1);} },
{ -label => " >> "   , -onpress => sub {update_booking($booking_type,$booking_euro,$booking_cent+10);} },]
                  , -y => 13, -x => 0, -width => 17);

$window_booking->add(
  undef, 'TextViewer',
  -x    => 0,
  -y    => 15,
  -height => 1,
  -text => "Beschreibung:",
  -width => 14,
);

my $input_description=$window_booking->add(
    undef, 'TextEntry',
    -sbborder => 1,
    -y => 15,
    -x => 14,
    -width => 30,
);

# return day difference number from current week's firstday to current date
sub day_difference
{
  my ($localyear,$localmonth,$localday)=(localtime)[5,4,3];
  $localyear+=1900;
  $localmonth+=1;

  my $z=scalar @$week-1;
  my ($year,$month,$day)=@{@$week[$z]->firstday};

  my $i=0;
  while (($localyear!=$year or $localmonth!=$month or $localday!=$day) and $i<6)
  {
    ($year,$month,$day)=Add_Delta_Days($year,$month,$day,1);
    $i++;
  }

  return $i;
}


sub do_booking
{
  my $current_type=shift;

  my $z=scalar @$week-1;
  my $d=day_difference();
  @$week[$z]->lastusedday($d);
  push @{@$week[$z]->day},$d;
  push @{@$week[$z]->type},$current_type;
  push @{@$week[$z]->amount},$booking_euro.".".sprintf("%02u",$booking_cent);
  push @{@$week[$z]->description},$input_description->get();

  # save to file TODO: code should be at some different place
  my ($year,$month,$day)=@{@$week[$z]->firstday};
  my $week_dat="accounts/".$account->accountname."/transactions/week_$year-$month-$day.dat";
  Papabank::Backend::write_week(@$week[$z],$week_dat);
}

$window_booking->add(undef, "Buttonbox", -buttons => [
{ -label => " |Buchung| "   , -onpress => sub
             {
	       my $b = shift();
               if ($booking_euro==0 and $booking_cent==0)
               {
  	         $b->root->dialog(
	             -message => " Bitte Betrag größer 0.00 EUR eingeben!",
		     -title   => "Keine Eingabe"
  	         );
               }
               else
               {
                 my @sel = $input_type->get;
                 @sel = ('<none>') unless @sel;
                 my $sel = join (", ", @sel);
                 my @type_strings=($Papabank::Output::transactiontypes{INPAY},
                                   $Papabank::Output::transactiontypes{OUTPAY},
                                   $Papabank::Output::transactiontypes{INTRANS},
                                   $Papabank::Output::transactiontypes{OUTTRANS});

	         my $value = $b->root->dialog(
	             -message => $type_strings[$sel]." von ".$booking_euro.".".sprintf("%02u",$booking_cent)." EUR.",
                     -buttons => ['ok','cancel'],
                     -title   => 'Buchung durchführen?',
	         );
                 if ($value ne 0)
                 {
                   my @type_names=('INPAY','OUTPAY','INTRANS','OUTTRANS');
                   do_booking($type_names[$sel]);
                   update_selection(scalar @$week -1);
                   $window_menu->focus();
                   $window_transactions->focus();
                 }
               }
             } },
{ -label => " |Abbrechen| "   , -onpress => sub {$window_menu->focus();$window_transactions->focus();} }], -y => -1);


sub show_booking
{
  $booking_euro=0;
  $booking_cent=0;
  $input_type->set_selection(1);
  $input_type->set_selection(0);
  $input_description->text("");
  $input_amount->text("Aktueller Kontostand: ".sprintf("%.2f",$thisweekfinal)." EUR");
  $window_booking->focus();
}

# ----------------------------------------------------
# Transaktionen
# ----------------------------------------------------

my $current_box=$window_transactions->add(
    undef, 'Listbox',
    -y          => 3,
    -ipad => 1,
    -padbottom => 1,
    -border     => 1,
    -title      => 'Transaktionen',
    -vscrollbar => 1,
);

my $week_text=$window_transactions->add(
  undef, 'TextViewer',
  -x    => 0,
  -y    => 0,
  -height => 1,
);

my $finalamount_info=$window_transactions->add(
  undef, 'TextViewer',
  -x => 11,
  -y => -1,
  -height => 1,
);

my %update_hash=( -label => '', -onpress => sub {} );
my $update_button=$window_transactions->add(
  undef,  "Buttonbox", -buttons => [\%update_hash], -x => 0, -y => -1, -width => 10,);

my @transaction_values=();

my $selected_week;

# set new week selection and update listbox and stuff accordingly
sub update_selection
{
  my $selection=shift;

  if ($selection<0) {$selection=0;}
  my $z=scalar @$week-1;
  if ($selection>$z) {$selection=$z;}

  $selected_week=$selection;
  my $j=0;
  $thisweekfinal=@$week[$selection]->initialamount;
  @transaction_values=();
  foreach(@{@$week[$selection]->type})
  {
    my $sign="+";
    if (@{@$week[$selection]->type}[$j] eq "OUTPAY" or @{@$week[$selection]->type}[$j] eq "OUTTRANS")
    {
      $sign="-";
      $thisweekfinal-=@{@$week[$selection]->amount}[$j];
    }
    else
    {
      $thisweekfinal+=@{@$week[$selection]->amount}[$j];
    }

    push @transaction_values, Papabank::Output::print_date_weekday(@{@$week[$selection]->firstday},@{@$week[$selection]->day}[$j])." ".$Papabank::Output::transactiontypes{@{@$week[$selection]->type}[$j]}." ".$sign.@{@$week[$selection]->amount}[$j]." EUR ".@{@$week[$selection]->description}[$j];
    $j++;
  }

  my $s=$selection+1;
  $week_text->text("Woche $s: ".Papabank::Output::print_date(@{@$week[$selection]->firstday},0)." bis ".Papabank::Output::print_date(@{@$week[$selection]->firstday},6));
  $current_box->values(\@transaction_values);
  $current_box->intellidraw();

  $finalamount_info->text("Kontostand (Woche ".$s."): ".sprintf("%.2f",$thisweekfinal)." EUR");
  if ($z==$selection)
    {
      %update_hash=( -label => '|Buchung|', -onpress => sub {show_booking();} );
      $current_box->set_color_bfg('red');
      $current_box->set_color_tbg('red');
    }
  else
    {
      %update_hash=( -label => '', -onpress => sub {} );
      $current_box->set_color_bfg('blue');
      $current_box->set_color_tbg('blue');
    }

  $finalamount_info->intellidraw();
  $update_button->intellidraw();
}

update_selection(scalar @$week -1);

$window_transactions->add(undef, "Buttonbox", -buttons => [ { -label => " 1 "   , -onpress => sub {update_selection(0);} },
{ -label => " << "   , -onpress => sub {update_selection($selected_week-10);} },
{ -label => " < "   , -onpress => sub {update_selection($selected_week-1);} },
{ -label => " > "   , -onpress => sub {update_selection($selected_week+1);} },
{ -label => " >> "   , -onpress => sub {update_selection($selected_week+10);} },
{ -label => " ".scalar @$week." "   , -onpress => sub {my $s=scalar @$week;update_selection($s-1);} }]
                  , -y => 1, -x => 0,);

# ---------------------------------------

$ui->mainloop();
}

1;
