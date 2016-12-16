
public class ConstraintPROF {
	private String num_semaine;
	private String num_prof;
	private String jour_semaine;

	public ConstraintPROF(String np, String ns, String js){
		num_semaine = ns;
		num_prof = np;
		jour_semaine = js;	
	}

	public String valueCreneau(){
		int coeff_jour;
		switch (jour_semaine) {
		case "lundi":
			coeff_jour = 0;
			break;
		case "mardi":
			coeff_jour = 1;
			break;
		case "mercredi":
			coeff_jour = 2;
			break;
		case "jeudi":
			coeff_jour = 3;
			break;
		case "vendredi":
			coeff_jour = 4;
			break;
		case "samedi":
			coeff_jour = 5;
			break;
		case "dimanche":
			coeff_jour = 6;
			break;
		default:
			coeff_jour = 5000;
			break;
		}
		int indice1 = 30*(Integer.parseInt(num_semaine)-1)+6*coeff_jour+1;
		int indice2 = indice1 + 5;
		return indice1+".."+indice2;
	}
	
	public String getNumProf(){
		return num_prof;
	}

}
