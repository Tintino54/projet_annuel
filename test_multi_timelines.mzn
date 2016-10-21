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

% volume : Volume horaire des UE par type ( cours, TD, TP )
% prof : Affectation des profs à chaque UE par type 
% priorite_ue : Priorité des cours
% limite_ue : Creneau limite avant fin du module, un module doit se finir avant ce créneau limite
% dependances_groupe : Matrice d'adjacence du graphe des dépendances des groupes 

array[GROUPE] of TYPE : type_groupe;
array[UE,TYPE] of int : volume;
array[UE,TYPE] of PROF : profs;
array[UE] of int: priorite_ue;
array[UE] of int: max_ue;
array[UE] of int: min_ue;
array[GROUPE, GROUPE] of bool : dependances_groupes;
set of int: INDICE = 1..20;

%% Variables de décision %%

array[GROUPE, CRENEAU] of var COURS: edt1;
array[GROUPE, CRENEAU] of var INDICE: edt2;
array[UE] of var UE: ue;

var int: nb_trou;
var int: premier_creneau_libre;
var int: dernier_creneau_libre;
%array[GROUPE, 1..5] of var COURS: pcl;
array[GROUPE,1..5] of var COURS: pcl;
array[GROUPE,1..5] of var COURS: dcl;

constraint forall(i in UE)(ue[i] = i);

%% Contraintes %%

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

%todo définition des trous, un trou est pour un paquet de 6, le 2ème et le 5ème
%constraint count(row(edt1, 1), 0, nb_trou);

%Pour favoriser les cours commençant après le créneau 1 et finissant avant le créneau 6 tous les jours
constraint forall(i in 1..(nb_creneau div 6), j in GROUPE)(row(edt1,j)[(i-1)*6+1] = pcl[j,i]);
constraint premier_creneau_libre = sum(i in GROUPE)(count(row(pcl, i), 0));
constraint forall(i in 1..(nb_creneau div 6), j in GROUPE)(row(edt1,j)[i*6] = dcl[j,i]);
constraint dernier_creneau_libre = sum(i in GROUPE)(count(row(dcl, i), 0));


solve maximize premier_creneau_libre + dernier_creneau_libre;

output [ show(edt1[i, j]) ++
    if j == nb_creneau then "\n" else " " endif ++ if j mod 6 == 0 then "  " else "" endif | i in GROUPE, j in CRENEAU
];