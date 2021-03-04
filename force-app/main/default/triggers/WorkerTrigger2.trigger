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
trigger WorkerTrigger2 on Platform_Action_Worker_2__e (after insert) {
    new PlatformWorkerTriggerLogic('Platform_Action_Worker_2__e').execute();
}