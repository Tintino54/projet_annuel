include "globals.mzn";

%types de cours
set of int: cours = 1..3;

%association nombre d'heures de cours et cours
array[cours] of int : horaires = [2, 7, 3];

%array[1..6] of var 0..3 :jour;

array[1..7, 1..6] of var 0..3 :semaine;

% répartition des blocs de cours en fonction des semaines
constraint forall(i in cours)(sum(j in 1..7)(sum(k in 1..6 )( bool2int(semaine[j,k]=i) )) = horaires[i] );


solve satisfy;