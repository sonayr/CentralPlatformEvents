/******************************************************************************
Author:Ryan O'Sullivan
Company:CloudKettle
Test Class(s):PlatfromCentralizerUnitTest
Description:Logic used in each worker class, parses the action defined in 
the json body for each event AND executes to corresponding
 APEX class 
 

History:
 Date:2021-02-24
 By:Ryan O'Sullivan
 Action:Created
******************************************************************************/
public class PlatformWorkerTriggerLogic extends BasePlatformTriggerLogic{
    private String workerBodyFieldName;
    private List<String> activeCallables;
    private Set<String> invalidClassList = new Set<String>();
    private Set<String> inactiveClassList = new Set<String>();

    public PlatformWorkerTriggerLogic(String eventDevName){
        super(eventDevName);
    }

    // Code that happens for each loop of the given trigger object (i.e. creating list)
    override protected void loopLogic(SObject event){
        List<CallableAction> eventActions = (List<CallableAction>)JSON.deserializeStrict((String)event.get(getWorkerBodyName()),List<CallableAction>.class);
        for(CallableAction action : eventActions){
            if(checkActiveClass(action.className)){
                callAction(action);
            } else {
                // Debug list for post
                inactiveClassList.add(action.className);
            }
        }
    }

    // Code that happens after looping through each trigger object (i.e. processing list)
    override protected void postLoopLogic(){
        if(!inactiveClassList.isEmpty()){
            for(String inactiveClass : inactiveClassList){
                System.debug('🔧🔧🔧 ' + inactiveClass + ' is either inactive in Platform_Callables__mdt or not included and has been skipped');
            }
        }

        if(!invalidClassList.isEmpty()){
            for(String invalidClass : invalidClassList){
                System.debug('❌❌❌ ' + invalidClass + ' does not implement the interface Callable and was unable to run');
            }
        }
    }
    
    private String getWorkerBodyName(){
        if(workerBodyFieldName == null){
            this.workerBodyFieldName = [SELECT Body_Field_Name__c 
                                        FROM Platform_Action_Worker__mdt 
                                        WHERE active__c = true 
                                        AND Platform_Event_Api_Name__c =: this.SobjectApiName 
                                        LIMIT 1]
                                        ?.Body_Field_Name__c;
        }
        return this.workerBodyFieldName;
    }

    private Boolean checkActiveClass(String className){
        return PlatformActionUtil.getActiveCallables().contains(className?.toLowerCase());
    }

    private void callAction(CallableAction action){
        Type callableClass = Type.forName(action.nameSpace,action.className);
        if(Callable.class.isAssignableFrom(callableClass)){
            // Class is a callable
            ((Callable)callableClass.newInstance()).call(action.action, action.args);
        } else {
            // Debug list for post
            invalidClassList.add(action.className);
        }
    }

}