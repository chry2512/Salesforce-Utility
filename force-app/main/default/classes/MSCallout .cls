/**
 * @description       : 
 * @author            : Christian Niro
 * @group             : 
 * @last modified on  : 06-22-2026
 * @last modified by  : Christian Niro
**/

public without sharing class MSCallout {
        
    public class OutputCallout{
        public String esito;
        public String errorMessage;
        public String idSAP;
        public Decimal OrderedAmount;
        public Decimal RemainingCreditAmount;
        public String errorCode;
    }
    
    public static Map<String, Object> callGenericService(String interfaceId, String jsonRequest, String baseCorrelationId){

        System.debug('callGenericService interfaceId['+interfaceId+'] jsonRequest['+jsonRequest+']');
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        Map<String, Object> outMap = new Map<String, Object>();

        CalloutConfiguration__mdt configurationMdt = retrieveConfiguration(interfaceId);
        //TODO gestire anche la casistica di configurazione assente o disattivata?
        
        String correlationId = getCorrelationId(baseCorrelationId);

        try{
            request.setEndpoint(configurationMdt.EndPoint__c);
            request.setHeader('client_id', configurationMdt.ClientId__c);
            request.setHeader('client_secret', configurationMdt.ClientSecret__c);
            request.setMethod(configurationMdt.HttpMethod__c);
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('correlation-id', correlationId);
            request.setTimeout(120000);
            request.setBody(jsonRequest);
            
            response = http.send(request);

            System.debug('callGenericService response['+response+']');

            outMap.put('RESPONSE_STATUS', response.getStatus());
            outMap.put('RESPONSE_STATUS_CODE', String.valueOf(response.getStatusCode()));
            outMap.put('RESPONSE_BODY', response.getBody());

            if(response.getBody()!=null){
                Map<String, Object> bodyMap= (Map<String, Object>)JSON.deserializeUntyped(response.getBody());


                if(bodyMap.containsKey('ResultFromSAP') && !String.isBlank((String)bodyMap.get('ResultFromSAP'))){
                    String curResponseStatusCode = (String)outMap.get('RESPONSE_STATUS_CODE');
                    String curResponseStatus = (String)outMap.get('RESPONSE_STATUS');
                    String curResultFormSAP = (String)bodyMap.get('ResultFromSAP');

                    if(!'2000'.equalsIgnoreCase(curResultFormSAP)){
                        curResponseStatusCode = curResultFormSAP;
                        //if(bodyMap.containsKey('ErrorMessage')){
                        //    curResponseStatus = (String)bodyMap.get('ErrorMessage');
                        if(bodyMap.containsKey('ErrorDetail')){
                            curResponseStatus = String.valueOf((List<Object>)bodyMap.get('ErrorDetail'));
                        }
                    }

                    outMap.put('RESPONSE_STATUS_CODE', curResponseStatusCode);
                    outMap.put('RESPONSE_STATUS', curResponseStatus);
                }
            } 

        } catch(Exception e){
            System.debug('callGenericService Exception['+e.getMessage()+']');
            System.debug('callGenericService Exception['+e.getStackTraceString()+']');
            outMap.put('EXCEPTION', e);
        } finally {
            String responseString = outMap.containsKey('RESPONSE_BODY') ? (String)outMap.get('RESPONSE_BODY') : '';

            EAILogService.ErrorBean curErrorBean = new EAILogService.ErrorBean();
            curErrorBean.errorMessage = outMap.containsKey('RESPONSE_STATUS') ? (String)outMap.get('RESPONSE_STATUS') : '';
            curErrorBean.errorCode = outMap.containsKey('RESPONSE_STATUS_CODE') ? (String)outMap.get('RESPONSE_STATUS_CODE') : '';

            if(!'200'.equalsIgnoreCase(curErrorBean.errorCode) && !'201'.equalsIgnoreCase(curErrorBean.errorCode)){
                curErrorBean.errorType = 'Integration';
            } 
            
            if(outMap.containsKey('EXCEPTION')){
                Exception curException = (Exception)outMap.get('EXCEPTION');
                curErrorBean.errorType = 'Internal';
                curErrorBean.errorMessage = curException.getMessage() + ' ' + curException.getStackTraceString();
            } 
            
            EAILogService.writeLog(correlationId, jsonRequest, responseString, EAILogService.DIRECTION_OUTBOUND, curErrorBean, interfaceId);
        }

        return outMap;
    }

    public static CalloutConfiguration__mdt retrieveConfiguration(String interfaceId){

        CalloutConfiguration__mdt outMdt = null;

        Common_Settings__mdt environmentMdt = Common_Settings__mdt.getInstance('ENVIRONMENT');
        String currentEnvironment = environmentMdt.SettingValue__c;
        if(String.isBlank(currentEnvironment)){
            currentEnvironment = 'DEV';
        }

        System.debug('retrieveConfiguration interfaceId['+interfaceId+'] currentEnvironment['+currentEnvironment+']');
        List<CalloutConfiguration__mdt> mtdList = 
            [SELECT ClientId__c, ClientSecret__c, EndPoint__c, HttpMethod__c
            FROM CalloutConfiguration__mdt 
            WHERE InterfaceId__c =:interfaceId
            AND Environment__c =:currentEnvironment];
        
        if(mtdList!=null && mtdList.size()>0){
            outMdt = mtdList.get(0);
        }
        System.debug('retrieveConfiguration outMdt['+outMdt+']');
        return outMdt;
    }

    
    public static String getCorrelationId(String objId){
        DateTime myDateTime = DateTime.now();
        Long getTimeLong = myDateTime.getTime();
        String outCorrelationId = (objId+getTimeLong).leftPad(35, '0');
        return outCorrelationId;
    }

}