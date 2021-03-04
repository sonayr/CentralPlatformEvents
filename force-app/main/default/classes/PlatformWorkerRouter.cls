/******************************************************************************
Author:Ryan O'Sullivan
Company:CloudKettle
Test Class(s):PlatfromCentralizerUnitTest
Description:Router logic for workers from centralized action Handler

Distributes work in round robin fashion to all workers registered in 
Platform_Action_Worker__mdt

History:
 Date:2021-02-15
 By:Ryan O'Sullivan
 Action:Created
******************************************************************************/
public class PlatformWorkerRouter{
    private static Map<SObjectType,String> workers;
    private static Integer workerLen;
    private static Integer counter = 0;
    private final static String LONG_TEXT_FIELD_TYPE = 'TextArea';
    private final static Integer LONG_TEXT_MAX_LEN = 131072;

    /*************************Method**********************************
    @author:Ryan O'Sullivan
    @since:2021-02-23
    Description:Returns a worker from a staticly saved list. Returned
    worker also has the given json body added to the event.
    
    @param jsonBody JSON string containing message body
    @return SObject representing a platform event worker
    *****************************************************************/
    public static SObject assignWorker(String jsonBody){
        Map<SObjectType,String> workerMap = getWorkerMap();
        if(!workerMap.isEmpty()){
            Integer indexMod = Math.mod(counter++,workerMap.size());
            SobjectType eventWorkerType = new List<SObjectType>(workerMap.keySet())[indexMod];
            String bodyField = workerMap.get(eventWorkerType);
            SObject eventWorker = eventWorkerType.newSObject();
            eventWorker.put(bodyField,jsonBody);
            return eventWorker;
        }else {
            throw new workerException('🚨🚨🚨 No valid workers turned on 🚨🚨🚨');
        }

    }

    /*************************Method**********************************
    @author:Ryan O'Sullivan
    @since:2021-02-23
    Description:Helper method to cache worker list. If cache is empty
    uses Platform_Action_Worker__mdt to determine the list of workers
    and validates each one to create a list to return and then cache
    
    @return Returns map of body_field_names to the work sobjecttype
    *****************************************************************/
    private static Map<SObjectType,String> getWorkerMap(){
        if(workers == null){
            workers = new Map<SObjectType,String>();
            for(Platform_Action_Worker__mdt activeWorkerMdt : [Select label,Platform_Event__r.QualifiedApiName,Body_Field__r.QualifiedApiName from Platform_Action_Worker__mdt where active__c = true]){
                SObjectType workerType = Schema.getGlobalDescribe().get(activeWorkerMdt.Platform_Event__r.QualifiedApiName);
                
                if(validatePlatformWorker(workerType,activeWorkerMdt)){
                    workers.put(workerType,activeWorkerMdt.Body_Field__r.QualifiedApiName);
                }
            }
        }
        return workers;
    }

    /*************************Method**********************************
    @author:Ryan O'Sullivan
    @since:2021-02-23
    Description:Validates that the given sObject represented by the
    mapping Metadata has a valid long text body field set at max 
    length. If not returns false and sends debug message to console
    otherwise returns true
    
    @param worker SObjectType representing the platform event
    @param mapping Platform_Action_Worker__mdt 
    @return Boolean value of true if worker and mapping are a valid
    platform event worker, false otherwise
    *****************************************************************/
    private static boolean validatePlatformWorker(SObjectType worker,Platform_Action_Worker__mdt mapping){
        Schema.DescribeFieldResult bodyField = worker?.getDescribe()?.fields.getMap().get(mapping.Body_Field__r.QualifiedApiName)?.getDescribe();
        String fieldType = bodyField?.getType().name();

        if(fieldType != LONG_TEXT_FIELD_TYPE){
            System.debug('🚨🚨🚨 The Worker API Name:' 
            + mapping.Platform_Event__r.QualifiedApiName
            + ' for '
            +  mapping.label
            + ' is invalid, please correct');
            return false;
        } else if(bodyField.getLength() < LONG_TEXT_MAX_LEN){ // No need for safe check here, would have failed above
            System.debug('🚨🚨🚨 The Worker API Name:' 
            + mapping.Platform_Event__r.QualifiedApiName
            + ' for '
            +  mapping.label
            + ' body field is not set at a max length of at least '
            + LONG_TEXT_MAX_LEN
            + '. Please correct as it is currently only set at '
            + bodyField.getLength());
            return false;
        }
        return true;
    }
    
    public class workerException extends Exception{}
}
