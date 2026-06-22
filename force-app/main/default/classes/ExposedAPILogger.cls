/**
 * @description       : Creates log applied to API classes
 * @author            : Christian Niro
 * @group             : Christian Niro
 * @last modified on  : 06-22-2026
 * @last modified by  : Christian Niro
 **/
public class ExposedAPILogger{
    private static final Integer MAX_PAYLOAD_LENGTH = 131072;
    private List<ExposedAPILog__c> exposedAPILogList = new List<ExposedAPILog__c>();
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

            ExposedAPILog__c exposedAPILog = new xposedAPILog__c();
            exposedAPILog.Name = apiName;
            exposedAPILog.ExecutionTime__c = executionTime;
            exposedAPI.LogHTTPMethod__c = request?.httpMethod;
            exposedAPI.LogHTTPStatusCode__c = response?.statusCode;
            exposedAPI.LogRemoteAddress__c = request?.remoteAddress;
            exposedAPI.LogResourcePath__c = request?.resourcePath;
            exposedAPI.LogRequestURI__c = request?.requestURI;
            exposedAPI.LogRequestHeaders__c = JSON.serialize(request?.headers).abbreviate(MAX_PAYLOAD_LENGTH);
            exposedAPI.LogRequestId__c = request?.headers?.get('requestid');
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

            exposedAPILog.UniqueKey__c = uniqueKey;
            exposedAPILog.RequestBody__c = request?.requestBody?.toString().abbreviate(MAX_PAYLOAD_LENGTH);
            exposedAPILog.ResponseTitle__c = responseTitle?.abbreviate(MAX_PAYLOAD_LENGTH);
            exposedAPILog.ResponseBody__c = response?.responseBody?.toString().abbreviate(MAX_PAYLOAD_LENGTH);
            exposedAPILog.List.add(exposedAPILog);
    }

    public void close(){
        insert exposedAPILogList;
        exposedAPILogList.clear();
    }

}