/**
 * @description       : Method that implements dynamic solutions 
 * @author            : Christian Niro
 * @group             :
 * @last modified on  : 05-15-2024
 * @last modified by  : 
 **/
public class UtilsClassDynamic extends Utils{
    // override method to get the record type ID map
    public override Map<String, Object> getSObjectValue(String sObjectName, Boolean forUpdate){
        //Initialize Map
        Map<String, Id> recordTypeMap = new Map<String, Id>();

        //Getting Object Result
        Schema.DescribeSObjectResult objectResult = Schema.getGlobalDescribe().get(sObjectName)?.getDescribe();

        if (objectResult != null){
            //Getting record info
            List<Schema.RecordTypeInfo> recordTypeInfos = objectResult.getRecordTypeInfos();


            for (Schema.RecordTypeInfo recordTypeInfo : recordTypeInfos){

                // If the current record type is active and available to the logged in user, adding it's name and id to the map
                if (recordTypeInfo.isActive() && recordTypeInfo.isAvailable()){
                    recordTypeMap.put(recordTypeInfo.getName(), recordTypeInfo.getRecordTypeId());
                }
            }
        }
        return recordTypeMap;
    }
}