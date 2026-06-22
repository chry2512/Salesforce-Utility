/**
 * @description       : Methods for generic purposes
 * @author            : Christian Niro
 * @group             :
 * @last modified on  : 05-15-2024
 * @last modified by  : 
 **/
global virtual class Utils{
    private static Boolean isProd = null;
    public class UtilsException extends Exception{}// Exception Class

    //Custom EXCEPTION for Utils Class
    /**
     * @description: Method to check permissiohn of field for update
     * @param Schema.DescribeFieldResult
     * @return Boolean
     */
    public static Boolean checkFieldOk(Schema.DescribeFieldResult fieldResult){

        if(fieldResult.getSObjectType().equals(Schema.Account.getSObjectType()) && fieldResult.isNameField()){
        	return false;
    	}

        
      
        return !fieldResult.isEncrypted()
               && !fieldResult.isExternalId() 
               &&  !fieldResult.isAutoNumber() 
               && !fieldResult.isCalculated() 
               && fieldResult.isUpdateable();
    }

    /**
     * @description: Method to check query limits
     * @param NULL
     * @return Integer
     */
    public static Integer limitQuery(){
        return Limits.getLimitQueryRows() - Limits.getQueryRows();
    }

    /**
     * @description: Method to check Heap Size Limit
     * @param NULL
     * @return Integer
     */
    public static Integer limitHeap(){
        return Limits.getLimitHeapSize() - Limits.getHeapSize();
    }

    /**
     * @description: Checks if environement is Production ORG (true) or Sandbox (false)
     * @param NULL
     * @return Boolean
     */
    public static Boolean isProductionOrg(){

        if (isProd == null){
            isProd = ![SELECT IsSandbox
                       FROM Organization
                       LIMIT 1].IsSandbox;
        }

        return isProd;
    }

    /**
     * @description:  Get Object API Name to Label Map
     * @param NULL
     * @return Map<String, String>
     */
    public virtual Map<String, String> getObjectAPINameToLabel(){
        //initialize Map
        Map<String, String> objectApiNameToLabel = new Map<String, String>();

        // getting all Sobject Metadata
        Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe();
        // Processing each sObject one by one
        for (String globalDescribeKey : globalDescribeMap.keySet()){
            // Getting the current sObject type
            Schema.SObjectType currentSObjectType = globalDescribeMap.get(globalDescribeKey);
            // Getting the current sObject description result from sObject Type
            Schema.DescribeSObjectResult currentSObjectResult = currentSObjectType.getDescribe();
            //  Getting the current sObject description result from sObject Type
            objectApiNameToLabel.put(currentSObjectResult.getName(), currentSObjectResult.getLabel());
        }

        // return Map
        return objectApiNameToLabel;
    }

    /**
     * @description:  Method to get all fields of an SObject
     * @param String
     * @return Map<String, Object>
     */
    public virtual Map<String, Object> getSObjectValue(String sObjectName, Boolean forUpdate){

        // initialize fields name set
        Map<String, Schema.SObjectField> fieldsName = new Map<String, Schema.SObjectField>();
        //Getting Metadata of all Sobject
        Map<String, Schema.SObjectType> sObjectMap = Schema.getGlobalDescribe();


        // type instance for current SObject
        Schema.SObjectType sObjectTypeInstance = sObjectMap.get(sObjectName);
        if (sObjectTypeInstance != null){
            // getting fields for current Sobject
            Map<String, Schema.SObjectField> fieldMap = sObjectTypeInstance.getDescribe().fields.getMap();

            // Checking each field one by one, if it's accessible, adding it's name to fieldNames set
            for (Schema.SObjectField field : fieldMap.values()){
                Schema.DescribeFieldResult fieldResult = field.getDescribe();

                if (forUpdate == true){

                    if (checkFieldOk(fieldResult)){

                        fieldsName.put(fieldResult.getName(), field);
                    }
                } else{
                    if (fieldResult.isAccessible()){
                        fieldsName.put(fieldResult.getName(), field);
                    }
                }
            }
        }

        return fieldsName;
    }

    /**
     * @description:  Method to get all Picklist Values
     * @param String
     * @return Map<String, String>
     */
    public virtual Map<String, String> getPicklistValuesMap(String objectAPIName, String fieldAPIName){

        // Inizialize PickList Map
        Map<String, String> picklistValuesMap = new Map<String, String>();
        // Getting current Field Result
        Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get(objectAPIName)?.getDescribe()?.fields?.getMap()?.get(fieldAPIName)?.getDescribe();
        //check if the field type is a PickList
        if ((fieldResult != null) && fieldResult.getType() == Schema.DisplayType.Picklist){
            //Getting all picklist entries
            List<Schema.PicklistEntry> pickListentries = fieldResult.getPicklistValues();

            for (Schema.PicklistEntry pickListentry : pickListentries){
                //check if the picklist is Active
                if (pickListentry.isActive()){
                    String picklistLabel = pickListentry.getLabel();
                    String picklistValue = pickListentry.getValue();
                    picklistValuesMap.put(picklistValue, picklistLabel);

                }
            }
        } else{

            throw new UtilsException(Label.UtilsExceptionPicklistValues); // custom label

        }
        return picklistValuesMap;
    }

    /**
     * @description: Metodo che riceve un array di String e restituisce una String unica con i valori dell'array concatenati da \n per visualizzazione su TextArea
     * @param String[]
     * @return String
     */
    public static String fromStringArrayToString(List<String> arrayStrings){

        String result = '';
        
        for (String str : arrayStrings){
            result += str + ';' ;
        }
        
        return result.removeEnd(';');
    }

    /**
     * @description: Metodo che converte una String in Datetime
     * @param String-Boolean
     * @return DateTime
     */
    public static DateTime convertStringToDateTime(String dateString, Boolean isFinish){

        DateTime dateConverted;

        dateString = dateString.replace('/', '-');
        List<String> splittedDate = dateString.split('-');
        String day = splittedDate.get(0);
        String month = splittedDate.get(1);
        String year = splittedDate.get(2);
        if (year.length() != 4){
            year = '20' + year;
        }

        if (!isFinish){
            dateConverted = Datetime.newInstance(Integer.valueOf(year), Integer.valueOf(month), Integer.valueOf(day), 0, 0, 0);
        } else{
            dateConverted = Datetime.newInstance(Integer.valueOf(year), Integer.valueOf(month), Integer.valueOf(day), 23, 59, 59);
        }

        return dateConverted;
    }
}