/******************************************************************************
Author:Ryan O'Sullivan
Company:CloudKettle
Test Class(s):PlatfromCentralizerUnitTest
Description: Worker Trigger to handle load from central platfrom action

History:
 Date:2021-02-28
 By:Ryan O'Sullivan
 Action:Created
******************************************************************************/
trigger WorkerTrigger5 on Platform_Action_Worker_5__e (after insert) {
    new PlatformWorkerTriggerLogic('Platform_Action_Worker_5__e').execute();
}