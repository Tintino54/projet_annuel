include "globals.mzn";
%% Paramètres %%
int: nb_creneau;
int : cr_par_jour = 6;
int: nb_UE;
int: max_groupe;
int: nb_groupe_td;
int: nb_groupe_tp;
var int: ref;
set of int : COURS;   % nombre de cours comprenant le cours vide 0
set of int : UE;      % nombre d' UE
set of int : TYPE;    % nombre de types de cours 
set of int : PROF;    % nombre de professseurs
set of int : GROUPE;  % nombre de groupes
set of int : CRENEAU; % nombre de creneaux

array[UE] of int : min_ue; % date du premier créneau de chaque UE
array[UE] of int : max_ue; % date du dernier créneau de chaque UE

array[GROUPE] of TYPE : type_groupe;
% volume : Volume horaire des UE par type ( cours, TD, TP )
% prof : Affectation des profs à chaque UE par type 
% priorite_ue : Priorité des cours
% limite_ue : Creneau limite avant fin du module, un module doit se finir avant ce créneau limite
% dependances_groupe : Matrice d'adjacence du graphe des dépendances des groupes 

array[UE,TYPE] of int : volume;
array[UE,TYPE] of PROF : profs;
array[UE] of int: priorite_ue;
array[GROUPE, GROUPE] of bool : dependances_groupes;

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
%Contrainte d'optimisation des créneaux libres de 8 à 9 et de 17 à 18
constraint forall(i in 1..(nb_creneau div cr_par_jour), j in GROUPE)(row(edt1,j)[(i-1)*cr_par_jour+1] = pcl[j,i]);
constraint premier_creneau_libre = sum(i in GROUPE)(count(row(pcl, i), 0));
constraint forall(i in 1..(nb_creneau div cr_par_jour), j in GROUPE)(row(edt1,j)[i*cr_par_jour] = dcl[j,i]);
constraint dernier_creneau_libre = sum(i in GROUPE)(count(row(dcl, i), 0));

%maximiser le nombre de créneaux libre le matin à 8 et à 18h
solve maximize premier_creneau_libre + dernier_creneau_libre;

output [ show(edt1[i, j]) ++
    if j == nb_creneau then "\n" else " " endif ++ if j mod 6 == 0 then "  " else "" endif | i in GROUPE, j in CRENEAU
];