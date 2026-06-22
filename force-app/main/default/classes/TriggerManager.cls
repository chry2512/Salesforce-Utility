/**
 * @description       : Manage trigger processes
 * @author            : Christian Niro
 * @group             : 
 * @last modified on  : 05-15-2024
 * @last modified by  : 
**/
public class TriggerManager{

    // Method for avoid recursion in Trigger
    public static Boolean isFirstTime = true; // simple static variable for the check is the first time
    public static Map<System.TriggerOperation, Set<Id>> recordAlreadyProcess = new Map<System.TriggerOperation, Set<Id>>();// put records already process in this static map and use contains method for the check
    public static Map<System.TriggerOperation, String> triggerOperationMap = new Map<System.TriggerOperation, String>();// put  trigger name and operation in this static map and use contains method for the check

    public class TriggerManagerException extends Exception{} // custom exception for Trigger Manager

    // method to check the trigger is first run
    public static Boolean runFirst(System.TriggerOperation key, String triggerName){

        System.debug('<<<<<chryRunFirst' + isFirstTime);

        if(triggerOperationMap.containsKey(key) && triggerOperationMap.get(key) == triggerName){
            runOnce();
            return isFirstTime;
        }
        
        clearRun();
        return isFirstTime;
    }

    // method to check the trigger is run
    public static Boolean runOnce(){   
        isFirstTime = false;
        return isFirstTime;
    }

    // method to clear operation
    public static Boolean clearRun(){   
        isFirstTime = true;
        return isFirstTime;
    }


    //Set for skip trigger
    public static Set<String> skipTriggerSet = new Set<String>();
    // this method skip the Triggers
    public static void skipTrigger(String nameTrigger){
        if (String.isNotBlank(nameTrigger)){

            skipTriggerSet.add(nameTrigger);

        } else{

            if (!Test.isRunningTest()){
                throw new  TriggerManagerException(Label.TriggerManagerExceptionStringBlank); // custom label
            }
        }
    }

    // this method unskip the Triggers
    public static void unskipTrigger(String nameTrigger){
        if (String.isNotBlank(nameTrigger)){


            skipTriggerSet.remove(nameTrigger);

        } else{
           
            if (!Test.isRunningTest()){
                throw new  TriggerManagerException(Label.TriggerManagerExceptionStringBlank); // custom label
            }
        }
    }

    //this method check if trigger is skipped
    public static Boolean isTriggerSkip(String nameTrigger){

        if (String.isBlank(nameTrigger)){
            return false;

        } else{

            //if the name of trigger is present in custom set return True
            return skipTriggerSet.contains(nameTrigger);
        }
    }
}