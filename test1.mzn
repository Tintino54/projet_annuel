include "globals.mzn";

%types de cours
set of int: nb_cours = 1..3;
set of int: nb_jours = 1..7;
set of int: nb_creneaux = 1..6;
set of int: nb_creneaux_semaine = 1..(6*7);
%association nombre d'heures de cours et cours
array[nb_cours] of int : horaires = [2, 14, 3];

%array[1..6] of var 0..3 :jour;

array[nb_jours, nb_creneaux] of var 0..3 :semaine;
array[1..42] of var 0..3 : semaine1d;

%constraint forall(i in cours)(count(jour, i, horaires[i]));
constraint semaine1d = row(semaine, 1)++row(semaine, 2)++row(semaine, 3)++row(semaine, 4)++row(semaine, 5)++row(semaine, 6)++row(semaine, 7);
constraint forall(i in nb_cours)(count(semaine1d, i, horaires[i]));

solve satisfy;