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
		
		ArrayList<Constraint> constraints = new ArrayList<Constraint>();
		try (BufferedReader br = new BufferedReader(new FileReader(new File(initial)))) {
		    String line;
		    File sortie = new File(result);
		    sortie.createNewFile();
		    FileWriter fw = new FileWriter(sortie);
		    while ((line = br.readLine()) != null) {
		    	constraints.add(createConstraint(line));
		    }
		    String res = "";
		    String kindOfGroup;
		    Constraint current;
		    String realGroupValue = "";
		    String groupeID = "";
		    for(int i = 0; i < constraints.size(); i++){
		    	current = constraints.get(i);
		    	
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
		    
		    fw.write(res);
		    System.out.println(res);
		    fw.close();
		}
	}
	
	public static Constraint createConstraint(String line){
		String tab[] = new String[2];
		tab = line.split(",");
		String groupe = tab[0].substring(1, tab[0].length());
		String part2[] = new String[2];
		part2 = tab[1].split("]");
		String creneau = part2[0];
		tab = line.split("UE");
		String ue = tab[1];
		
		return new Constraint(groupe, creneau, ue);
	}
}
