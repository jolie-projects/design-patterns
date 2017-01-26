include "../common/type_registering.iol"

interface RegisteringIFace {
    RequestResponse:
        registerService( RegisterRequest )( bool ),
        deregisterService( void )( bool ),
        generateAndGetJolieDocs( string )( string )
    OneWay:
}

outputPort RegisterService {
    Location: "local"
    Interfaces: RegisteringIFace
}
