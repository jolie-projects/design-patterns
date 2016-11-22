include "console.iol"
include "mock_service.iol"
include "time.iol"

execution { concurrent }

inputPort MockService {
    Location: "socket://localhost:8000"
    Protocol: sodep
    Interfaces: MockServiceIface
}

main {
    [ req( request )( response ) {
        response.content = request.content
    }]
}
