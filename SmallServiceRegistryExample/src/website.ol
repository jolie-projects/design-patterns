include "console.iol"
include "file.iol"
include "string_utils.iol"
include "Service_Registry.iol"

execution{ concurrent }

constants {
    rootFolder = "www/",
    tableHeader = "<table class='ui celled table'>
                  <thead>
                    <tr>
                      <th>Servicename</th>
                      <th>Location</th>
                      <th>Protocol</th>
                      <th>Interface</th>
                      <th>Documentation</th>
                    </tr>
                  </thead>
                  <tbody>",
    tableFooter = "</tbody></table>"
}

interface WebsiteInterface {
    RequestResponse:
        default( undefined )( undefined ),
        searchByName( undefined )( undefined ),
        about( undefined )( undefined ),
        getInterfaceFile( undefined )( undefined ),
        getServiceDocFile( undefined )( undefined),
        shutdown( void )( void )
    OneWay:
        // NONE
}

inputPort WebsitePort {
    Location: "socket://localhost:8000"
    Protocol: http { .format -> format; .contentType -> mime; .default = "default"; .contentDisposition -> contentDisposition }
    Interfaces: WebsiteInterface
}

init {
    println@Console( "Starting" )()
}

main {
    [ default( request )( response )
    {
        format = "html";
        println@Console( request.operation )();
        contains@StringUtils( request.operation { .substring = ".." } )( reversePathTraversal );
        if (request.operation == "" || reversePathTraversal )
        {
            request.operation = "index.html"
        };
        exists = false;
        if ( reversePathTraversal == false ) {
            exists@File( rootFolder + operation.request )( exists )
        };

        if (!exists)
        {
            request.operation = "index.html"
        };
        readFile@File( { .filename = rootFolder + request.operation } )( response )
    }]
    [ searchByName( request )( response ) {
        println@Console( request.query )();
        queryServices@ServiceRegistry( request.query )( queryResult );
        response.msg = tableHeader;
        for (i = 0, i < #queryResult.row, i++) {
            with ( queryResult.row[i] ) {
                response.msg += "<tr>
                                  <td>" + .Name + "</td>
                                  <td>" + .Location + "</td>
                                  <td>" + .Protocol + "</td>
                                  <td>
                                    <button class='ui primary button downloadButton'>
                                        <a href='getInterfaceFile?query=" + .Name + "' target='_blank'>Download Interface</a>
                                    </button>
                                  </td>
                                  <td>
                                   <button class='ui secondary button downloadButton'>
                                        <a href='getServiceDocFile?query=" + .Name + "' target='_blank'>Show Documentation</a>
                                   </td>
                                 </tr>"
            }
        };
        response.msg += tableFooter
    }]
    [ getInterfaceFile( request )( response ) {
        contentDisposition = "attachment; filename=\"" + request.query + ".iol\"";
        format = "raw";
        mime = "application/x-jolie-interface";
        getServiceInterface@ServiceRegistry( request.query )( response )
    }]
    [ getServiceDocFile( request )( response ) {
        format = "html";
        getServiceDocFile@ServiceRegistry( request.query )( response )
    }]
    [ about( )( response ) {
        readFile@File( { .filename = rootFolder + "about" } )( res );
        response.msg = response
    }]
    [ shutdown( )( ) {
        exit
    }]
}
