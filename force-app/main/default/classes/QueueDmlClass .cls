/**
 * @description       : Queueble class for DML operations in bulk
 * @author            :
 * @group             :
 * @last modified on  : 03-09-2024
 * @last modified by  :
 **/
public class IP_QueueDmlClass implements Queueable{
    private static final Integer MAX = 3000;
    private List<SObject> originList = new List<SObject>();
    private IP_DmlDetails dmlDetail;
    private Database.DmlOptions dmlOptions;
    private IP_DmlMethod method;
    private IP_Access level;
    public IP_QueueDmlClass(List<SObject> originList, IP_DmlDetails dmlDetail){
        this.originList = originList;
        this.dmlOptions = dmlDetail.dmlOpts;
        this.method = dmlDetail.method;
        this.dmlDetail = dmlDetail;
        this.level = dmlDetail.level;
    }

    public void execute(QueueableContext context){

        if (!originList.isEmpty() && originList != null){

            List<SObject> dmlToOperation;

            List<List<SObject>> allListDML = new List<List<SObject>>();
            List<Database.SaveResult> sr = new List<Database.SaveResult>();
            List<Database.DeleteResult> rs = new List<Database.DeleteResult>();

            // Split records in List<List<Sobject>>
            for (Integer i = 0; i < (originList.size() / MAX) + 1; i++){

                dmlToOperation = new List<SObject>();

                for (Integer j = MAX * i; j < (MAX * i) + MAX && j < originList.size(); j++){
                    dmlToOperation.add(new List<SObject>(originList)[j]);
                }
                allListDML.add(dmlToOperation);
            }

            // switch if Insert or Update
            switch  on method{
                when INSERIRE{

                    SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.CREATABLE, allListDML[0]);
                    allListDML[0] = securityDecision.getRecords();

                    switch  on level{
                        when USER_MODE{
                            sr = Database.insert (allListDML[0], dmlOptions, AccessLevel.SYSTEM_MODE);
                        }
                        when SYSTEM_MODE{
                            sr = Database.insert (allListDML[0], dmlOptions, AccessLevel.USER_MODE);
                        }
                        when else{
                            sr = Database.insert (allListDML[0], dmlOptions, AccessLevel.USER_MODE);
                        }
                    }
                }

                when AGGIORNARE{

                    SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.UPDATABLE, allListDML[0]);
                    allListDML[0] = securityDecision.getRecords();

                    switch  on level{
                        when USER_MODE{
                            sr = Database.update (allListDML[0], dmlOptions, AccessLevel.SYSTEM_MODE);
                        }
                        when SYSTEM_MODE{
                            sr = Database.update (allListDML[0], dmlOptions, AccessLevel.USER_MODE);
                        }
                        when else{
                            sr = Database.update (allListDML[0], dmlOptions, AccessLevel.USER_MODE);
                        }
                    }
                }

                when ELIMINARE{

                    switch  on level{
                        when USER_MODE{
                            rs = Database.delete (allListDML[0], false, AccessLevel.SYSTEM_MODE);
                        }
                        when SYSTEM_MODE{
                            rs = Database.delete (allListDML[0], false, AccessLevel.USER_MODE);
                        }
                        when else{
                            rs = Database.delete (allListDML[0], false, AccessLevel.USER_MODE);
                        }
                    }
                }
            }

            // If there are more one list start recursive Queue
            if (allListDML.size() > 1){
                allListDML.remove(0);

                List<SObject> newSobjectRecursive = new List<SObject>();

                for (List<SObject> key : allListDML){
                    newSobjectRecursive.addAll(key);
                }

                if (!Test.isRunningTest()){
                    ID jobID = System.enqueueJob(new IP_QueueDmlClass(newSobjectRecursive, dmlDetail));
                }
            }
        }
    }
}