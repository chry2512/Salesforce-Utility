/**
 * @description       : DML operations with different Access levels
 * @author            : CHRISTIAN NIRO
 * @group             :
 * @last modified on  : 06-22-2026
 * @last modified by  : Christian Niro
 **/
public class DmlClass implements DmlOperable {
    
    private static final Integer MAX_RECORDS = 3000;
    private static final Integer MAX_LOG = 200;
    private static Boolean allRecords = false;
    public class DmlException extends Exception{
    }

    //insert List of Sobject with SYSTEM Access Level
    public static Object insertSobjectSystem(List<SObject> objectToijnstance, Database.DmlOptions dmlOptions){

        Database.DmlOptions dml = new Database.DmlOptions();
        if (dmlOptions == null){
            dml.OptAllOrNone = false;
        } else{
            dml = dmlOptions;
        }

        IP_DmlDetails details = new IP_DmlDetails(dml, IP_Access.SYSTEM_MODE, IP_DmlMethod.INSERIRE);

        //check records size and start queable for more records
        if (objectToijnstance.size() >= MAX_RECORDS){


            Id jobId = System.enqueueJob(new IP_QueueDMLClass(objectToijnstance, details));        
        } else{


            SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.CREATABLE, objectToijnstance);
            objectToijnstance = securityDecision.getRecords();
            List<Database.SaveResult> returnedValue = Database.insert (objectToijnstance, dml, AccessLevel.SYSTEM_MODE);

            if (returnedValue.size() < MAX_LOG){
                allRecords = true;
            }

            if (dml.OptAllOrNone == true){

                for (Database.SaveResult sr : returnedValue){
                    if (!sr.isSuccess()){
                        throw new DmlException(LabelDmlExceptionErrorInsert + sr.getErrors());
                    }
                }
            }       
        }

        return objectToijnstance;
    }

    //update List of Sobject with SYSTEM Access Level
    public static Object updateSobjectSystem(List<SObject> objectToijnstance, Database.DmlOptions dmlOptions){
      
        Database.DmlOptions dml = new Database.DmlOptions();

        if (dmlOptions == null){
            dml.OptAllOrNone = false;
        } else{
            dml = dmlOptions;
        }

        IP_DmlDetails details = new IP_DmlDetails(dml, IP_Access.SYSTEM_MODE, IP_DmlMethod.AGGIORNARE);
        //check records size and start queable for more records
        if (objectToijnstance.size() >= MAX_RECORDS){
            if (objectToijnstance.getSObjectType().getDescribe().isUpdateable()){
                Id jobId = System.enqueueJob(new IP_QueueDMLClass(objectToijnstance, details));
              
            }
        } else{

            SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.UPDATABLE, objectToijnstance);
            objectToijnstance = securityDecision.getRecords();
            List<Database.SaveResult> returnedValue = Database.update (objectToijnstance, dml, AccessLevel.SYSTEM_MODE);
            if (returnedValue.size() < MAX_LOG){
                allRecords = true;
            }

            if (dml.OptAllOrNone == true){

                for (Database.SaveResult sr : returnedValue){
                    if (!sr.isSuccess()){
                        throw new DmlException(LabelDmlExceptionErrorUpdate + sr.getErrors());
                    }
                }
            }
        }

        return objectToijnstance;
    }

    //insert List of Sobject with USER Access Level
    public static Object insertSobjectUser(List<SObject> objectToijnstance, Database.DmlOptions dmlOptions){
     
        Database.DmlOptions dml = new Database.DmlOptions();

        if (dmlOptions == null){
            dml.OptAllOrNone = false;
        } else{
            dml = dmlOptions;
        }

        IP_DmlDetails details = new IP_DmlDetails(dml, IP_Access.USER_MODE, IP_DmlMethod.INSERIRE);

        //check records size and start queable for more records
        if (objectToijnstance.size() >= MAX_RECORDS){

            Id jobId = System.enqueueJob(new IP_QueueDMLClass(objectToijnstance, details));
        } else{

            SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.CREATABLE, objectToijnstance);
            objectToijnstance = securityDecision.getRecords();
            List<Database.SaveResult> returnedValue = Database.insert (objectToijnstance, dml, AccessLevel.USER_MODE);
            if (returnedValue.size() < MAX_LOG){
                allRecords = true;
            }

            if (dml.OptAllOrNone == true){

                for (Database.SaveResult sr : returnedValue){
                    if (!sr.isSuccess()){
                        throw new DmlException(LabelDmlExceptionErrorInsert + sr.getErrors());
                    }
                }
            }      
        }
        return objectToijnstance;
    }

    //update List of Sobject with USER Access Level
    public static Object updateSobjectUser(List<SObject> objectToijnstance, Database.DmlOptions dmlOptions){

        Database.DmlOptions dml = new Database.DmlOptions();

        if (dmlOptions == null){
            dml.OptAllOrNone = false;
        } else{
            dml = dmlOptions;
        }

        IP_DmlDetails details = new IP_DmlDetails(dml, IP_Access.USER_MODE, IP_DmlMethod.AGGIORNARE);
        //check records size and start queable for more records
        if (objectToijnstance.size() >= MAX_RECORDS){

            if (objectToijnstance.getSObjectType().getDescribe().isUpdateable()){

                Id jobId = System.enqueueJob(new IP_QueueDMLClass(objectToijnstance, details));
               
            }
        } else{

            SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.UPDATABLE, objectToijnstance);
            objectToijnstance = securityDecision.getRecords();
            List<Database.SaveResult> returnedValue = Database.update (objectToijnstance, dml, AccessLevel.USER_MODE);
            if (returnedValue.size() < MAX_LOG){
                allRecords = true;
            }

            if (dml.OptAllOrNone == true){

                for (Database.SaveResult sr : returnedValue){
                    if (!sr.isSuccess()){
                        throw new DmlException(LabelDmlExceptionErrorUpdate + sr.getErrors());
                    }
                }
            }     
        }

        return objectToijnstance;
    }
}