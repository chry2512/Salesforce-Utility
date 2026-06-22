/**
 * @description       : Interface con anem of methods for query operations
 * @author            : Christian Niro
 * @group             :
 * @last modified on  : 05-27-2024
 * @last modified by  :
 **/
public interface QueryOperable{
    List<SObject> queryWithBindsVariable(Map<String, Object> binds, String query, String accessLevel);// this is method for prevent SQL injection in simple query
    Database.QueryLocator queryLocatorWithBindsVariable(Map<String, Object> binds, String query, String access);// this is method for prevent SQL injection in query locator
    List<SObject> getObjInstance(List<SObject> recordToUpdate, Map<String, Map<String, Object>> fieldUpdate); // dynamic query and update fields
    List<SObject> getLookupValues(String searchKeyWord, String objectAPIName, String whereCondition, String fieldNames, Integer customLimit); // dynamic query for lookup component
    SObject getinitRecord(String recordId, String objectAPIName, String fieldNames); // dynamic query for init record
    List<SObject> gerRecentlyCreatedRecords(String objectAPIName, String fieldNames, String whereCondition, Integer customLimit); // dynamic query for recently created records
}