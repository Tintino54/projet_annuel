include "globals.mzn";

%types de cours
set of int: cours = 1..3;

%association nombre d'heures de cours et cours
array[cours] of int : horaires = [2, 2, 1];

array[1..6] of var 0..3 :jour;

constraint forall(i in cours)(count(jour, i, horaires[i]));

solve satisfy;