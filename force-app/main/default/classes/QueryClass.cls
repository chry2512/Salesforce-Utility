/**
 * @description       : This class is used to query records from the database
 * @author            : Christian Niro
 * @group             :
 * @last modified on  : 05-27-2024
 * @last modified by  :
 **/
public virtual class QueryClass implements QueryOperable{
    public static final String USER_MODE = 'user_mode'; // Constant User Access Level
    public static final String SYSTEM_MODE = 'system_mode';// Constant System Access Level
    public class QueryClassException extends Exception{
    }

    // Exception Class
    /* DEFAULT METHOD TO INVOKE QUERY*/
    /*THIS IS  HELPER METHOD TO BE EASY CALL DEFAULT METHOD*/
    //use this method  invoke default method for query
    public static List<SObject> queryHelperMethod(Map<String, Object> binds, String objectName, String condition, String accessLevel, Boolean forUpdate){
        String query = getSimpleSOQL(objectName, condition, forUpdate);
        System.debug('<<< query: ' + query);
        List<SObject> result = queryWithBindsVariable(binds, query, accessLevel);
        System.debug('<<< result: ' + result);
        return result;
    }

    //This Method return a simple Query in String Format
    public static String getSimpleSOQL(String objectName, String condition, Boolean forUpdate){

        Utils get = new Utils();

        // Getting the field names using the object name
        Set<String> fieldNames = get.getSObjectValue(objectName, forUpdate).keySet();

        //  Forming the SOQL query
        String query = 'SELECT ';
        for (String fieldName : fieldNames){
            query += fieldName + ', ';
        }

        //  Removing last , from the SOQL query string
        query = query.substring(0, query.lastIndexof(','));

        // Adding the object name to the SOQL
        query += ' FROM ' + objectName;

        if (String.isNotBlank(condition)){
            query += ' WHERE ' + condition;
        }

        // Returning the SOQL
        return query;
    }

    // USE THIS METHOD FOR PREVENT SOQL INJECTION return List<Sobject>
    public static List<SObject> queryWithBindsVariable(Map<String, Object> binds, String query, String access){

        Map<String, Object> newBinds = binds;
        List<SObject> returnedValue = null;

        switch  on access{
            when 'user_mode'{
                returnedValue = Database.queryWithBinds(query, newBinds, AccessLevel.USER_MODE);
            }
            when 'system_mode'{
                returnedValue = Database.queryWithBinds(query, newBinds, AccessLevel.SYSTEM_MODE);
            }
            when else{
                returnedValue = Database.queryWithBinds(query, newBinds, AccessLevel.USER_MODE);
            }
        }

        if (returnedValue == null){

            throw new QueryClassException(Label.QueryClassExceptionBindsMethod);
        }

        return returnedValue;
    }

    // USE THIS METHOD FOR PREVENT SOQL INJECTION IN QUERY LOCATOR FOR BATCH --> returns List<Sobjects> more 50000 records
    public static Database.QueryLocator queryLocatorWithBindsVariable(Map<String, Object> binds, String query, String access){

        Map<String, Object> newBinds = binds;
        Database.QueryLocator returnedValue = null;
        switch  on access{
            when 'user_mode'{
                returnedValue = Database.getQueryLocatorWithBinds(query, newBinds, AccessLevel.USER_MODE);
            }
            when 'system_mode'{
                returnedValue = Database.getQueryLocatorWithBinds(query, newBinds, AccessLevel.SYSTEM_MODE);
            }
            when else{
                returnedValue = Database.getQueryLocatorWithBinds(query, newBinds, AccessLevel.USER_MODE);
            }
        }

        if (returnedValue == null){

            throw new QueryClassException(Label.QueryClassExceptionBindsMethod);
        }

        return returnedValue;
    }

    // This is New  simple version, faster then deprecated version
    // use this methd to query records on Sobject and update more fields , return --> list<Sobject>
    public static List<SObject> getObjInstance(List<SObject> recordToUpdate, Map<String, Map<String, Object>> fieldUpdate){
        List<SObject> returnedValue = recordToUpdate;
        Map<String, SObject> updateRecord = new Map<String, SObject>();

        if (returnedValue == null){
            throw new QueryClassException(Label.QueryClassExceptionOverrideMethods);
        }

        for (SObject o : returnedValue){

            Schema.SObjectType sObjectType = o.getSObjectType();
            Map<String, Schema.SObjectField> fieldsdMap = sObjectType.getDescribe().fields.getMap();
            Boolean isToUpdate = false;

            Map<String, Object> fieldsUpdateObject = fieldUpdate.get((String) o.get('Id'));

            for (String fieldName : fieldsUpdateObject.keySet()){

                Schema.DescribeFieldResult fieldtoCheck = fieldsdMap.get(fieldName).getDescribe();

                if (!Utils.checkFieldOk(fieldToCheck)){

                    fieldsUpdateObject.remove(fieldName);
                    continue;
                }

                if (fieldsUpdateObject.containsKey(fieldName)){
                    isToUpdate = true;
                    o.put(fieldName, fieldsUpdateObject.get(fieldName));
                }
            }

            if (isToUpdate == true){
                updateRecord.put(o.Id, o);
            }
        }

        return updateRecord.values();
    }

    public virtual List<SObject> getLookupValues(String searchKeyWord, String objectAPIName, String whereCondition, String fieldNames, Integer customLimit){
        String searchKey = '%' + searchKeyWord + '%';
        List<sObject> returnList = new List<sObject>();


        String sQuery = 'SELECT Id, Name';

        if (String.isNotBlank(fieldNames) && !fieldNames.equalsIgnoreCase('Name')){
            sQuery += ',' + fieldNames;
        }


        if (String.isNotBlank(whereCondition) && whereCondition != null){
            sQuery += ' FROM ' + objectAPIName + ' WHERE ' + fieldNames + ' LIKE \'' + searchKey + '\' AND ' + whereCondition + ' ORDER BY CreatedDate DESC limit ' + String.valueOf(customLimit);
        } else{
            sQuery += ' FROM ' + objectAPIName + ' WHERE ' + fieldNames + ' LIKE \'' + searchKey + '\' ORDER BY CreatedDate DESC limit ' + String.valueOf(customLimit);
        }

        system.debug(sQuery);
        List<sObject> lstOfRecords = Database.query(sQuery);
        for (sObject obj : lstOfRecords){
            returnList.add(obj);
        }

        System.debug(lstOfRecords);

        return returnList;
    }

    public virtual SObject getinitRecord(String recordId, String objectAPIName, String fieldNames){
        String sRecId = recordId;

        String sQuery = 'SELECT id, Name';

        if (String.isNotBlank(fieldNames)){

            sQuery += ',' + fieldNames;
        }


        sQuery += ' FROM ' + objectAPIName + ' WHERE Id = : sRecId LIMIT 1 ';


        for (sObject obj : Database.query(sQuery)){

            return obj;
        }

        return null;
    }

    public virtual List<SObject> gerRecentlyCreatedRecords(String objectAPIName, String fieldNames, String whereCondition, Integer customLimit){
        List<sObject> returnList = new List<sObject>();

        String sQuery = 'SELECT Id, Name';

        if (String.isNotBlank(fieldNames) && !fieldNames.equalsIgnoreCase('Name')){

            sQuery += ',' + fieldNames;
        }

        if (String.isNotBlank(whereCondition) && whereCondition != null){

            sQuery += ' FROM ' + objectAPIName + ' WHERE ' + whereCondition + ' ORDER BY CreatedDate DESC limit ' + String.valueOf(customLimit);

        } else{

            sQuery += ' FROM ' + objectAPIName + ' ORDER BY CreatedDate DESC limit ' + String.valueOf(customLimit);
        }


        System.debug(sQuery);

        List<sObject> lstOfRecords = Database.query(sQuery);

        for (sObject obj : lstOfRecords)
            returnList.add(obj);
        return returnList;
    }

}