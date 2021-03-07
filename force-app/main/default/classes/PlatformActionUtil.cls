/******************************************************************************
Author:Ryan O'Sullivan
Company:CloudKettle
Test Class(s):PlatfromCentralizerUnitTest
Description:Utility class to hold common methods for the Platform Action
Framework

History:
 Date:2021-02-15
 By:Ryan O'Sullivan
 Action:Created
******************************************************************************/
public class PlatformActionUtil {
    private final static Integer OVER_RIDE_DEFAULT_BATCH_SIZE = 1;
    private final static Integer OVER_RIDE_DEFAULT_RETRY_SIZE = 0;
    private static Platform_Action_Settings__mdt settings;
    @TestVisible private static Map<String,List<String>> activeCallables;
    @TestVisible private static Boolean testCalled = false;
    
    /*************************Method**********************************
    @author:Ryan O'Sullivan
    @since:2021-02-15
    Description:Returns Batch Size setting from custom metadata
    Platform_Action_Settings__mdt 
    
    @return Integer representing batch size config option
    *****************************************************************/
    static public Integer getBatchSizeSetting(){
        return (Integer)getSettings().Batch_Size__c;
    }

    /*************************Method**********************************
    @author:Ryan O'Sullivan
    @since:2021-02-15
    Description:Returns a Max Retry size setting from custom metadata
    Platform_Action_Settings__mdt
    
    @return Integer representing max retry config option
    *****************************************************************/
    static public Integer getMaxRetrySetting(){
        return (Integer)getSettings().Max_Retries__c;
    }

    /*************************Method**********************************
    @author:Ryan O'Sullivan
    @since:2021-03-03
    Description:Gets a list of callable actions that are defined in
    Platform_Callables__mdt. All active callable classes should be
    defined here in order to run
    
    @return List of Strings represnting lower case class names
    *****************************************************************/
    static public Map<String,List<String>> getActiveCallables(){
        if(activeCallables == null){
            activeCallables = new Map<String,List<String>>();
            for(Platform_Callables__mdt callable : [SELECT NamespacePrefix, label FROM Platform_Callables__mdt WHERE active__c = true]){
                String lowercaseLabel = callable.label.toLowerCase();
                if(activeCallables.containsKey(callable.NamespacePrefix)){
                    activeCallables.get(callable.NamespacePrefix).add(lowercaseLabel);
                } else {
                    activeCallables.put(callable.NamespacePrefix,new List<String>{lowercaseLabel});
                }
            }
        }
        return activeCallables;
    }

    static private Platform_Action_Settings__mdt getSettings(){
        if(settings == null){
            // Query settings from Custom Metadata if not cached
            Platform_Action_Settings__mdt[] settingsQuery = [Select Batch_Size__c,Max_Retries__c from Platform_Action_Settings__mdt where Active__c = true order by label asc limit 1];
            if(settingsQuery.isempty()){
                // Create override defaults if nothing in custom metadata
                settings = new Platform_Action_Settings__mdt(
                    Batch_Size__c = OVER_RIDE_DEFAULT_BATCH_SIZE,
                    Max_Retries__c = OVER_RIDE_DEFAULT_RETRY_SIZE
                );
            } else {
                settings = settingsQuery[0]; // Return first from list
            }
        }
        return settings;
    }

    // This class is just used for the PlatformCentralizerUnitTest
    public class testableAction implements Callable {
        public Object call(String action, Map<String, Object> args) {
            testCalled = true;
            return null;
        }
    }
}
