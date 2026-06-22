/**
 * @description       : Ms Utility class for callouts from SF to ML
 * @author            : Christian Niro
 * @group             : 
 * @last modified on  : 06-22-2026
 * @last modified by  : Christian Niro
**/
public without sharing class MSCalloutUtility {

    public class JsonMsResponse {
        public Integer ACK { get; set; }//1 OK, 0 KO
        public String IntegrationFlow { get; set; }
        public String Systems { get; set; }//System
        public String TypeOfError { get; set; }
        public String Environment { get; set; }
        public Integer ErrorCode { get; set; }
        public String ErrorMessage { get; set; }
        public String Country { get; set; }
        public String idSAP { get; set; }
    }
    

    public class JsonEtMessage {
        public String TYPE { get; set; }//Tp. mess.: S esito pos., E err., W avvert., I inf., A term.
        public String ID { get; set; }//Classe messaggi
        public String MESSAGE { get; set; }//Testo messaggio
        public String LOG_NO { get; set; }//Registro applicazione: numero registro
        public String MESSAGE_V1 { get; set; }//Variabile messaggio
        public String MESSAGE_V2 { get; set; }//Variabile messaggio
        public String MESSAGE_V3 { get; set; }//Variabile messaggio
        public String MESSAGE_V4 { get; set; }//Variabile messaggio
        public String PARAMETER { get; set; }//Nome parametro
        public String ROW { get; set; }//Riga nel parametro
        public String FIELD { get; set; }//Campo nel parametro
        public String BUSINESS_EXCEPTION { get; set; }//Indicatore a una posizione
    }

}