include "console.iol"
include "database.iol"
include "file.iol"
include "exec.iol"
include "string_utils.iol"
include "runtime.iol"

constants {
    databasename = "stats.db",
    debug = true
}

main {
    tryCreateDatabaseFile;
    initConnection;
    tryCreateTables
}

define initConnection
{
    with ( connectionInfo )
    {
        .username = .password = .host = "";
        .database = "stats.db";
        .driver = "sqlite";
        .checkConnection = 1
    };
    connect@Database( connectionInfo )( )
}

define tryCreateDatabaseFile
{
    exists@File( databasename )( exists );
    if (!exists)
    {
        commandExecutionRequest = "touch";
        with ( commandExecutionRequest ) {
            .args[0] = databasename;
            .waitFor = 1
        };
        exec@Exec( commandExecutionRequest )( execResult )
    }
}

define tryCreatePingTable
{
    pingTable =
    "CREATE TABLE IF NOT EXISTS " +
    "PingTable (id bigint PRIMARY KEY NOT NULL UNIQUE, " + "LastSuccessfulPing DATETIME, LastPing DATETIME)";
    updateRequest = pingTable;
    update@Database( updateRequest )( )
}

define tryCreateServiceTable
{
    println@Console( "Servicetable" )();
    serviceTable =
    "CREATE TABLE IF NOT EXISTS " +
    "ServiceTable (id bigint PRIMARY KEY NOT NULL UNIQUE, " +
    "Name NVARCHAR(200), Location NVARCHAR(200), Protocol NVARCHAR(50), InterfaceFile NVARCHAR(5000), DocFile NVARCHAR(5000))";
    updateRequest = serviceTable;
    update@Database( updateRequest )( result )
}

define tryCreateTestData
{
    println@Console( "testdata" )();
    testData =
    "INSERT OR REPLACE INTO ServiceTable " +
    "VALUES (0, 'Example', 'example.org', 'http', 'just an example', 'no docs here, mate')";
    updateRequest = testData;
    update@Database( updateRequest )( resy );
    println@Console( resy )();
    query@Database( "SELECT * FROM ServiceTable ")( res );
    valueToPrettyString@StringUtils( res )( resp );
    println@Console( resp )()
}

define tryCreateTables
{
    tryCreatePingTable;
    tryCreateServiceTable;
    if ( debug )
    {
        tryCreateTestData
    }
}
