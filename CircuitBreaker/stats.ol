include "console.iol"
include "stats.iol"
include "math.iol"
include "time.iol"

execution { concurrent } // Either sequential or make atomic when incrementing values

init {
    global.noOfCurrentSuccesses = 0;
    global.noOfCurrentFailures = 0;
    global.noOfCurrentTimeouts = 0;
    getCurrentTimeMillis@Time()(now);
    global.lastFailure = now;
    resetRollingWindowValues
}

constants {
    tripThreshold = 0.05, // 5 percent
    callTOval = 20000, // 20 seconds in milliseconds
    rollingWindowTimeValue = 60000, // 60 seconds in milliseconds
    usesRandomIntForCheckRate = false,
    requestsPerRollingWindowAllowed = 60,
    randomLowerValue = 0.10,
    timeSinceLastFailureAllowed = 60000, // 60 seconds in milliseconds
    debug = false,
    useTimerForClosing = true
}

inputPort localIn {
    Location: "local"
    Interfaces: IfaceStats
}

// Use if not embedded
/*inputPort Stats {
    Location: "socket://localhost:8080"
    Protocol: sodep
    Interfaces: IfaceStats
}*/

main {
    [ timeout() ] {
        getCurrentTimeMillis@Time()( now );
        synchronized ( syncToken ) {
            global.lastFailure = now;
            global.noOfCurrentTimeouts += 1
        }
    }
    [ reset() ] {
        synchronized ( syncToken ) {
            global.noOfCurrentFailures = 0;
            global.noOfCurrentSuccesses = 0;
            global.noOfCurrentTimeouts = 0
        }
    }
    [ failure() ] {
        getCurrentTimeMillis@Time()( now );
        synchronized ( syncToken ) {
            global.noOfCurrentFailures += 1;
            global.lastFailure = now
        }
    }
    [ success() ] {
        synchronized ( syncToken ) {
            global.noOfCurrentSuccesses += 1
        }
    }
    [ checkRate( )( canPass )  {
        // Either random or using rollingWindow
        canPass = false;
        if ( usesRandomForCheckRate ) {
            random@Math( )( randDouble );
            if ( randDouble >= randomLowerValue ) {
                canPass = true
            }
        }
        else { // Use rolling window approach (this is the default)
            tryResetRollingWindowValues;
            if (global.rollingWindowValues.totalRequests < requestsPerRollingWindowAllowed) {
                canPass = true;
                global.rollingWindowValues.totalRequests += 1
            }
        }
    }]
    [ shouldTrip( )( trip ) {
        trip = false;
        with( global ){
            total = double( .noOfCurrentSuccesses + .noOfCurrentFailures + .noOfCurrentTimeouts );
            if (total != 0) {
                if ( double(.noOfCurrentFailures + .noOfCurrentTimeouts ) / total >= tripThreshold) {
                    trip = true
                }
            }
        }
    }]
    [ getStability( )( stable ) {
        stable = false;
        with( global.rollingWindowValues ) {
            if ( useTimerForClosing ) {
                getCurrentTimeMillis@Time( )( now );
                if ( global.lastFailure + timeSinceLastFailureAllowed < now ) {
                    stable = true
                }
            } else if ( .numberOfSuccesses == .totalRequests ){
                stable = true
            }
        }
    } ]
}

define resetRollingWindowValues
{
    getCurrentTimeMillis@Time()( currentTimeMillis );
    with ( global.rollingWindowValues ) {
        if (debug) {
            println@Console("next reset: " + .nextResetInMillis)();
            println@Console("successes: " + .numberOfSuccesses)();
            println@Console("failures: " + .numberOfFailures)();
            println@Console("timeouts: " + .numberOfTimeouts)();
            println@Console("reqs: " + .totalRequests)()
        };
        .nextResetInMillis = currentTimeMillis + rollingWindowTimeValue;
        .numberOfSuccesses = 0;
        .numberOfFailures = 0;
        .numberOfTimeouts = 0;
        .totalRequests = 0
    }
}

define tryResetRollingWindowValues
{
    getCurrentTimeMillis@Time()( currentTimeMillis );
    if (currentTimeMillis > global.rollingWindowValues.nextResetInMillis) {
        synchronized ( syncToken ) {
            resetRollingWindowValues
        }
    }
}

// ADD DATABASE ACCESS
