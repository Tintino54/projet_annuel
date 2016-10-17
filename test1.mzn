include "globals.mzn";

%types de cours
set of int: cours = 1..3;

%association nombre d'heures de cours et cours
array[cours] of int : horaires = [2, 1, 3];

%array[1..6] of var 0..3 :jour;

array[1..7, 1..6] of var 0..3 :semaine;

%constraint forall(i in cours)(count(jour, i, horaires[i]));
constraint forall(i in cours, j in 1..7 where j = i)(count(row(semaine, j), i, horaires[i]));

solve satisfy;