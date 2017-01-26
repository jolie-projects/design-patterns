include "../Service_Registry.iol"
include "console.iol"
include "runtime.iol"
include "../Services/FakeWeatherService.iol"
include "ui/swing_ui.iol"

main
{
    queryServices@ServiceRegistry( "FakeWeatherService" )( result );
    location = result.row[0].Location[0];
    protocol = result.row[0].Protocol[0];
    setOutputPort@Runtime( { .protocol = protocol, .location = location, .name = "ExternalService" } )();
    getDayWeather@ExternalService( { .country = "denmark", .zipcode = "1955" } )( res );
    showMessageDialog@SwingUI("In the country of denmark, in the zipcode 1955, the number of degrees is " + res.degrees[0] + " and the weather is " + res.weatherType[0] )();
    shutdown@ExternalService()
}

outputPort ExternalService {
    Location: ""
    Protocol: None
    Interfaces: FakeWeatherInterface
}
