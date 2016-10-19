include "globals.mzn";


%% Paramètres %%

int: nb_creneau;
int: max_UE;
int: max_groupe;
int: nb_groupe_td;
int: nb_groupe_tp;

set of int : COURS;   % nombre de cours comprenant le cours vide 0
set of int : UE;      % nombre d' UE
set of int : TYPE;    % nombre de types de cours 
set of int : PROF;    % nombre de professseurs
set of int : GROUPE;  % nombre de groupes
set of int : CRENEAU; % nombre de creneaux

array[GROUPE] of TYPE : type_groupe;

% Volume horaire des UE par type ( cours, TD, TP )
array[UE,TYPE] of int : volume;

% Affectation des profs à chaque UE par type 
array[UE,TYPE] of PROF : profs;

% Matrice d'adjacence du graphe des dépendances des groupes 
array[GROUPE, GROUPE] of bool : dependances_groupes;
set of int: INDICE = 1..20;

%% Variables de décision %%

array[GROUPE, CRENEAU] of var COURS: edt1;
array[GROUPE, CRENEAU] of var INDICE: edt2;
array[UE] of var UE: ue;

constraint forall(i in UE)(ue[i] = i);

%% Contraintes %%

% Un prof ne peut pas donner deux cours en même temps
constraint forall(i in PROF,j in CRENEAU)(sum(k in GROUPE)(bool2int(profs[edt1[k,j],type_groupe[k]]=i))<=1);  

% Contrainte dépendance des groupes
constraint forall(i in CRENEAU,j in GROUPE, k in j+1..max_groupe)(dependances_groupes[j,k] -> (edt1[j,i] > 0 /\ edt1[k,i] > 0) == 0);   

% Prendre la première ligne comme ligne de CM
constraint distribute( ue, row(edt1, 1)) = col(volume, 1);
% Prendre les x lignes de groupe de TD
constraint forall(i in 2..1+nb_groupe_td)(distribute( ue, row(edt1, i)) = col(volume, 2));
% Prendre les x lignes de groupe de TP
constraint forall(i in 2+nb_groupe_td..nb_groupe_tp+1+nb_groupe_td)(distribute( ue, row(edt1, i)) = col(volume, 3));

solve satisfy;
output [ show(edt1[i, j]) ++
    if j == nb_creneau then "\n" else " " endif ++ if j mod 6 == 0 then "  " else "" endif| i in GROUPE, j in CRENEAU
];