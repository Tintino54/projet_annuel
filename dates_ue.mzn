include "globals.mzn";
include "parameters.mzn";
include "absolute_data.mzn";

%% Variables de décision %%

array[GROUPE, CRENEAU] of var COURS: edt1;
array[UE] of var UE: ue;

array[GROUPE] of var int: nb_trou;
var int: premier_creneau_libre;
var int: dernier_creneau_libre;
array[GROUPE,1..nb_creneau div 6] of var COURS: pcl;
array[GROUPE,1..nb_creneau div 6] of var COURS: dcl;

%permet de remplir le tableau des UE
constraint forall(i in UE)(ue[i] = i);

%% Contraintes %%

%Cette contrainte sert à placer le volume horaire dans l'emploi du temps
%Elle force les cours à se placer dans l'emploi du temps
constraint distribute( ue, row(edt1, 1)) = col(volume, 1);
constraint forall(i in 2..1+nb_groupe_td)(distribute( ue, row(edt1, i)) = col(volume, 2));
constraint forall(i in 2+nb_groupe_td..nb_groupe_tp+1+nb_groupe_td)(distribute( ue, row(edt1, i)) = col(volume, 3));

% ----------------------------------------------------TEST-SPECIFIQUE-SUR-CETTE-CONTRAINTE--------------------------------
% contraintes de précédence optimisées, une UE doit commencer avant une certaine UE et finir avant une certaine UE
constraint forall(i in 1..max(min_ue), j in GROUPE)(edt1[j,i] != 0 -> min_ue[edt1[j,i]] <= i);
constraint forall(i in min(max_ue)..nb_creneau, j in GROUPE)(edt1[j,i] != 0 -> max_ue[edt1[j,i]] >= i); 

solve :: int_search([edt1[i,j] | i in GROUPE, j in CRENEAU],input_order,indomain_max,complete) satisfy;

output ["   UE" ++ show(UE[i]) ++ "   "|i in UE] ++ ["\n "] ++ ["CM TD TP "|i in UE] ++ ["\n"] ++ [ " " ++ show(volume[i,j]) ++ " "| i in UE, j in TYPE] ++ ["\n "] ++ [show(edt1[i, j])++
    if j == nb_creneau then "\n" else " " endif ++ if j mod max_groupe == 0 then " " else "" endif  | i in GROUPE, j in CRENEAU
];