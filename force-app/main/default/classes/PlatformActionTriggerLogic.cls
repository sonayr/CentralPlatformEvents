/******************************************************************************
Author:Ryan O'Sullivan
Company:CloudKettle
Test Class(s):PlatfromCentralizerUnitTest
Description:Trigger logic used for Action__e central handler trigger. 

History:
 Date:2021-02-24
 By:Ryan O'Sullivan
 Action:Created
******************************************************************************/
public class PlatformActionTriggerLogic extends BasePlatformTriggerLogic{
    List<SObject> workerEvents = new List<SObject>();
    public PlatformActionTriggerLogic(String eventDevName) {
        super(eventDevName);
    }

    override protected void loopLogic(SObject event){
        // Create list of workers here
        workerEvents.add(PlatformWorkerRouter.assignWorker((String)event.get('JSON_Body__c')));
    }

    override protected void postLoopLogic(){
        // Execute list of workers here
        Eventbus.publish(workerEvents);
    }

}