To run it, either run the script “run.sh” or run the programs in the same order. 
This will create a database and add an example. 
The website is now running on http://localhost:8000/, and to add the FakeWeatherService, go to the Services folder and run “FakeWeatherService.ol”, which will add itself to the service registry, and will now show up on the website. It is necessary to go into the folder as the program will look for “FakeWeatherService.iol” in the current folder.

In the folder Clients, the WeatherEnthusiast.ol-file can be run to query the FakeWeatherService and shut it down, removing it from the Service Registry.


To add a new Service to the registry:

Embed the file “Registering.ol”, found in the Services-folder. In the init block, call the following operations:

generateAndGetJolieDocs@RegisterService( OWN_FILE_NAME )( docFileLocation );
readFile@File( { .filename = docFileLocation } )( docFileContent );
readFile@File( { .filename = OWN_INTERFACE_FILE_NAME )( interfaceFile);
registerService@RegisterService( { .serviceName = SERVICE_NAME, .location = SERVICE_LOCATION, .protocol = SERVICE_PROTOCOL, .interfacefile = interfaceFile, .docFile = docFileContent })( success )

To remove the service, have the service call:

deregisterService@RegisterService( )( success );

Where the embedded service contains the serviceID, so no request-argument is required.

QUERYING THE SERVICE REGISTRY:

Have the client include the file “Service_Registry.iol”, “runtime.iol” and the interface file of the service we want to contact,  and call the operation:

queryServices@ServiceRegistry( SERVICE_NAME )( result );
location = result.row[0].Location[0]; // Get the location
protocol = result.row[0].Protocol[0]; // Get the protocol
setOutputPort@Runtime( { .protocol = protocol, .location = location, .name = OUTPUTPORTNAME } )();

OUTPUTPORTNAME is the name of an outputport defined in the client. And example could be (on startup)
outputPort ExternalService {
    Location: ""
    Protocol: None
    Interfaces: SERVICE_INTERFACE
}
