/**
 * @description       : 
 * @author            : Christian Niro
 * @group             : 
 * @last modified on  : 06-22-2026
 * @last modified by  : Christian Niro
**/
public class AccountService extends APIHandler.APIVirtual{

    private Integer statusCode = 500;
    private String responseBody = 'Error not Managed';
    private String integrationFlow = '';
    private String environment = '';

    private Map<String, List<String>> contactOverrideMap;
    private Map<String, List<String>> accRelationshipOverrideMap;
    
    // Internal class for the response
    public class AccountResponseWrap{
        public Integer ack;
        public String integrationFlow;
        public String systemName;
        public String title;
        public String environment;
        public Integer code;
        public String message;

        // Constructor to populate the fields
        public AccountResponseWrap(Integer ack, String integrationFlow, String systemName, String title, String environment, Integer code, String message){
            this.ack = ack;
            this.integrationFlow = integrationFlow;
            this.systemName = systemName;
            this.title = title;
            this.environment = environment;
            this.code = code;
            this.message = message;
        }
    }
    
    public AccountService() {

        implementedMethod_POST = true;
        implementedMethod_PUT = true;

        contactOverrideMap = new Map<String, List<String>>();
        accRelationshipOverrideMap = new Map<String, List<String>>();

    }

    public override Object execute_POST(){
        
        System.debug('AccountService.execute_POST requestBody[' + this.request.requestBody + ']');
        this.integrationFlow = 'SP-ACC-01';
        return execute();
    }

    public override Object execute_PUT(){
        
        System.debug('AccountService.execute_PUT requestBody[' + this.request.requestBody + ']');
        this.integrationFlow = 'SP-ACC-02';
        return execute();
    }

    public Object execute(){
        
        System.debug('AccountService.execute integrationFlow['+this.integrationFlow+'] requestBody[' + this.request.requestBody + ']');
        MappingFieldsMulesoftService mappingService = new MappingFieldsMulesoftService(this.integrationFlow);
        String systemName = 'CRM SFCD';
        try{
            Map<String, Object> requestBodyMap;

            try{
                requestBodyMap = (Map<String, Object>)JSON.deserializeUntyped(this.request.requestBody.toString());
            } catch (Exception e){
                System.debug('AccountService.execute error[' + e.getMessage() + ']');
                System.debug('AccountService.execute error[' + e.getStackTraceString() + ']');
                statusCode = 400; // Bad request
                responseBody = 'error at ' + e?.getStackTraceString() + ': ' + e?.getMessage();
                return responseBody;
            }

            Map<String, Object> objectSalesforceMap = new Map<String, Object>();
            mappingService.mapMuleFieldsInSalesObject('', requestBodyMap, objectSalesforceMap);
            system.debug('AccountService.execute objectSalesforceMap[' + objectSalesforceMap + ']');
            
            upsertData(objectSalesforceMap);
            System.debug('AccountService.execute upsertData End');

            callOverride();
            
            statusCode = 201;
            responseBody =  JSON.serializePretty(new AccountResponseWrap(1, this.integrationFlow, systemName, 'CREATE/UPDATE', environment, 201, 'SUCCESS CREATE/UPDATE ACCOUNT'));
            return responseBody;

        } catch (Exception err){
            System.debug('AccountService.execute error[' + err.getMessage() + ']');
            System.debug('AccountService.execute error[' + err.getStackTraceString() + ']');
            statusCode = 500; // Internal server error
            e = err;
            return null;
        }
    }

    // ovveride method to validate request parameters in your method
    public override Boolean validateRequest_POST(){
        return true;
    }

    // ovveride method to validate request parameters in your method
    public override Boolean validateRequest_PUT(){
        return true;
    }

    // ovveride method to set response parameters in your method
    public override Map<ResponseParameter, Object> setResponseParameters_POST(Object responseBody){
        Map<ResponseParameter, Object> responseMap = new Map<ResponseParameter, Object>();
        responseMap.put(APIHandler.ResponseParameter.STATUSCODE, statusCode);
        responseMap.put(APIHandler.ResponseParameter.RESPONSEBODY, responseBody);

        return responseMap;
    }

    // ovveride method to set response parameters in your method
    public override Map<ResponseParameter, Object> setResponseParameters_PUT(Object responseBody){
        Map<ResponseParameter, Object> responseMap = new Map<ResponseParameter, Object>();
        responseMap.put(APIHandler.ResponseParameter.STATUSCODE, statusCode);
        responseMap.put(APIHandler.ResponseParameter.RESPONSEBODY, responseBody);

        return responseMap;
    }

