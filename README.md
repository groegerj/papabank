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

todo

PREREQUISITES
=====================================================================

Debian packages:

*  package perl-modules
*  libdate-calc-perl
*  libcurses-ui-perl
*  texlive-latex-extra
*  texlive-lang-german

todo

USAGE
=====================================================================

First create directories:

    mkdir -p accounts/jimknopf/statements
    mkdir -p accounts/jimknopf/tmp
    mkdir -p accounts/jimknopf/transactions

Invoke the program by

    ./papabank jimknopf

replace jimknopf by any account name, for which you have created
an according subdirectory of 'accounts'. Every account needs a
configuration file account.dat (to be written by hand) such as

accounts/jimknopf/accounts.dat

so far not internationalised but hardcoded in German language

todo
