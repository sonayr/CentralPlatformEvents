/******************************************************************************
Author:Ryan O'Sullivan
Company:CloudKettle
Test Class(s):[To Create]
Description:Centralized handler to manage and route all Platform Action events.
This class will break up all events into worker platform events as each 
event-trigger pair will take up a single thread
Uses Custom Metadata Platform_Action_Settings__mdt to config runtime settings

History:
 Date:2021-02-15
 By:Ryan O'Sullivan
 Action:Created
******************************************************************************/
trigger PlatformActionHandler on Action__e (after insert) {
    new PlatformActionTriggerLogic('Action__e').execute();
}