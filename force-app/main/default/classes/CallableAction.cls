/******************************************************************************
Author:Ryan O'Sullivan
Company:CloudKettle
Test Class(s):PlatfromCentralizerUnitTest
Description:Defininiton of the Apex JSON object passed to PlatformAction

History:
 Date:2021-02-26
 By:Ryan O'Sullivan
 Action:Created
******************************************************************************/
global class CallableAction {
    
    // Namespace of the given class, if one exists
    public String nameSpace;
    
    // Name of the apex class to reference
    public String className;

    // Used to hold the method name to be executed (may not be useful for every call, depends on user implementation)
    public String action;

    // Used to hold the arguments passed to the executed apex class
    public Map<String, Object> args;

    
    /*************************Method**********************************
    @author:Ryan O'Sullivan
    @since:2021-02-26
    Description:Constructor for a callable action. Takes the name
    of an apex class and map of strings to object agnostic pointers
    
    @param action String name of the ApexClass Callable
    @param args Map of String to pointers (can be any object type)
    *****************************************************************/
    public CallableAction(String className, String action, Map<String,Object> args){
        this.className = className;
        this.action = action;
        this.args = args;
    }

    public CallableAction(String nameSpace, String className, String action, Map<String,Object> args){
        this(className,action,args);
        this.nameSpace = nameSpace;
    }
}
