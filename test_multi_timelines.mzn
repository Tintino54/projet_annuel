include "globals.mzn";
include "parameters.mzn";
include "initial_constraint.mzn";
include "absolute_data.mzn";
%include "jours_feries.mzn";

%% Variables de décision %%

array[GROUPE, CRENEAU] of var COURS: edt1;
%array[GROUPE, CRENEAU] of var INDICE: edt2;
array[UE] of var UE: ue;

array[GROUPE] of var int: nb_trou;
var int: premier_creneau_libre;
var int: dernier_creneau_libre;
array[GROUPE,1..nb_creneau div 6] of var COURS: pcl;
array[GROUPE,1..nb_creneau div 6] of var COURS: dcl;

array[GROUPE, CRENEAU] of var 0..nb_profs: prof_edt;

constraint forall(i in UE)(ue[i] = i);

var int : nb_differences;

%% Contraintes %%

%remplit matrice des profs
constraint forall(i in GROUPE, j in CRENEAU)(
  if edt1[i,j] > 0 then prof_edt[i,j] = profs[edt1[i,j], type_groupe[i]] else true endif
);

% Un prof ne peut pas donner deux cours en même temps
constraint forall(i in PROF,j in CRENEAU)(sum(k in GROUPE)(bool2int(profs[edt1[k,j],type_groupe[k]]=i))<=1);

% Contrainte dépendance des groupes
constraint forall(i in CRENEAU,j in GROUPE, k in j+1..max_groupe)(dependances_groupes[j,k] -> (edt1[j,i] > 0 /\ edt1[k,i] > 0) == 0);   

%prendre la première ligne comme ligne de CM

constraint distribute( ue, row(edt1, 1)) = col(volume, 1);
constraint forall(i in 2..1+nb_groupe_td)(distribute( ue, row(edt1, i)) = col(volume, 2));
constraint forall(i in 2+nb_groupe_td..nb_groupe_tp+1+nb_groupe_td)(distribute( ue, row(edt1, i)) = col(volume, 3));

%pas cours le jeudi après-midi
constraint forall(i in GROUPE, j in CRENEAU, where j mod 30 = 22 \/ j mod 30 = 23 \/ j mod 30 = 24)(edt1[i,j] = 0);

%todo définition des trous, un trou est pour un paquet de 6, les cours à 0 entre le premier et dernier cours
constraint forall(i in GROUPE)(
  count(row(edt1, i), 0, nb_trou[i])
);

%Pour favoriser les cours commençant après le créneau 1 et finissant avant le créneau 6 tous les jours
constraint forall(i in 1..(nb_creneau div cr_par_jour), j in GROUPE)(row(edt1,j)[(i-1)*cr_par_jour+1] = pcl[j,i]);
constraint premier_creneau_libre = sum(i in GROUPE)(count(row(pcl, i), 0));
constraint forall(i in 1..(nb_creneau div cr_par_jour), j in GROUPE)(row(edt1,j)[i*cr_par_jour] = dcl[j,i]);
constraint dernier_creneau_libre = sum(i in GROUPE)(count(row(dcl, i), 0));

% contraintes de précédence optimisées
constraint forall(i in 1..max(min_ue), j in GROUPE)(edt1[j,i] != 0 -> min_ue[edt1[j,i]] <= i);
constraint forall(i in min(max_ue)..nb_creneau, j in GROUPE)(edt1[j,i] != 0 -> max_ue[edt1[j,i]] >= i); 

%assigner les cours selon leur priorité
%constraint forall(i in CRENEAU, j in CRENEAU where j > i /\ edt1[1,i] != 0 /\ edt1[1,j] != 0)(priorite_ue[edt1[1,i]] < priorite_ue[edt1[1,j]]);

% contrainte de redondance fait en sorte que chaque semaine ressemble le plus à la semaine précédente 
constraint nb_differences = sum(s in 1..nb_creneau div (cr_par_jour * jours_par_semaine) - 1, i in GROUPE, j in 1..cr_par_jour * jours_par_semaine)
                               (bool2int(edt1[i,j + (cr_par_jour * jours_par_semaine) * (s-1)] != edt1[i, j + (cr_par_jour * jours_par_semaine) * s])
                            );

%solve maximize premier_creneau_libre + dernier_creneau_libre;
solve :: int_search([edt1[i,j] | i in GROUPE, j in CRENEAU],input_order,indomain_max,complete) satisfy;

%function int: count_gaps(array of int: ) = ;

output ["   UE" ++ show(UE[i]) ++ "   "|i in UE] ++ ["\n "] ++ ["CM TD TP "|i in UE] ++ ["\n"] ++ [ " " ++ show(volume[i,j]) ++ " "| i in UE, j in TYPE] ++ ["\n "] ++ [show(edt1[i, j])++
    if j == nb_creneau then "\n" else " " endif ++ if j mod max_groupe == 0 then " " else "" endif  | i in GROUPE, j in CRENEAU
];