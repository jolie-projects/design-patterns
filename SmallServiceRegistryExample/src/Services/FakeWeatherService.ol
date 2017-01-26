include "FakeWeatherService.iol"
include "string_utils.iol"
include "Registering.iol"
include "console.iol"
include "file.iol"

constants {
    FWS_LOCATION = "socket://localhost:8002",
    FWS_PROTOCOL = sodep
}

embedded {
    Jolie: "Registering.ol" in RegisterService
}

execution { concurrent }

inputPort FakeWeatherInputPort {
    Location: FWS_LOCATION
    Protocol: FWS_PROTOCOL
    Interfaces: FakeWeatherInterface
}

init
{
    generateAndGetJolieDocs@RegisterService( "FakeWeatherService.ol" )( docFileLocation );
    readFile@File( { .filename = docFileLocation } )( docFileContent );
    readFile@File( { .filename = "FakeWeatherService.iol" } )( interfaceFile );
    registerService@RegisterService( { .serviceName = "FakeWeatherService", .location = FWS_LOCATION, .protocol = "sodep", .interfacefile = interfaceFile, .docFile = docFileContent })( success )
}

main
{
    [ getDayWeather( request )( response ) {
        toLowerCase@StringUtils( request.country )( country );
        if ( country == "england" ) {
            if ( request.zipcode == "EC2R 6AB") {
                response.degrees[0] = 10;
                response.weatherType[0] = "rain"
            }
        } else if ( country == "denmark" ) {
            if ( request.zipcode == "5000" ) {
                response.degrees[0] = 2;
                response.weatherType[0] = "blizzard"
            } else if ( request.zipcode == "1955" ) {
                response.degrees[0] = 24;
                response.weatherType[0] = "sunny"
            }
        }
    } ]

    [ getHourWeather( request )( response ) {
        toLowerCase@StringUtils( request.country )( country );
        if ( country == "england" ) {
            if ( request.zipcode == "EC2R 6AB") {
                response.degrees[0] = 10;
                response.weatherType[0] = "rain"
            }
        } else if ( country == "denmark" ) {
            if ( request.zipcode == "5000" ) {
                response.degrees[0] = 2;
                response.weatherType[0] = "blizzard"
            } else if ( request.zipcode == "1955" ) {
                response.degrees[0] = 24;
                response.weatherType[0] = "sunny"
            }
        }
    }]

    [ shutdown() ] {
        deregisterService@RegisterService( )( success );
        println@Console( "Shutdown: " + success )();
        if ( success == false ) {
            println@Console( "Removing service failed ")()
        } else {
            exit
        }
    }
}
