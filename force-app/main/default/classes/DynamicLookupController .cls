/**
 * @description       : Controller for dynamic lookup component
 * @author            : Christian Niro
 * @group             : 
 * @last modified on  : 06-22-2026
 * @last modified by  : Christian Niro
**/
public with sharing class DynamicLookupController {

    public class ResultWrapper {
        @AuraEnabled public String mainField { get; set; }
        @AuraEnabled public String subField { get; set; }
        @AuraEnabled public String id { get; set; }
    }

    public class SearchWrapper {
        @AuraEnabled public String objectApiName { get; set; }
        @AuraEnabled public String fieldApiName { get; set; }
        @AuraEnabled public String otherFieldApiName { get; set; }
        @AuraEnabled public String searchString { get; set; }
        @AuraEnabled public String whereString { get; set; }
        @AuraEnabled public String whereField { get; set; }
        @AuraEnabled public String selectedRecordId { get; set; }
        @AuraEnabled public String parentRecordId { get; set; }
        @AuraEnabled public String parentFieldApiName { get; set; }
    }

    @AuraEnabled
    public static List<ResultWrapper> fetchRecords(SearchWrapper inputWrapper) {
        try {
            if (inputWrapper == null) {
                return null;
            }
            
            String query = buildQuery(inputWrapper);
 
            List<SObject> records = Database.query(query);
            return mapResults(records, inputWrapper);

        } catch (Exception err) {
            throw new AuraHandledException(err.getMessage());
        }
    }

    private static String buildQuery(SearchWrapper inputWrapper) {
        String fieldsToQuery = buildFieldsToQuery(inputWrapper);
        String baseQuery = 'SELECT ' + fieldsToQuery + ' FROM ' + String.escapeSingleQuotes(inputWrapper.objectApiName);
        String filterCriteria = buildFilterCriteria(inputWrapper);
    
        System.debug('Check: ' + inputWrapper.parentRecordId);
    
        if (String.isNotBlank(inputWrapper.selectedRecordId)) {
            baseQuery += ' WHERE Id = \'' + String.escapeSingleQuotes(inputWrapper.selectedRecordId) + '\'';
        } else if (String.isNotBlank(inputWrapper.parentFieldApiName) && String.isNotBlank(inputWrapper.parentRecordId)) {
            baseQuery += ' WHERE ' + String.escapeSingleQuotes(inputWrapper.parentFieldApiName) + ' = \'' + String.escapeSingleQuotes(inputWrapper.parentRecordId) + '\'';
            if (String.isNotBlank(filterCriteria)) {
                baseQuery += ' AND ' + filterCriteria;
            }
            if(String.isNotBlank(inputWrapper.whereString) && String.isNotBlank(inputWrapper.whereField)){
                baseQuery += ' AND ' + inputWrapper.whereField + ' = \'' + String.escapeSingleQuotes(inputWrapper.whereString) + '\'';
            }
        } else if (String.isNotBlank(filterCriteria)) {
            baseQuery += ' WHERE ' + filterCriteria;
            if(String.isNotBlank(inputWrapper.whereString) && String.isNotBlank(inputWrapper.whereField)){
                baseQuery += ' AND ' + inputWrapper.whereField + ' = \'' + String.escapeSingleQuotes(inputWrapper.whereString) + '\'';
            }
        }else if (String.isNotBlank(inputWrapper.whereString) && String.isNotBlank(inputWrapper.whereField)) {  
            baseQuery += ' WHERE ' + inputWrapper.whereField + ' = \'' + String.escapeSingleQuotes(inputWrapper.whereString) + '\'';   
        }
    
        System.debug('baseQuery: ' + baseQuery);
        return baseQuery;
    }

    private static String buildFieldsToQuery(SearchWrapper inputWrapper) {
        List<String> fields = new List<String>{'Id'};
        if (String.isNotBlank(inputWrapper.fieldApiName)) {
            fields.add(inputWrapper.fieldApiName);
        }
        if (String.isNotBlank(inputWrapper.otherFieldApiName)) {
            fields.add(inputWrapper.otherFieldApiName);
        }
        return String.join(fields, ', ');
    }


    private static String buildFilterCriteria(SearchWrapper inputWrapper) {
        if (String.isNotBlank(inputWrapper.searchString) && String.isNotBlank(inputWrapper.fieldApiName)) {
            return inputWrapper.fieldApiName + ' LIKE \'%' + String.escapeSingleQuotes(inputWrapper.searchString.trim()) + '%\'';
        }
        return null;
    }

    private static List<ResultWrapper> mapResults(List<SObject> records, SearchWrapper inputWrapper) {
        List<ResultWrapper> returnWrapperList = new List<ResultWrapper>();
        for (SObject s : records) {
            ResultWrapper wrap = new ResultWrapper();
            wrap.mainField = String.isNotBlank(inputWrapper.fieldApiName) ? (String)s.get(inputWrapper.fieldApiName) : null;
            wrap.subField = String.isNotBlank(inputWrapper.otherFieldApiName) ? (String)s.get(inputWrapper.otherFieldApiName) : null;
            wrap.id = (String)s.get('Id');
            returnWrapperList.add(wrap);
        }
        return returnWrapperList;
    }   
}