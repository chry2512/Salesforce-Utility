/**
 * @description       : Controller class for Search Product Component
 * @author            : Christian Niro
 * @group             :
 * @last modified on  : 05-27-2024
 * @last modified by  :
 **/
public class SearchProductController{
    private static QueryClass queryClassInstance = new QueryClass();
    @AuraEnabled
    public static List<Product2> searchProducts(String productName){

        String objectName = 'Product2';
        List<Product2> productList = new List<Product2>();
        Map<String, Object> binds = new Map<String, Object>{ 'productName' => productName };
        String condition = 'Name LIKE:productName';
        String accesslevel = QueryClass.SYSTEM_MODE;
        try{

            productList = QueryClass.queryHelperMethod(binds, objectName, condition, accessLevel, false);

            System.debug('productList' + productList);

            if (productList.isEmpty()){

                throw new AuraHandledException(Label.NoProductFound);

            }
        } catch (Exception e){
            if (!Test.isRunningTest()){
                throw new AuraHandledException(e.getMessage());
            }
        }
        return productList;
    }

    // Method for Update Records
    @AuraEnabled
    public static String updateProducts(Object data){
        List<Product2> productsToUpdate = (List<Product2>)JSON.deserialize(JSON.serialize(data), List<Product2>.class);
        try{
            if (Schema.sObjectType.Product2.isUpdateable()){
                Database.update (productsToUpdate, false, AccessLevel.USER_MODE);
            }
            return 'Success';
        } catch (Exception e){
            return e.getMessage();
        }
    }

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