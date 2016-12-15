include "globals.mzn";

%fichier expérimental pour les jours feries
%comme on fonctionne sur un modèle de 30 créneaux par semaine
%un modèle à l'année fonctionne différamment

/*
France 	                  2016 	            2017 	2018
Jour de l'an 	        1 Janvier 	1 Janvier 	1 Janvier
Lundi de Pâques 	28 Mars 	17 Avril 	2 Avril
Fête du Travail 	1 Mai 	        1 Mai 	        1 Mai
8 Mai 1945 	        8 Mai 	        8 Mai 	        8 Mai
Jeudi de l'Ascension 	5 Mai 	        25 Mai 	        10 Mai
Lundi de Pentecôte 	16 Mai 	        5 Juin 	        21 Mai
Fête Nationale 	        14 Juillet 	14 Juillet 	14 Juillet
Assomption 	        15 Août 	15 Août 	15 Août
La Toussaint 	        1 Novembre 	1 Novembre 	1 Novembre
Armistice 	        11 Novembre 	11 Novembre 	11 Novembre
Noël 	                25 Décembre 	25 Décembre 	25 Décembre
*/

int: lundi        = 1;
int: mardi        = 2;
int: mercredi     = 3;
int: jeudi        = 4;
int: vendredi     = 5;
int: samedi       = 6;
int: dimanche     = 7;


%mettre à 1 si année bissextile
int: bissextile = 0;
%définir le premier jour de l'année pour le calcul de l'emploi du temps en fonction
int: premier_jour_de_lanne = mardi;

%nombre de créneaux par mois, malheureusement, prend les weekends en compte
int:janvier =   31 *              cr_par_jour;
int:fevrier =   28 + bissextile * cr_par_jour;
int:mars =      31 *              cr_par_jour;
int:avril =     30 *              cr_par_jour;
int:mai =       31 *              cr_par_jour;
int:juin =      30 *              cr_par_jour;
int:juillet =   31 *              cr_par_jour;
int:aout =      31 *              cr_par_jour;
int:septembre = 30 *              cr_par_jour;
int:octobre =   31 *              cr_par_jour;
int:novembre =  30 *              cr_par_jour;
int:decembre =  31 *              cr_par_jour;

%définir à droite le jour férié
%ps: faire attention au lundi de pâques qui peut être sur différents mois
int: cr_premier_janvier =                                                                                    1;
int: cr_lundi_paque =          janvier+fevrier+                                                              28;
int: cr_fete_travail =         janvier+fevrier+mars+avril+                                                   1;
int: cr_huit_mai =             janvier+fevrier+mars+avril+                                                   8;
int: cr_jeudi_ascension =      janvier+fevrier+mars+avril+                                                   5;
int: cr_lundi_pentecote =      janvier+fevrier+mars+avril+                                                   16;
int: cr_fete_nationale =       janvier+fevrier+mars+avril+mai+juin+                                          14 ;
int: cr_assomption =           janvier+fevrier+mars+avril+mai+juin+juillet+                                  15;
int: cr_toussaint =            janvier+fevrier+mars+avril+mai+juin+juillet+aout+septembre+octobre+           1;
int: cr_armistice =            janvier+fevrier+mars+avril+mai+juin+juillet+aout+septembre+octobre+           11;
int: cr_noel =                 janvier+fevrier+mars+avril+mai+juin+juillet+aout+septembre+octobre+novembre+  25;

%pas cours le jour de l'an
constraint forall(i in GROUPE, j in cr_premier_janvier..    cr_par_jour+cr_premier_janvier-1)  (edt1[i,j] = 0);
constraint forall(i in GROUPE, j in cr_lundi_paque..        cr_par_jour+cr_lundi_paque-1)      (edt1[i,j] = 0);
constraint forall(i in GROUPE, j in cr_fete_travail..       cr_par_jour+cr_fete_travail-1)     (edt1[i,j] = 0);
constraint forall(i in GROUPE, j in cr_huit_mai..           cr_par_jour+cr_huit_mai-1)         (edt1[i,j] = 0);
constraint forall(i in GROUPE, j in cr_jeudi_ascension..    cr_par_jour+cr_jeudi_ascension-1)  (edt1[i,j] = 0);
constraint forall(i in GROUPE, j in cr_lundi_pentecote..    cr_par_jour+cr_lundi_pentecote-1)  (edt1[i,j] = 0);
constraint forall(i in GROUPE, j in cr_fete_nationale..     cr_par_jour+cr_fete_nationale-1)   (edt1[i,j] = 0);
constraint forall(i in GROUPE, j in cr_assomption..         cr_par_jour+cr_assomption-1)       (edt1[i,j] = 0);
constraint forall(i in GROUPE, j in cr_toussaint..          cr_par_jour+cr_toussaint-1)        (edt1[i,j] = 0);
constraint forall(i in GROUPE, j in cr_armistice..          cr_par_jour+cr_armistice-1)        (edt1[i,j] = 0);
constraint forall(i in GROUPE, j in cr_noel..               cr_par_jour+cr_noel-1)             (edt1[i,j] = 0);


%pas cours les weekends
%Contrainte à faire en fonction du premier jour de l'annee