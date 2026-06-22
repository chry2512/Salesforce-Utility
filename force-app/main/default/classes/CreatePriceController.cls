/**
 * @description       : Create Price Controller class
 * @author            : Christian Niro
 * @group             : Christian Niro
 * @last modified on  : 05-27-2024
 * @last modified by  :
 **/
public class CreatePriceController{
    private static QueryClass queryClassInstance = new QueryClass();
    @AuraEnabled(cacheable = true)
    public static List<sObject> getLookupValues(String searchKeyWord, String objectAPIName, String whereCondition, String fieldNames, Integer customLimit){
        return queryClassInstance.getLookupValues(searchKeyWord, objectAPIName, whereCondition, fieldNames, customLimit);
    }

    @AuraEnabled(cacheable = true)
    public static sObject getinitRecord(String recordId, String objectAPIName, String fieldNames){
        return queryClassInstance.getinitRecord(recordId, objectAPIName, fieldNames);
    }

    @AuraEnabled(cacheable = true)
    public static List<sObject> gerRecentlyCreatedRecords(String objectAPIName, String fieldNames, String whereCondition, Integer customLimit){
        return queryClassInstance.gerRecentlyCreatedRecords(objectAPIName, fieldNames, whereCondition, customLimit);
    }

}