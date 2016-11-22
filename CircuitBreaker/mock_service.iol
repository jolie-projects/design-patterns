type MockRequest:void {
    .content:string
}

type MockResponse:void {
    .content:string
}

interface MockServiceIface {
    RequestResponse:
        req( MockRequest )( MockResponse )
}
