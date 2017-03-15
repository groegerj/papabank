papabank
=====================================================================

Copyright (C) 2016-2017 Josua Groeger.
groegerj at thp.uni-koeln dot de

papabank is a perl program with an ncurses GUI for managing
something like a bank account, mainly intended for pocket money.

LICENSE
=====================================================================

papabank is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

papabank is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with papabank.  If not, see <http://www.gnu.org/licenses/>.

PURPOSE
=====================================================================

papabank is a perl program with an ncurses GUI for managing
something like a bank account, mainly intended for pocket money.

Become your own bank and manage accounts for your children.
Let them give the coins they recently got from grandma to you the bank,
instead of hiding them under the rug, and give back cash as needed.
papabank gives you an easy way to keep track of this.

It works on a weekly basis. Every week (starting with the day defined
for the account) corresponds to one simple data file. On a payment
or transmission, only the data file of the current week is altered
(date and time should be roughly correct on your system),
while the previous week data are left untouched.
On program start, missing week data files are generated (say e.g. you
haven't run the program for three weeks).
Moreover, bank statements are generated for the past weeks (if not
yet generated) in PDF format.
You may specify a weekly amount of (pocket) money which is paid to the
account. Moreover, every four weeks a defined percentage of interest
is paid in addition to the pocket money.

PREREQUISITES
=====================================================================

papabank requires a working pdflatex command and some perl stuff.
On Debian, the following packeges should be installed.

*  package perl-modules
*  libdate-calc-perl
*  libcurses-ui-perl
*  texlive-latex-extra
*  texlive-lang-german

papabank uses the Perl package Date::Day for calculating the
day of the week for some date. In the first version, this was
John Von Essen's implementation. However, since the license
is not really clear and the author was not responsive,
I replaced the package by my own implementation (file Day.pm).
I left the name and interface unchanged (drop-in replacement),
which might cause a problem, if someone has the original
Date::Day installed.

BUGS
=====================================================================

papabank was written in a very short period of time, in summer 2016.
Besides, it was my first Perl program larger than a simple script.

This said, the code is quite ugly. Moreover

*  German language is hardcoded.
*  The generated PDF bank statements are broken if some week enjoys
   too many payments or transactions (missing table/page breaks).
*  Bank and account data still have to be written by hand in the data
   files (see the example provided).
*  Does not check missing system requirements.
*  Program and data are not separated.
*  PDF files are generated on program start, before the user interface
   is shown. There should be some better solution.
*  Routine for calculating interest is over-simple.
*  Never run two or more instances of papabank on one set of data,
   for otherwise there might be inconsistencies.
*  Only one bank supported so far.
*  Probably many more problems.

I have used the program for many months without noticing any
problems besides those listed above.

USAGE
=====================================================================

First create an account. The example provided just misses the
following directories:

    mkdir -p accounts/jimknopf/statements
    mkdir -p accounts/jimknopf/tmp
    mkdir -p accounts/jimknopf/transactions

Invoke the program by

    ./papabank jimknopf

where jimknopf is replace by any (existing) account name,
for which you have created an according subdirectory of 'accounts'.
Every account needs a configuration file account.dat
(to be written by hand) such as

    accounts/jimknopf/accounts.dat

Bank data are stored in the file

    bank.dat

Changes have to be made by hand.

