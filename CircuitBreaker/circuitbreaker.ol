include "time.iol"
include "console.iol"
include "circuitbreaker.iol"
// TargetSrv
include "mock_service.iol"

execution { concurrent }

constants {
    OPEN = 0,
    HALF_OPEN = 1,
    CLOSED = 2,
    callTOval = 20000, // 20 seconds in milliseconds
    resetTOval = 30000 // 30 seconds in milliseconds
}

init {
    global.state = CLOSED
}

interface extender CBIfaceExt {
    RequestResponse:
        *( void )( void ) throws CBFault
}

// Stats as embedded service
include "stats.iol"
outputPort Stats {
	Interfaces: IfaceStats
}

embedded {
    Jolie: "stats.ol" in Stats
}



inputPort localPort {
    Location: "local"
    Interfaces: CBIfaceExt
}

outputPort MockService {
    Location: "socket://localhost:8000"
    Protocol: sodep
    Interfaces: MockServiceIface
}

// Receives client messages
inputPort CircuitBreaker {
    Location: "socket://localhost:8004"
    Protocol: sodep
    Interfaces: CBIfaceExt
    Aggregates: MockService with CBIfaceExt
}

define callTO {
    //Start timer with duration set by callTO parameter
    scheduleTimeout@Time( callTOval { .operation = "callTO", .timeunit = "MILLISECONDS" } )( uuid )
}

define resetTO {
    // Try to close (transition to half-open) CB after being opened
    scheduleTimeout@Time( resetTOval { .operation = "resetTO"} )( )
}

define cancelCallTO {
    // kill callTO timeout
    cancelTimeout@Time( uuid )( )
}

define trip { global.state = OPEN; resetTO; println@Console( "Now OPEN" )() /* DELETE */ }

define checkErrorRate
{
    // check to see if statechange is necessary
    synchronized( stateToken ) {
        if (global.state == CLOSED) {
            shouldTrip@Stats()( shouldTrip );
            if ( shouldTrip ) { trip }
        } else if ( global.state == HALF_OPEN ) {
            trip
        }
    }
}

courier CircuitBreaker {
    [ interface MockServiceIface( request )( response )] {
        if ( global.state == CLOSED ) {
            callTO;
            install ( default => cancelCallTO; failure@Stats(); checkErrorRate );
            forward( request )( response );
            success@Stats(); cancelCallTO
        } else if ( global.state == OPEN ) {
            throw( CBFault )
        } else if ( global.state == HALF_OPEN) {
            checkRate@Stats( )( canPass );
            if ( canPass ) {
                callTO;
                install (default => cancelCallTO; failure@Stats(); checkErrorRate );
                forward( request )( response );
                success@Stats(); cancelCallTO;
                scheduleTimeout@Time( resetTOval { .operation = "closeTO" } )()
            } else {
                throw ( CBFault )
            }
        }
    }
}

main {
    [ callTO() ]  {
        timeout@Stats(); checkErrorRate
    }

    [ resetTO() ]  {
        synchronized( stateToken ) {
            if ( global.state == OPEN )
            {
                reset@Stats(); global.state = HALF_OPEN;
                println@Console( "Now HALF_OPEN ")(); // DELETE
                scheduleTimeout@Time( resetTOval { .operation = "closeTO" } )()
            }
        }
    }

    [ closeTO() ] {
        getStability@Stats( )( stable );
        synchronized( stateToken ) {
            if (global.state == HALF_OPEN) {
                if ( stable ) {
                    println@Console( "Now CLOSED" )(); // DELETE
                    global.state = CLOSED
                }
            }
        }
    }
}
