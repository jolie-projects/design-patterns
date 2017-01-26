include "Service_Registry.iol"
include "db/StatsDatabase.iol"
include "console.iol"

inputPort ServiceRegistryPort {
    Location: SERVICE_REGISTRY_LOCATION
    Protocol: SERVICE_REGISTRY_PROTOCOL
    Interfaces: ServiceRegistryInterface
}

execution{ concurrent }

main
{
    [ registerService( serviceRegisterRequest )( result ) // Register service-instance on startup
    {
        register@StatsDatabase( serviceRegisterRequest )( result )
    }]
    [ deregisterService( serviceDeregisterRequest )( success ) // Deregister service-instance on shutdown
    {
        deregister@StatsDatabase( serviceDeregisterRequest )( success )
    }]
    [ queryServices( request )( response ) {
        queryServices@StatsDatabase( request )( response )
    }]
    [ getServiceInterface( request )( response ) {
        getServiceInterface@StatsDatabase( request )( response )
    }]
    [ getServiceDocFile( request )( response ) {
        getServiceDocFile@StatsDatabase( request )( response )
    }]
}
