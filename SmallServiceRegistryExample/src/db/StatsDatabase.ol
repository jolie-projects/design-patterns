include "database.iol"
include "console.iol"
include "StatsDatabase.iol"
include "string_utils.iol"

execution{ concurrent }

/* Move to internal DB service? */
inputPort InputDBPort {
    Location: "socket://localhost:8003"
    Protocol: sodep
    Interfaces: RegistryDBInterface
}

define initConnection
{
    with (connectionInfo) {
        .username = .password = .host = "";
        .database = "stats.db";
        .driver = "sqlite";
        .checkConnection = 1
    };
    connect@Database( connectionInfo )( )
}

define getNextIDForRegistering
{
    initConnection;
    println@Console( "now getting ID" )();
    query@Database( "SELECT MAX(ID) as ID FROM ServiceTable" )( res );
    nextID = res.row[0].ID[0] + 1
}

init
{
    initConnection
}

main
{
    [ register( registerRequest )( serviceID ) {
        scope( registerScope )
        {
            install( SQLException => serviceID = -1 );
            initConnection;
            getNextIDForRegistering;
            println@Console( "Got next ID as " + nextID )();
            with ( registerRequest )
            {
                println@Console( .serviceName + .location + .protocol )();
                update@Database("INSERT Into ServiceTable VALUES (" + nextID + ", '" + .serviceName + "', '" + .location + "', '" + .protocol + "', '" + .interfacefile + "', '" + .docFile + "');" )()
            };
            serviceID = nextID
        }
    }]
    [ deregister( deregisterRequest )( success ) {
        install( default => success = false );
        scope( deregisterScope )
        {
            update = "DELETE FROM ServiceTable WHERE id = " + deregisterRequest.id;
            update@Database(update)();
            success = true
        }
    }]
    [ queryServices( queryRequest )( queryResponse ) {
        query = "SELECT st.Name, st.Location, st.Protocol FROM ServiceTable st WHERE st.Name like '%" + queryRequest + "%' OR st.Location like '%" + queryRequest + "%' OR st.Protocol like '%" + queryRequest + "%'";
        scope( queryScope )
        {
            install ( SQLException => queryResponse = "" );
            query@Database( query )( queryResponse )
        }
    }]
    [ getServiceInterface( queryRequest )( queryResponse ) {
        query = "SELECT st.InterfaceFile FROM ServiceTable st WHERE st.Name = '" + queryRequest + "'";
        query@Database( query )( response );
        queryResponse = response.row[0].InterfaceFile[0]
    }]
    [ getServiceDocFile( queryRequest )( queryResponse) {
        query = "SELECT st.DocFile FROM ServiceTable st WHERE st.Name = '" + queryRequest + "'";
        query@Database( query )( response );
        queryResponse = response.row[0].DocFile[0]
    }]
}
