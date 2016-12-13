include "globals.mzn";

int : nbESG;
set of int: ESG = 1..nbESG;

int : nbUE;
set of int: UE = 1..nbUE;

int : nbEC = 3; %nombre d'enseignants
set of int : EC = 1..nbEC;

array[ESG, UE] of int : groupesUE;
array[ESG, UE] of int : heuresUE;
array[ESG] of string : nomESG;

int: nbHeuresECmax = 200;
int: nbHeuresECmin = 100;

array[ESG, UE] of var EC : ECUE;
constraint forall(i in ESG)(sum(row(ECUE, i)) < nbHeuresECmax);
constraint forall(i in ESG)(sum(row(ECUE, i)) > nbHeuresECmin);

solve satisfy;