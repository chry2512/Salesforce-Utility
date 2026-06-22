/**
 * @description       : 
 * @author            : Christian Niro
 * @group             : 
 * @last modified on  : 06-22-2026
 * @last modified by  : Christian Niro
**/

public class MappingFieldsMulesoftService {

    private Map<String, MappingFieldsMulesoft__mdt> mappingMdtMap = new Map<String, MappingFieldsMulesoft__mdt>();
    //private Map<String, List<CustomMapping__mdt>> customMappingMap = new Map<String, List<CustomMapping__mdt>>();

    public MappingFieldsMulesoftService(String integrationFlow) {
        List<MappingFieldsMulesoft__mdt> mappingMdtList = [SELECT DataTypeSalesforce__c, FieldNameMulesoft__c, FieldNameSalesforce__c, ObjectSalesforce__c, CustomMapping__c
            FROM MappingFieldsMulesoft__mdt
            WHERE IsActive__c = true AND IntegrationFlow__c =:integrationFlow];
    
        for (MappingFieldsMulesoft__mdt curMappingMdt : mappingMdtList){
            mappingMdtMap.put(curMappingMdt.FieldNameMulesoft__c.toUpperCase(), curMappingMdt);
            //todo
            //if(!String.isBlank(curMappingMdt.CustomMapping__c)){
            //CustomMappingMap.put(curMappingMdt.CustomMapping__c, new list<CustomMapping__mdt>());
            //}
        }
    }

    public void mapMuleFieldsInSalesObject(String fullPath, Map<String, Object> jsonDeserializedMap, Map<String, Object> objectSalesforceMap){

        if (jsonDeserializedMap != null){
            for (String curKey : jsonDeserializedMap.keySet()){
               
                String curFieldNameMulesoft = String.isBlank(fullPath) ? curKey.toUpperCase() : fullPath + '.' + curKey.toUpperCase();
                System.debug('MappingFieldsMulesoftService.mapMuleFieldsInSalesObject curFieldNameMulesoft['+curFieldNameMulesoft+']');
                if (jsonDeserializedMap.get(curKey) instanceOf Map<String, Object>){
                    mapMuleFieldsInSalesObject(curFieldNameMulesoft, (Map<String, Object>)jsonDeserializedMap.get(curKey), objectSalesforceMap);
                }
                if (jsonDeserializedMap.get(curKey) instanceOf List<Object>){
                    mapMuleFieldsInSalesObject(curFieldNameMulesoft, (List<Object>)jsonDeserializedMap.get(curKey), objectSalesforceMap);
                } else{
                    if (mappingMdtMap.containsKey(curFieldNameMulesoft)){
                        MappingFieldsMulesoft__mdt curMappingMdt = mappingMdtMap.get(curFieldNameMulesoft);
                        
                        if (!objectSalesforceMap.containsKey(curMappingMdt.ObjectSalesforce__c)){
                            objectSalesforceMap.put(curMappingMdt.ObjectSalesforce__c, new Map<String, Object>());
                        }
                		Map<String, Object> curObjectFieldsMap = (Map<String, Object>)objectSalesforceMap.get(curMappingMdt.ObjectSalesforce__c);

                        Object curValue = jsonDeserializedMap.get(curKey);
                        if ('Checkbox'.equalsIgnoreCase(curMappingMdt.DataTypeSalesforce__c) && !(curValue instanceOf Boolean)){
                            curValue = 'X'.equalsIgnoreCase((String) curValue);
                        } else if (!String.isBlank(curMappingMdt.CustomMapping__c)){
                            curValue = getValueCustomMapping(curMappingMdt.CustomMapping__c, (String) curValue);
                        } else if (curValue == null){
                            curValue = '';
                        }
                        curObjectFieldsMap.put(curMappingMdt.FieldNameSalesforce__c, curValue);//todo add gestione tipologia dato
                    }
                }
            }
        }
    }

    @TestVisible
    private void mapMuleFieldsInSalesObject(String fullPath, List<Object> jsonDeserializedList, Map<String, Object> objectSalesforceMap){
        if (jsonDeserializedList != null){

            for (Object curElement : jsonDeserializedList){
                if (curElement instanceOf Map<String, Object>){

                    List<String> innerObjectKey = new List<String>();

                    //Map<String, Map<String, Object>> curSalesforceMap = new Map<String, Map<String, Object>>();
                    Map<String, Object> curSalesforceMap = new Map<String, Object>();

                    mapMuleFieldsInSalesObject(fullPath, (Map<String, Object>)curElement, curSalesforceMap);

                    //merge curSalesforceMap in objectSalesforceMap
                    for (String curKey : curSalesforceMap.keySet()){
                        if(curKey.contains('.')){
                            innerObjectKey.add(curKey);
                        }
                        if (!objectSalesforceMap.containsKey(curKey)){
                            objectSalesforceMap.put(curKey, new List<Object>());
                        }

                        List<Object> curList = (List<Object>)objectSalesforceMap.get(curKey);
                        curList.add(curSalesforceMap.get(curKey));
                    }

                    for (String curKey : innerObjectKey){
                        if(curKey.contains('.') && curSalesforceMap.containsKey(curKey)){
                            list<String> objectNameSplit = curKey.split('\\.');
                            String parentObjectName = objectNameSplit.get(0);
                            String childObjectName = objectNameSplit.get(1);

                            if (objectSalesforceMap.containsKey(parentObjectName)){
                                Map<String, Object> parentObject = (Map<String, Object>) objectSalesforceMap.get(parentObjectName);
                                if(parentObject.containsKey(childObjectName) && parentObject.get(childObjectName) instanceof List<Object>){
                                    List<Object> curChildObjectList = (List<Object>)parentObject.get(childObjectName);
                                    curChildObjectList.add(curSalesforceMap.get(curKey));
                                } else {
                                    parentObject.put(childObjectName, objectSalesforceMap.get(curKey));
                                }
                                //parentObject.put(childObjectName, objectSalesforceMap.get(curKey));
                            }
                            
                            objectSalesforceMap.remove(curKey);
                        }
                    }
                }
            }
        }
    }

    private String getValueCustomMapping(String customMappingName, String curValueMulesoft){
        String outValue;

        if(String.isBlank(curValueMulesoft)){
            return '';
        }

        switch on curValueMulesoft{
            when 'DI' {	outValue = 'Distributor';}
            when 'RI' {	outValue = 'Wholesaler';}
            when 'PR' {	outValue = 'Private User';}
            when 'W1' {	outValue = 'Workshop';}
            when 'W2' {	outValue = 'Bodyshop';}
            when 'OT' {	outValue = 'Other';}
            when 'FL' {	outValue = 'Fleet';}
            when 'C1' {	outValue = 'Consortium';}
            when 'G2' {	outValue = 'Commercial Group';}
            when 'SP' {	outValue = 'Professional School';}
            when 'SA' {	outValue = 'Satellite';}
            when 'YY' {	outValue = 'Standard B2B/B2C';}
            when 'EX' {	outValue = 'Export';}
            when 'W4' {	outValue = 'Generic Workshop';}
            when 'CO' {	outValue = 'Constructor';}
            when 'TO' {	outValue = 'Online Training';}
            when 'EC' {	outValue = 'Ecommerce';}
            when 'B2' {	outValue = 'Standard B2B/B2C';}
            when else { outValue = curValueMulesoft; }
        }
        return outValue;

    }


}