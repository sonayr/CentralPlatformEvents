/******************************************************************************
Author:Ryan O'Sullivan
Company:CloudKettle
Description:Test class for the Central Platfrom Action handler

History:
 Date:2021-02-28
 By:Ryan O'Sullivan
 Action:Created
******************************************************************************/
@isTest
private class PlatfromCentralizerUnitTest {

    private static final String TEST_CALLABLE = 'PlatformActionUtil.testableAction';
    
    @IsTest
    static void CreateValidAction(){
        Test.startTest();
        List<CallableAction> eventInfo = new CallableAction[]{new CallableAction(null,TEST_CALLABLE,'test',null)};
        String JSONMessage = JSON.serialize(eventInfo);
        Action__e action = new Action__e(JSON_Body__c = JSONMessage);
        Eventbus.publish(action);
        Test.stopTest();

        Integer countOfSubCalls = [SELECT ExternalId FROM EventBusSubscriber WHERE Tip >= 1]?.size();
        System.assertEquals(2, countOfSubCalls,'Should have ran twice to indicate the router ran and the designated worker ran');
    }

    @IsTest
    static void IsolateWorker(){
        
        // Setup static class list to accept test class
        List<String> callableList = PlatformActionUtil.getActiveCallables();
        callableList.add(TEST_CALLABLE.toLowerCase());
        PlatformActionUtil.activeCallables = callableList;

        Test.startTest();
        System.assert(!PlatformActionUtil.testCalled,'Test call should be set to false before a platform event is fired'); 
        CallableAction[] eventInfo = new CallableAction[]{new CallableAction(TEST_CALLABLE,'test',null)};
        String JSONMessage = JSON.serialize(eventInfo);
        Platform_Action_Worker_1__e actions = new Platform_Action_Worker_1__e(JSON_Body__c = JSONMessage);
        Eventbus.publish(actions);

        
        Test.stopTest();

        System.assert(PlatformActionUtil.testCalled,'Failed to call test Callable class through platform events'); 
    }
    @IsTest
    static void bulkActionTest(){
        Test.startTest();
        CallableAction[] eventInfo = new CallableAction[]{new CallableAction(TEST_CALLABLE,'test',null)};
        Action__e[] actions = new Action__e[]{};
        Integer maxBatchSize = PlatformActionUtil.getBatchSizeSetting();
        String JSONMessage = JSON.serialize(eventInfo);

        // Add one more than batch size limit to trigger a re-action
        for(Integer i = 0 ; i <= maxBatchSize; i++){
            actions.add(new Action__e(JSON_Body__c = JSONMessage));
        }
        Eventbus.publish(actions);
        Test.stopTest();
        EventBusSubscriber[] eventSubs = [SELECT ExternalId,Tip,Position FROM EventBusSubscriber];
        for (EventBusSubscriber eventSub : eventSubs) {
            system.debug(eventSub);
        }
        Integer countOfSubCalls = [SELECT ExternalId FROM EventBusSubscriber WHERE Tip >=: maxBatchSize]?.size();
        System.assertEquals(1, countOfSubCalls,'Did not find a trigger that ran ' + maxBatchSize +  ' batches'  );

    }

}
