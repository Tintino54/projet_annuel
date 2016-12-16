include "globals.mzn";
include "parameters.mzn";
include "absolute_data.mzn";
include "initial_constraint.mzn";

predicate custom_count(array [int] of var int: x, set of int: s,var int: y, var int: c) =
c==sum ( i in s ) ( bool2int(x[i]==y) );

function var int: calcfa(var int: x, int: y) = y+x;
function var int: calcfb(var int: x, int: y) = y+x;



%% Variables de décision %%

%gestion séances d'ecart
array[UE] of var 0..nb_creneau/2 : seances_decart_par_UE;
array[CRENEAU, UE] of var 0..nb_creneau/2 : seances_decart_entre_TP;
array[CRENEAU, UE] of var 0..nb_creneau/2 : seances_decart_entre_TD;

array[GROUPE, CRENEAU] of var COURS: edt1;
array[UE] of var UE: ue;

array[GROUPE] of var int: nb_trou;
var int: premier_creneau_libre;
var int: dernier_creneau_libre;
array[GROUPE,1..nb_creneau div 6] of var COURS: pcl;
array[GROUPE,1..nb_creneau div 6] of var COURS: dcl;
array[GROUPE, CRENEAU] of var 0..nb_profs: prof_edt;


array[1..nb_groupe_td-1] of var 1..200: gestion_indice_td;

array[GROUPE, CRENEAU, UE] of var 0..nb_creneau div 2: seance_ecart_compteur_TD;
array[GROUPE_DEUX_A_DEUX_TD, CRENEAU, UE] of var 0..nb_creneau div 2: seance_ecart_groupe_dad;
array[CRENEAU, UE] of var 0..nb_creneau div 2: seance_ecart_compteur_calculated_TD;

%permet de remplir le tableau des UE
constraint forall(i in UE)(ue[i] = i);

%% Contraintes %%

%Cette contrainte sert à placer le volume horaire dans l'emploi du temps
%Elle force les cours à se placer dans l'emploi du temps
constraint distribute( ue, row(edt1, 1)) = col(volume, 1);
constraint forall(i in 2..1+nb_groupe_td)(distribute( ue, row(edt1, i)) = col(volume, 2));
constraint forall(i in 2+nb_groupe_td..nb_groupe_tp+1+nb_groupe_td)(distribute( ue, row(edt1, i)) = col(volume, 3));

% Contrainte dépendance des groupes, permet de tester la contrainte, pas trop de séances d'écart entre les différents groupes
constraint forall(i in CRENEAU,j in GROUPE, k in j+1..max_groupe)(dependances_groupes[j,k] -> (edt1[j,i] > 0 /\ edt1[k,i] > 0) == 0);

% ----------------------------------------------------TEST-SPECIFIQUE-SUR-CETTE-CONTRAINTE--------------------------------

%pour les groupes de TP par exemple
%pour le groupes de TP1 TP2 et TP3 par exemple
%il faut regarder entre les groupes pour un cours donné le nombre maximal de séances d'écart à un moment donné
%donc pour chaque créneau, il faut regarder le nombre de séance d'écart pour un cours
%on récupère ce maximum dans une variable
%il faut minimiser ce maximum
  %il faut compter à chaque créneau le nombre de séances des groupes, récuperer la différence entre le min et le max
  %entrer le résultat dans un tableau
  %récupérer le minimum de ce résultat dans seances_decart_par_UE

%gestion des indices
%gérer les indices pour pouvoir faire la boucle pour pouvoir gérer les groupes deux à deux
%pour ensuite définir le tableau des maximums de séance d'écart par UE
%minimiser ensuite ces séances d'écart
constraint forall(i in nb_groupe_td-1..1)(
  gestion_indice_td[nb_groupe_td-i] = i + gestion_indice_td[nb_groupe_td-i-1]
);

%remplir le compteur
constraint forall(i in GROUPE, j in CRENEAU, k in UE, where type_groupe[i] == TD)(
  custom_count(row(edt1, i), 1..j, k,seance_ecart_compteur_TD[i,j,k])
);
constraint forall(i in GROUPE_DEUX_A_DEUX_TD, j in CRENEAU, k in UE, where type_groupe[i] == TD)(
  seance_ecart_groupe_dad[i,j,k]=abs(seance_ecart_compteur_TD[calcfa(i, nb_groupe_td), j, k] - seance_ecart_compteur_TD[calcfb(i, nb_groupe_td), j, k])
);
/*constraint forall(i in GROUPE, j in CRENEAU, k in UE, where type_groupe[i] == TD)(
  seance_ecart_compteur_calculated_TD[j, k] = row()
);*/




solve :: int_search([edt1[i,j] | i in GROUPE, j in CRENEAU],input_order,indomain_max,complete) satisfy;

output ["   UE" ++ show(UE[i]) ++ "   "|i in UE] ++ ["\n "] ++ ["CM TD TP "|i in UE] ++ ["\n"] ++ [ " " ++ show(volume[i,j]) ++ " "| i in UE, j in TYPE] ++ ["\n "] ++ [show(seance_ecart_compteur_TD[i, j, 1])++
    if j == nb_creneau then "\n" else " " endif ++ if j mod max_groupe == 0 then " " else "" endif  | i in GROUPE, j in CRENEAU
];