    private void upsertData(Map<String, Object> objectSalesforceMap){

        Account accountBySap = (Account)JSON.deserialize(JSON.serialize((Map<String, Object>)objectSalesforceMap.get('ACCOUNT')), Account.class);
        System.debug('AccountService.upsertData accountBySap[' + accountBySap + ']');

        accountBySap.Name = accountBySap.name1__c;
        if(!String.isBlank(accountBySap.name2__c)){
            accountBySap.Name = accountBySap.Name + ' ' + accountBySap.name2__c;
        }
        if(!String.isBlank(accountBySap.name3__c)){
            accountBySap.Name = accountBySap.Name + ' ' + accountBySap.name3__c;
        }
        
        if(String.isBlank(accountBySap.User_Type__c)){
            List<Account> accountRelatedList = [SELECT Id, Account_Number__c, User_Type__c FROM Account WHERE Account_Number__c = :accountBySap.Account_Number__c];
            if(accountRelatedList!=null && accountRelatedList.size()>0){
                accountBySap.User_Type__c = accountRelatedList[0].User_Type__c;
            }
        }

        accountBySap.Account_Status__c = 'Active';
        upsert accountBySap Account_Number__c;

        contactOverrideMap.put(accountBySap.Account_Number__c, new list<String>());
        accRelationshipOverrideMap.put(accountBySap.Account_Number__c, new list<String>());

        if (objectSalesforceMap.containsKey('CONTACT')){
            List<Contact> contactsBySap = (List<Contact>)JSON.deserialize(JSON.serialize(objectSalesforceMap.get('CONTACT')), List<Contact>.class);
            Id ContactEmailRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('RT_Contact_Email').getRecordTypeId();

            if(contactsBySap!=null && contactsBySap.size()>0){
                for(Contact curContact : contactsBySap){
                    curContact.recordTypeId = ContactEmailRecordTypeId;
                    curContact.AccountId = accountBySap.Id;
                    buildOverrideMap(accountBySap.Account_Number__c, curContact);
                }
            }
            
            upsert contactsBySap ExternId__c;
        }

        if (objectSalesforceMap.containsKey('ACCOUNT_RELATIONS')){
            List<Account_Relationship__c> accountRelationshipsBySap = (List<Account_Relationship__c>)JSON.deserialize(JSON.serialize(objectSalesforceMap.get('ACCOUNT_RELATIONS')), List<Account_Relationship__c>.class);
            Map<String, List<Account_Relationship__c>> accountRelatedMap = new Map<String, List<Account_Relationship__c>>();

            if(accountRelationshipsBySap!=null && accountRelationshipsBySap.size()>0){
                for(Account_Relationship__c curAccountRelationship : accountRelationshipsBySap){
                    curAccountRelationship.Parent_Account__c = accountBySap.Id;
                    curAccountRelationship.ExternId__c = accountBySap.Account_number__c 
                        + '|' + curAccountRelationship.AccountRelatedRelationNumber__c
                        + '|' + curAccountRelationship.AccountMasterRelation__c
                        + '|' + curAccountRelationship.AccountRelatedRelation__c
                        ;

                    if(!accountRelatedMap.containsKey(curAccountRelationship.AccountRelatedRelationNumber__c)){
                        accountRelatedMap.put(curAccountRelationship.AccountRelatedRelationNumber__c, new List<Account_Relationship__c>());
                    }
                    accountRelatedMap.get(curAccountRelationship.AccountRelatedRelationNumber__c).add(curAccountRelationship);

                    //mappa contatti per override
                    buildOverrideMap(accountBySap.Account_Number__c, curAccountRelationship);
                }
            }

            if(accountRelatedMap.keySet()!=null && accountRelatedMap.keySet().size()>0){
                List<Account> accountRelatedList = [SELECT Id, Account_Number__c FROM Account WHERE Account_Number__c IN :accountRelatedMap.keySet()];
                if(accountRelatedList!=null && accountRelatedList.size()>0){
                    for(Account curAccount : accountRelatedList){
                        List<Account_Relationship__c> curAccountRelationshipList = accountRelatedMap.get(curAccount.Account_Number__c);
                        for(Account_Relationship__c curAccountRelationship : curAccountRelationshipList){
                            curAccountRelationship.Child_Account__c = curAccount.Id;
                        }
                    }
                }
            }
            
            upsert accountRelationshipsBySap ExternId__c;
        }
    }

    private Map<String, List<String>> buildOverrideMap(String parentExternId, Sobject objectToAdd){

        Map<String, List<String>> outMap;
        String curValue;
        
        if(objectToAdd instanceOf Contact){
            curValue = ((Contact)objectToAdd).ExternId__c;
            outMap = contactOverrideMap;
        } else if (objectToAdd instanceOf Account_Relationship__c){
            curValue = ((Account_Relationship__c)objectToAdd).ExternId__c;
            outMap = accRelationshipOverrideMap;
        }

        if(!outMap.containsKey(parentExternId)){
            outMap.put(parentExternId, new List<String>());
        }
        outMap.get(parentExternId).add(curValue);

        return outMap;
    }

    private void callOverride(){
        if('SP-ACC-01'.equals(this.integrationFlow)){
            System.enqueueJob(new OverrideObjectQueue(contactOverrideMap, 'Contact'));
        }
        System.enqueueJob(new OverrideObjectQueue(accRelationshipOverrideMap, 'Account_Relationship__c'));
    }

}