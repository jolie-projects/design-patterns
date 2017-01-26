type RegisterRequest:void {
    .protocol:string
    .location:string
    .serviceName:string
    .interfacefile:string
    .docFile:string
}

type DeregisterRequest:void {
    .id:long
}
