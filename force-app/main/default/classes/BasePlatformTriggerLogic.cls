/******************************************************************************
Author:Ryan O'Sullivan
Company:CloudKettle
Test Class(s):PlatfromCentralizerUnitTest
Description:Platform trigger base logic to enforce retry and batch limiting
logic controlled in Platform_Action_Settings__mdt custom metadata

History:
 Date:2021-02-23
 By:Ryan O'Sullivan
 Action:Created
******************************************************************************/
public abstract class BasePlatformTriggerLogic {
    private Integer batchSizeMax = PlatformActionUtil.getBatchSizeSetting();
    private Integer batchCounter = 0;
    
    protected String replayId;
    protected String SobjectApiName;

    public BasePlatformTriggerLogic(String eventDevName){
        SobjectApiName = eventDevName;
    }
    /*************************Method**********************************
    @author:Ryan O'Sullivan
    @since:2021-02-23
    Description:Executes on the defined triggerAction code while 
    wrapping it with built in retry logic as well as managing batch
    size.

    The logic that occurs in the loop can be defined 

    Both these parameters are controlled in 
    Platform_Action_Settings__mdt custom metadata
    *****************************************************************/
    public void execute() {
        try{
            for(SObject event : Trigger.new){
                
                loopLogic(event);
                
                // Capture replayId to resume next batch after
                if(++batchCounter > batchSizeMax){
                    replayId = (String)event.get('ReplayId');
                    break;
                }
            }
            postLoopLogic();
            if(replayId != null){
                // Continues next batch of events after given id
                EventBus.TriggerContext.currentContext().setResumeCheckpoint(replayId);
            }
        } catch(Exception e){
            if (EventBus.TriggerContext.currentContext().retries < PlatformActionUtil.getMaxRetrySetting()) {
                throw new EventBus.RetryableException(e.getMessage());
            }
        }
    }

    // Code that happens for each loop of the given trigger object (i.e. creating list)
    abstract protected void loopLogic(SObject event);

    // Code that happens after looping through each trigger object (i.e. processing list)
    abstract protected void postLoopLogic();

}