/**
 * @description       : Controller Service Process
 * @author            : Christian Niro
 * @group             : Christian  Niro
 * @last modified on  : 05-22-2024
 * @last modified by  : 
 **/
public with sharing class ServiceProcessController{
    public static final String TEMPLATE = 'SendCsv';
    public static final String HEADERS = 'Id,Description,ProductSku,ProductCode,Class,Type,RecordStatus,isActive,isOrderable';
    @AuraEnabled
    public static void sendMail(){
        String body = '';
        String objectName = 'StagingTable__c';
        String condition = 'RecordStatus__c = :bind  LIMIT 50000';
        Map<String, Object> binds = new Map<String, Object>{ 'bind' => 'New' };

        List<StagingTable__c> recordList = QueryClass.queryHelperMethod(binds, objectName, condition, QueryClass.SYSTEM_MODE, false);

        for (StagingTable__c record : recordList){

            body += '' + record.Id + ',' + record.Description__c + ',' + record.ProductSku__c + ',' + record.ProductCode__c + ',' + record.Class__c + ',' + record.Type__c + ',' + record.RecordStatus__c + ',' + record.isActive__c + ',' + record.isOrderable__c + '\n';
        }

        String finalFile = HEADERS + '\n' + body;
        Blob fileBody = Blob.valueOf(finalFile);

        Id customTemplate = [SELECT Id, DeveloperName
                             FROM EmailTemplate
                             WHERE DeveloperName = :TEMPLATE].Id;

        UtilsClassEmail.sendMailCustomTemplate(customTemplate, fileBody, 'newStagingAreaRecords.csv', 'ServiceProcess', 'christianniro18@gmail.com', null);
    }

    @AuraEnabled
    public static List<StagingTable__c> getRecords(){


        String objectName = 'StagingTable__c';
        String condition = 'RecordStatus__c = :bind  LIMIT 50000';
        Map<String, Object> binds = new Map<String, Object>{ 'bind' => 'New' };

        List<StagingTable__c> recordList = QueryClass.queryHelperMethod(binds, objectName, condition, QueryClass.SYSTEM_MODE, false);

        System.debug('<<<record retrurn size' + recordList.size());


        if (recordList.isEmpty() || recordList == null){

            throw new QueryException('No records found in the database.');
        }


        return recordList;
    }

    @AuraEnabled
    public static String getContentFile(String documentId, Boolean thirdStep){
        // Recupera il ContentVersion dal documento ID
        Blob file = null;
        try{
            file = [SELECT VersionData
                    FROM ContentVersion
                    WHERE ContentDocumentId = :documentId AND IsLatest = true
                    LIMIT 1].VersionData;

            if (!Test.isRunningTest()){
                throw new ServiceCreationException('il File è vuoto');

            }


            return file.toString();
        } catch (Exception e){

            if (AMP_UtilsClass.limitHeap() == 0 || e.getMessage() == 'String length exceeds maximum: 6000000'){
                if (file != null){
                    AMP_UtilsClass.uploadFileAsync(file, thirdStep);
                } else{
                    throw new ServiceCreationException('il File è vuoto');
                }
            }
            throw new ServiceCreationException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Integer getContentSize(String documentId){
        return [SELECT ContentSize
                FROM ContentVersion
                WHERE ContentDocumentId = :documentId AND IsLatest = true
                LIMIT 1].ContentSize;
    }

    @AuraEnabled
    public static String uploadFile(Blob csv, Boolean thirdStep){
        String result = '';

        try{

            System.debug('Boolean' + thirdStep);

            AMP_UtilsClass.manageUploadFile(csv.toString(), thirdStep);
            result = 'Il caricamento del file si è completato con successo';
        } catch (Exception e){


            throw new InvalidStateCsvParseClassException(e.getMessage());
        }
        return result;
    }

}