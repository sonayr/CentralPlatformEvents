# Central Platform Builder

Allows you to move asynchronous apex to run through a single platform event which distributes the work evenly to worker platform builders to excute in sepearate threads.

Use the CallableAction apex object to format the JSON text send to the body of the action event

The work to execute must use a callable and the apex class should be defined in the Platform_Callables Custom Metadata.

