include "globals.mzn";


% paramètres
int: nb_creneau;
int: max_UE;
int: nb_groupe_td;
int: nb_groupe_tp;

set of int : COURS;   % nombre de cours comprenant le cours vide 0
set of int : UE;      % nombre d' UE
set of int : TYPE;    % nombre de types de cours 
set of int : PROF;    % nombre de professseurs
set of int : GROUPE;  % nombre de groupes
set of int : CRENEAU; % nombre de creneaux

% Volume horaire des UE par type ( cours, TD, TP )
array[UE,TYPE] of int : volume;

% Affectation des profs à chaque UE par type 
array[UE,TYPE] of PROF : profs;

% Matrice d'adjacence du graphe des dépendances des groupes 
array[GROUPE, GROUPE] of bool : dependances_groupes;
set of int: INDICE = 1..20;


array[GROUPE, CRENEAU] of var COURS: edt1;
array[GROUPE, CRENEAU] of var INDICE: edt2;
array[UE] of var UE: ue;

constraint forall(i in UE)(ue[i] = i);

%TODO , généraliser
%prendre la première ligne comme ligne de CM
constraint distribute( ue, row(edt1, 1)) = col(volume, 1);
%prendre les x lignes de groupe de TD
constraint forall(i in 2..1+nb_groupe_td)(distribute( ue, row(edt1, i)) = col(volume, 2));
%prendre les x lignes de groupe de TP
constraint forall(i in 2+nb_groupe_td..nb_groupe_tp+1+nb_groupe_td)(distribute( ue, row(edt1, i)) = col(volume, 3));

solve satisfy;
output [ show(edt1[i, j]) ++
    if j == nb_creneau then "\n" else " " endif ++ if j mod 6 == 0 then "  " else "" endif| i in GROUPE, j in CRENEAU
];