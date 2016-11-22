interface CBIfaceExt {
    RequestResponse:
    OneWay:
        resetTO( void ),
        callTO( void ),
        closeTO( void )
}

outputPort CircuitBreaker {
    Location: "socket://localhost:8000"
    Protocol: sodep
    Interfaces: CBIfaceExt
}
