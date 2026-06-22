/**
 * @description       : Creates log applied to API classes
 * @author            : Christian Niro
 * @group             : Christian Niro
 * @last modified on  : 05-27-2024
 * @last modified by  :
 **/
public class ExposedAPILogger{
    private static final Integer MAX_PAYLOAD_LENGTH = 131072;
    //private List<IP_ExposedAPILog__c> exposedAPILogList = new List<IP_ExposedAPILog__c>();
    private static ExposedAPILogger instance;

    //build and insert log with Request And Response informations
    private ExposedAPILogger(){
    }

    public static ExposedAPILogger getInstance(){
        if (instance == null)
            instance = new ExposedAPILogger();
        return instance;
    }

    public void log(String apiName, Datetime executionTime, String responseTitle, RestRequest request, RestResponse response){

        /*IP_ExposedAPILog__c exposedAPILog = new IP_ExposedAPILog__c();
         exposedAPILog.Name = apiName;
         exposedAPILog.IP_ExecutionTime__c = executionTime;
         exposedAPILog.IP_HTTPMethod__c = request?.httpMethod;
         exposedAPILog.IP_HTTPStatusCode__c = response?.statusCode;
         exposedAPILog.IP_RemoteAddress__c = request?.remoteAddress;
         exposedAPILog.IP_ResourcePath__c = request?.resourcePath;
         exposedAPILog.IP_RequestURI__c = request?.requestURI;
         exposedAPILog.IP_RequestHeaders__c = JSON.serialize(request?.headers).abbreviate(MAX_PAYLOAD_LENGTH);
         exposedAPILog.IP_RequestId__c = request?.headers?.get('requestid');
         //finding account external id in request
         String uniqueKey = request?.requestBody?.toString().substringAfterLast('accountExternalID":"').substringBefore('"');
         if (String.isBlank(uniqueKey)){
         //finding asset external id in request
         uniqueKey = request?.requestBody?.toString().substringAfterLast('externalID":"').substringBefore('"');
         }
         if (String.isBlank(uniqueKey)){
         //finding account external id in response
         uniqueKey = response?.responseBody?.toString().substringAfterLast('accountExternalID":"').substringBefore('"');
         }

         exposedAPILog.IP_UniqueKey__c = uniqueKey;
         exposedAPILog.IP_RequestBody__c = request?.requestBody?.toString().abbreviate(MAX_PAYLOAD_LENGTH);
         exposedAPILog.IP_ResponseTitle__c = responseTitle?.abbreviate(MAX_PAYLOAD_LENGTH);
         exposedAPILog.IP_ResponseBody__c = response?.responseBody?.toString().abbreviate(MAX_PAYLOAD_LENGTH);
         exposedAPILogList.add(exposedAPILog);*/
    }

    public void close(){
        // insert exposedAPILogList;
        //exposedAPILogList.clear();
    }

}