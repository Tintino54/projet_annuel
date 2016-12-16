import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;



public class Main {
	
	public static String initial = "ChosesSures.tur";
	public static String result = "initial_constraint.mzn";
	
	public static void main(String[] args) throws IOException {
		
		ArrayList<ConstraintEDT> constraintsEDT = new ArrayList<ConstraintEDT>();
		ArrayList<ConstraintPROF> constraintsPROF = new ArrayList<ConstraintPROF>();
		try (BufferedReader br = new BufferedReader(new FileReader(new File(initial)))) {
		    String line;
		    File sortie = new File(result);
		    sortie.createNewFile();
		    FileWriter fw = new FileWriter(sortie);
		    while ((line = br.readLine()) != null) {
		    	if(!line.subSequence(0, 1).equals("a"))
		    		constraintsEDT.add(createConstraintEDT(line));
		    	else
		    		constraintsPROF.add(createConstraintPROF(line));
		    }
		    String res = "";
		    String kindOfGroup;
		    ConstraintEDT current;
		    String realGroupValue = "";
		    String groupeID = "";
		    for(int i = 0; i < constraintsEDT.size(); i++){
		    	current = constraintsEDT.get(i);
		    	
		    	kindOfGroup = current.getGroupe().substring(0,2);
		    	
		    	groupeID = current.getGroupe().substring(2,current.getGroupe().length());
		    	if(kindOfGroup.equals("CM")){
		    		realGroupValue = "1";
		    	}else if(kindOfGroup.equals("TD")){
		    		realGroupValue = "1+"+groupeID;
		    	}else if(kindOfGroup.equals("TP")){
		    		realGroupValue = "1+nb_groupe_td+"+groupeID;
		    	}
		    	res = res + "constraint edt1["+realGroupValue+","+current.getCreneau()+"] = "+current.getUE()+";" + "\n";
		    }
		    
		    ConstraintPROF currentPROF;
		    for(int i = 0; i < constraintsPROF.size(); i++){
		    	currentPROF = constraintsPROF.get(i);
		    	/*constraint forall(i in GROUPE, j in 7..14)(
		    			  prof_edt[i, j] != 3
		    	);*/
		    	res = res + "constraint forall(i in GROUPE, j in "+currentPROF.valueCreneau()+")(" +
		    			"prof_edt[i,j] != "+currentPROF.getNumProf()+");";
		    			
		    }
		    
		    fw.write(res);
		    System.out.println(res);
		    fw.close();
		}
	}
	
	public static ConstraintEDT createConstraintEDT(String line){
		String groupe, creneau, ue;
		
		String tab[] = new String[2];
		tab = line.split(",");
		groupe = tab[0].substring(1, tab[0].length());
		String part2[] = new String[2];
		part2 = tab[1].split("]");
		creneau = part2[0];
		tab = line.split("UE");
		ue = tab[1];
		
		return new ConstraintEDT(groupe, creneau, ue);
	}
	
	public static ConstraintPROF createConstraintPROF(String line){
		String prof, semaine, jour;
		
		String tab[] = new String[3];
		tab = line.split(",");
		String profs[] = new String[2];
		profs = tab[0].split("prof");
		prof = profs[1];
		String semaines[] = tab[1].split("semaine");
		semaine = semaines[1];
		jour = tab[2].substring(0, tab[2].length()-1);
		
		
		return new ConstraintPROF(prof, semaine, jour);
	}
}