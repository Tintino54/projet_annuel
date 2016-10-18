include "globals.mzn";

set of int: nb_cours = 1..3;
set of int: nb_jours = 1..5;
set of int: nb_creneaux = 1..6;
set of int: nb_creneaux_semaine = 1..(6*5);
set of int: GROUPE = 1..6;
set of int: CRENEAU = 1..12;
set of int: UE = 1..12;
set of int: INDICE = 1..20;


array[GROUPE, CRENEAU] of var UE: edt1;
array[GROUPE, CRENEAU] of var INDICE: edt2;

constraint forall(i in CRENEAU)(
  alldifferent(col(edt1, i))
);

solve satisfy;
output [ show(edt1[i, j]) ++
    if j == 12 then "\n" else " " endif | i in GROUPE, j in CRENEAU
];