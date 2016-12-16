
public class ConstraintEDT {
	private String groupe;
	private String creneau;
	private String UE;
	public ConstraintEDT(String g, String c, String u){
		groupe = g;
		creneau = c;
		UE = u;
	}
	
	public String getCreneau(){
		return creneau;
	}
	public String getGroupe(){
		return groupe;
	}
	public String getUE(){
		return UE;
	}

}
