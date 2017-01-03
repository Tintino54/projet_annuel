constraint edt1[1,3] = 1;
constraint edt1[1+2,5] = 2;
constraint forall(i in GROUPE, j in 7..12)(prof_edt[i,j] != 2);