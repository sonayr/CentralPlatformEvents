/******************************************************************************
Author:Ryan O'Sullivan
Company:CloudKettle
Test Class(s):PlatfromCentralizerUnitTest
Description:Defininiton of the Apex JSON object passed to PlatformAction

History:
 Date:2021-02-26
 By:Ryan O'Sullivan
 Action:Created

 Date:2021-03-06
 By:Ryan O'Sullivan
 Action:Added Static Calls to handle 
******************************************************************************/
global class CallableAction {

    private static List<CallableAction> callableList = new List<CallableAction>();
    // Namespace of the given class, if one exists
    public String nameSpace;
    
    // Name of the apex class to reference
    public String className;

    // Used to hold the method name to be executed (may not be useful for every call, depends on user implementation)
    public String action;

    // Used to hold the arguments passed to the executed apex class
    public Map<String, Object> args;


    /**
     * @function
     * @author Ryan O'Sullivan
     * @since 2021-03-06
     * @version 1.0
     * @description Adds a new callable to be executed later with
     * send action
     *
     * @param nameSpace - String of apex class namespace
     * @param className - String of apex class label
     * @param args - Map of string to object pointers
     * @return none
    **/
    global static void addCallable(String nameSpace, String className, String action, Map<String, Object> args ){
        callableList.add(new CallableAction(nameSpace,className,action,args));
    }

    /**
     * @function
     * @author Ryan O'Sullivan
     * @since 2021-03-06
     * @version 1.0
     * @description Adds a new callable to be executed later with
     * send actions
     *
     * @param className - String of apex class label
     * @param args - Map of string to object pointers
     * @return none
    **/
    global static void addCallable(String className,  String action, Map<String, Object> args ){
        callableList.add(new CallableAction(null,className,action,args));
    }
    /**
     * @function
     * @author Ryan O'Sullivan
     * @since 2021-03-06
     * @version 1.0
     * @description Adds a new callable to be executed later with
     * send actions
     *
     * @param action - Callabale action to add to list
     * @return none
    **/
    global static void addCallable(CallableAction action){
        callableList.add(action);
    }

    /**
     * @function
     * @author Ryan O'Sullivan
     * @since 2021-03-06
     * @version 1.0
     * @description Seralizes callable list and fires an action__e 
     * platform event with JSON seralization as body
     *
     * @param 
     * @return description of return
    **/
    global static Database.SaveResult sendActions(){
        String body = JSON.serialize(callableList);
        callableList.clear();
        return Eventbus.publish(new Action__e(JSON_Body__c = body));
    }

    /*************************Method**********************************
    @author:Ryan O'Sullivan
    @since:2021-02-26
    Description:Constructor for a callable action. Takes the name
    of an apex class and map of strings to object agnostic pointers
    
    @param action String name of the ApexClass Callable
    @param args Map of String to pointers (can be any object type)
    *****************************************************************/
    global CallableAction(String nameSpace, String className, String action, Map<String,Object> args){
        this.action = action;
        this.args = args;
        this.className = className;
        // this.className = nameSpace == null ? this.className : nameSpace + '.' + className;
        this.nameSpace = nameSpace;
    }
}
