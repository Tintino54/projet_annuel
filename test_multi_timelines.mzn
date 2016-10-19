include "globals.mzn";


% paramètres
int: nb_creneau;
int: max_UE;
int: max_groupe;
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

%TODO , généraliser
constraint distribute( [1,2,3], row(edt1, 1)) = col(volume, 1);
constraint distribute( [1,2,3], row(edt1, 1)) = col(volume, 2);
constraint distribute( [1,2,3], row(edt1, 1)) = col(volume, 2);
constraint distribute( [1,2,3], row(edt1, 1)) = col(volume, 3);
constraint distribute( [1,2,3], row(edt1, 1)) = col(volume, 3);
constraint distribute( [1,2,3], row(edt1, 1)) = col(volume, 3);

% contrainte dépendance des groupes
constraint edt1[1,1] + bool2int(dependances_groupes[1,1]) = 0;
%constraint forall(i in CRENEAU,j in GROUPE, k in j+1..max_groupe)(int2bool(edt1[k][i]) /\ dependances_groupes[j][k] = 0);   
solve satisfy;
output [ show(edt1[i, j]) ++
    if j == nb_creneau then "\n" else " " endif ++ if j mod 6 == 0 then "  " else "" endif| i in GROUPE, j in CRENEAU
];