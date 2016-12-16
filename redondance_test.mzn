int : cr_par_jour = 3;
int : jour_par_semaine = 1;
int : nb_groupes = 3;
int : nb_semaines = 3;

var int : nb_differences;

array[1..nb_groupes,1..cr_par_jour * jour_par_semaine * nb_semaines] of int : semaines = [|0,0,0,1,2,3,1,2,2|1,1,2,1,2,2,1,2,2|2,2,3,0,3,3,0,3,3|];

constraint nb_differences = sum(s in 1..nb_semaines-1, i in 1..nb_groupes, j in 1..cr_par_jour * jour_par_semaine)
                               (bool2int(semaines[i,j + (cr_par_jour * jour_par_semaine) * (s-1)] != semaines[i, j + (cr_par_jour * jour_par_semaine) * s])
                            );

solve satisfy;