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
%set of int: INDICE = 1..20;

%% Variables de décision %%

array[GROUPE, CRENEAU] of var COURS: edt1;
%array[GROUPE, CRENEAU] of var INDICE: edt2;
array[UE] of var UE: ue;

array[GROUPE] of var int: nb_trou;
var int: premier_creneau_libre;
var int: dernier_creneau_libre;
%array[GROUPE, 1..5] of var COURS: pcl;
array[GROUPE,1..nb_creneau div 6] of var COURS: pcl;
array[GROUPE,1..nb_creneau div 6] of var COURS: dcl;

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

%todo définition des trous, un trou est pour un paquet de 6, les cours à 0 entre le premier et dernier cours
constraint forall(i in GROUPE)(
  count(row(edt1, i), 0, nb_trou[i])
);


%Pour favoriser les cours commençant après le créneau 1 et finissant avant le créneau 6 tous les jours
/*constraint forall(i in 1..(nb_creneau div cr_par_jour), j in GROUPE)(row(edt1,j)[(i-1)*cr_par_jour+1] = pcl[j,i]);
constraint premier_creneau_libre = sum(i in GROUPE)(count(row(pcl, i), 0));
constraint forall(i in 1..(nb_creneau div cr_par_jour), j in GROUPE)(row(edt1,j)[i*cr_par_jour] = dcl[j,i]);
constraint dernier_creneau_libre = sum(i in GROUPE)(count(row(dcl, i), 0));*/

% contraintes de précédence optimisées
constraint forall(i in 1..max(min_ue), j in GROUPE)(edt1[j,i] != 0 -> min_ue[edt1[j,i]] <= i);
constraint forall(i in min(max_ue)..nb_creneau, j in GROUPE)(edt1[j,i] != 0 -> max_ue[edt1[j,i]] >= i); 

%assigner les cours selon leur priorité
%constraint forall(i in CRENEAU, j in CRENEAU where j > i /\ edt1[1,i] != 0 /\ edt1[1,j] != 0)(priorite_ue[edt1[1,i]] < priorite_ue[edt1[1,j]]);

%solve maximize premier_creneau_libre + dernier_creneau_libre;
solve satisfy;

%function int: count_gaps(array of int: ) = ;

output ["   UE" ++ show(UE[i]) ++ "   "|i in UE] ++ ["\n"] ++ ["CM TD TP "|i in UE] ++ ["\n"] ++ [ " " ++ show(volume[i,j]) ++ " "| i in UE, j in TYPE] ++ ["\n "] ++ [show(edt1[i, j])++ if j == nb_creneau then "\n" else " " endif ++ if j mod cr_par_jour == 0 then " " else "" endif  | i in GROUPE, j in CRENEAU];