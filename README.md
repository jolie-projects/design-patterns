# Design Patterns

## Circuit Breaker

Running the circuit breaker can be accomplished by running *circuitbreaker.ol* and *mock_service.ol*. Running *mock_client.ol* or *mock_client_one_request.ol* will send requests through the circuitbreaker.

Current issues invovle exceptions including:

Connection Reset By Peer
java.net.SocketException: Invalid argument

Due to the way Jolie handles certain exceptions, these are not caught by the default scope, which means failure haven't been produced when running the circuitbreaker, timeouts, however, has. These can occur when overloading the circuit breaker by continuous request (tested with about 750 requests at once), from where the circuit breaker has gone from Closed to Open, to Half-Open and back to Closed again for proper functionality.

## TODOS

1. When _ext_ keyword is implemented, make the circuit breaker generic so it can be added to a project, needing only modifications to a *CB_Config.col*-file.
2. Synchronize blocks that change CB-state to avoid race conditions.
