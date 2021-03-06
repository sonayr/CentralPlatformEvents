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
        List<Object> eventActions = (List<Object>)JSON.deserializeUnTyped((String)event.get(getWorkerBodyName()));
        for(Object callableDetails : eventActions){
            try{
                Map<String,Object> details = (Map<String,Object>)callableDetails;
                String className = (String)details.get('className');
                if(checkActiveClass(className)){
                    callAction(details);
                } else {
                    // Debug list for post
                    inactiveClassList.add(className);
                }
            } catch(TypeException excp){
                System.debug('🌪🌪🌪 Cast exception' + excp.getMessage());
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

    private void callAction(Map<String,Object> callableDetails){
        String className = (String)callableDetails.get('className');
        String action = (String)callableDetails.get('action');
        Map<String,Object> args = (Map<String,Object>)callableDetails.get('args');

        Type callableClass = Type.forName(className);
        if(Callable.class.isAssignableFrom(callableClass)){
            // Class is a callable
            ((Callable)callableClass.newInstance()).call(action, args);
        } else {
            // Debug list for post
            invalidClassList.add(className);
        }
    }

}