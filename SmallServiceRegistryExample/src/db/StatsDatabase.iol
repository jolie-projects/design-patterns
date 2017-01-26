include "../common/type_registering.iol"

interface RegistryDBInterface {
    RequestResponse:
        register( RegisterRequest )( long ) throws RegisteringFault,
        deregister( DeregisterRequest )( bool ) throws DeregisterFault,
        queryServices( string )( undefined ),
        getServiceInterface( string )( string ),
        getServiceDocFile( string )( string )
    OneWay:
}

outputPort StatsDatabase {
    Location: "socket://localhost:8003"
    Protocol: sodep
    Interfaces: RegistryDBInterface
}
