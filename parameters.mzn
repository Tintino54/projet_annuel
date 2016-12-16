%% Paramètres %%

int: nb_creneau;
int : cr_par_jour = 6;
int: nb_UE;
int: max_groupe;
int: nb_groupe_td;
int: nb_groupe_tp;
int: nb_profs;
var int: ref;
set of int : COURS;   % nombre de cours comprenant le cours vide 0
set of int : UE;      % nombre d' UE
set of int : TYPE;    % nombre de types de cours 
set of int : PROF;    % nombre de professseurs
set of int : GROUPE;  % nombre de groupes
set of int : GROUPE_DEUX_A_DEUX_TD; % nombre de groupes deux à deux (exemple TP1-TP2, TP1-TP3, TP2-TP3) utilisé pour des calcus de séances d'écart
set of int : GROUPE_DEUX_A_DEUX_TP;
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