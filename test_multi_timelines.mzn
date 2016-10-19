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

%Priorité des cours
array[UE] of int: priorite_ue;

%Creneau limite avant fin du module, un module doit se finir avant ce créneau limite
array[UE] of int: limite_ue;

% Matrice d'adjacence du graphe des dépendances des groupes 
array[GROUPE, GROUPE] of bool : dependances_groupes;
set of int: INDICE = 1..20;


array[GROUPE, CRENEAU] of var COURS: edt1;
array[GROUPE, CRENEAU] of var INDICE: edt2;
array[UE] of var UE: ue;

var int: nb_trou;

constraint forall(i in UE)(ue[i] = i);

%prendre la première ligne comme ligne de CM
constraint distribute( ue, row(edt1, 1)) = col(volume, 1);
%prendre les x lignes de groupe de TD
constraint forall(i in 2..1+nb_groupe_td)(distribute( ue, row(edt1, i)) = col(volume, 2));
%prendre les x lignes de groupe de TP
constraint forall(i in 2+nb_groupe_td..nb_groupe_tp+1+nb_groupe_td)(distribute( ue, row(edt1, i)) = col(volume, 3));

%pas cours le jeudi après-midi
constraint forall(i in GROUPE, j in CRENEAU, where j mod 30 = 21 \/ j mod 30 = 22 \/ j mod 30 = 23)(edt1[i,j] = 0);

%todo définition des trous, un trou est pour un paquet de 6, le 2ème et le 5ème
constraint count(row(edt1, 1), 0, nb_trou);

%assigner les cours selon leur priorité
%constraint forall(i in CRENEAU, j in CRENEAU where j > i /\ edt1[1,i] != 0 /\ edt1[1,j] != 0)(priorite_ue[edt1[1,i]] < priorite_ue[edt1[1,j]]);

%Un cours doit se terminer avant un certain créneau
%constraint forall(i in UE, j in CRENEAU)(j < limite_ue[i]);

solve satisfy;
output [ show(edt1[i, j]) ++
    if j == nb_creneau then "\n" else " " endif ++ if j mod 6 == 0 then "  " else "" endif | i in GROUPE, j in CRENEAU
];