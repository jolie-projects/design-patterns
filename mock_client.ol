include "mock_service.iol"
include "console.iol"

outputPort MockService {
    Location: "socket://localhost:8004"
    Protocol: sodep
    Interfaces: MockServiceIface
}

main {
    spawn ( i over 750) {
        req@MockService( { .content = "hello" } )( response )
    }
}
