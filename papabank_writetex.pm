package Papabank::WriteTex;

# papabank_writetex.pm -- write Latex code and invoke pdflatex
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
use lib '.';
use Day;
use papabank_output;

sub make_pdf
{
  my $bank=shift;
  my $account=shift;
  my $week=shift;
  my $tmp_dir=shift;
  my $week_pdf=shift;

  open("outfile", ">$tmp_dir/tmp.tex");
  tex_writefile($bank,$account,$week,\*outfile);
  close("outfile");

  if (system("cd $tmp_dir && pdflatex -interaction=nonstopmode tmp.tex && rm tmp.aux tmp.log tmp.tex"))
  {
    print "\ncreating tmp.pdf with latex failed!\n";
    exit 1;
  }

  system("mv $tmp_dir/tmp.pdf $week_pdf");
}

sub tex_writefile
{
  my $bank=shift;
  my $account=shift;
  my $week=shift;

  my $HANDLE=shift;

  print $HANDLE print_header();

  print $HANDLE print_bank_address($bank);

  print $HANDLE print_customer_address($account);
  print $HANDLE print_title($bank,$week);

  print $HANDLE print_table_header($week);
  my $i=0;
  foreach(@{$week->day})
  {
    print $HANDLE print_table_entry($week,$i+1,${$week->day}[$i],${$week->type}[$i],${$week->amount}[$i],${$week->description}[$i]);
    $i=$i+1;
  }
  print $HANDLE print_table_closing($week);

  print $HANDLE print_closing();
}


sub print_header
{
  return ("\\documentclass[german]{g-brief}\n".
"%\\usepackage[T1]{fontenc}\n".
"\\usepackage[utf8x]{inputenc}\n".
"\\usepackage[table]{xcolor}\n".
"\n".
"\\renewcommand{\\arraystretch}{1.5}\n".
"\\setlength{\\tabcolsep}{7.5pt}\n".
"\\newcommand{\\Sig}[1] % Signature\n".
"   { \\Gruss{#1}{0.5cm} }\n".
"\n".
"%\\lochermarke\n".
"\\faltmarken\n".
"%\\fenstermarken\n".
"%\\trennlinien\n".
"%\\klassisch\n".
"\n".
"\\begin{document}\n".
"\n".
"\\Land{}\n".
"\\Telefon{}\n".
"\\Telex{}\n".
"\\EMail{}\n".
"\\HTTP{}\n".
"\\Bank{}\n".
"\\BLZ{}\n".
"\\Konto{}\n".
"\\RetourAdresse{ }\n".
"\\Postvermerk{}\n".
"\\MeinZeichen{}\n".
"\\IhrZeichen{}\n".
"\\IhrSchreiben{}\n".
"\\Anlagen{}\n".
"\\Verteiler{}\n".
"\n".
"\\Anrede{}\n".
"\\Sig{}\n".
"\n");
}

sub print_bank_address
{
  my $bank=shift;

  return ("\\Name{".$bank->name."}\n".
"\\Unterschrift{}\n".
"\\Strasse{".$bank->street." ".$bank->number."}\n".
"\\Zusatz{}\n".
"\\Ort{".$bank->zip." ".$bank->town."}\n".
"\n");
}

sub print_customer_address
{
  my $account=shift;

  return ("\\Adresse{".$account->firstname." ".$account->name."\\\\\n".
$account->street." ".$account->number."\\\\\n".
$account->zip." ".$account->town."}\n".
"\n");
}

sub print_title
{
  my $bank=shift;
  my $week=shift;
  my $title="";

  if ($week->status eq "2")
    {$title="\\Betreff{Kontoauszug von ".Papabank::Output::print_date(@{$week->firstday},0)." bis ".Papabank::Output::print_date(@{$week->firstday},6)."}\n";}
  else
    {$title="\\Betreff{(Vorl\\\"aufiger) Kontoauszug ab ".Papabank::Output::print_date(@{$week->firstday},0)."}\n";}

  return ($title.
"\n".
"\\Datum{".$bank->town.", ".Papabank::Output::print_date(@{$week->firstday},$week->lastusedday)."}\n".
"\n");
}

sub print_table_header
{
  my $week=shift;

  return ("\\begin{g-brief}\n".
"\\vspace{-.75cm}\\rowcolors{2}{white}{gray!25}\n".
"\\begin{center}\n".
"\\begin{tabular}{rrl|rr|p{5.25cm}}\n".
"\\\\&\\texttt{".Papabank::Output::print_date(@{$week->firstday},-1)."}&&&\\texttt{".sprintf("%.2f",$week->initialamount)."}&\\texttt{Alter Kontostand (EUR)}\\\\\\\\\n".
"\\textbf{Nr.}&\\textbf{Datum}&\\textbf{Transaktion}&\\textbf{Soll}&\\textbf{Haben}&\\textbf{Beschreibung}\n");
}

sub print_table_entry
{
  my $week=shift;
  my $number=shift;
  my $day=shift;
  my $typ=shift;
  my $amount=shift;
  my $description=shift;

  my $soll="";
  my $haben="";
  if ($typ eq "INPAY" or $typ eq "INTRANS" or $typ eq "INTEREST") {$haben=$amount;}
  if ($typ eq "OUTPAY" or $typ eq "OUTTRANS") {$soll="-".$amount;}

  my $typ_name=$Papabank::Output::transactiontypes{$typ};

  my $hline="";
  if ($number eq "1") {$hline="\\hline";}

  return ("\\\\".$hline."\\texttt{$number}&\\texttt{".Papabank::Output::print_date(@{$week->firstday},$day)."}&\\texttt{$typ_name}&\\texttt{$soll}&\\texttt{$haben}&\\texttt{$description}\n");
}

sub print_table_closing
{
  my $week=shift;

  return ("\\\\\\hline".
"\\rowcolor{white}\\\\".
"\\rowcolor{gray!25}\n".
"&\\texttt{".Papabank::Output::print_date(@{$week->firstday},$week->lastusedday)."}&&&\\texttt{".sprintf("%.2f",$week->finalamount)."}&\\texttt{Neuer Kontostand (EUR)}".
"\\end{tabular}\n\\end{center}\n".
"\n".
"\\end{g-brief}\n".
"\n");
}

sub print_closing
{
  return ("\\end{document}\n");
}

1;

