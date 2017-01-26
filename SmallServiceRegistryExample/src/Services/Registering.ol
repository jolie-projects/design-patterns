include "console.iol"
include "../Service_Registry.iol"
include "Registering.iol"
include "exec.iol"
include "string_utils.iol"

inputPort localInput {
    Location: "local"
    Interfaces: RegisteringIFace
}

init
{
    global.serviceID = -1
}

execution { sequential }

main
{
    [ registerService( registerRequest )( success ) {
        success = false;
        registerService@ServiceRegistry( registerRequest )( serviceID );
        global.serviceID = serviceID;
        println@Console(global.serviceID + " assigned as serviceID")();
        success = true
    } ]

    [ deregisterService ( )( success ) {
        success = false;
        if (global.serviceID != -1) {
            deregisterService@ServiceRegistry( { .id = global.serviceID } )( success )
        }
    } ]
    [ generateAndGetJolieDocs( filenameRequest )( filenameResponse ) {
        // Not pretty solution, possible issues if filename contains whitespace?
        exec@Exec( "joliedoc" { .args[0] = filenameRequest, .waitFor = 1, .stdOutConsoleEnable = false } )( res );
        split@StringUtils( res { .regex = " " } )( splitResult );
        fileName = splitResult.result[2];
        length@StringUtils( fileName )( length );
        substring@StringUtils( fileName { .end = length - 1, .begin = 0 })( filenameResponse )
    }]
}
