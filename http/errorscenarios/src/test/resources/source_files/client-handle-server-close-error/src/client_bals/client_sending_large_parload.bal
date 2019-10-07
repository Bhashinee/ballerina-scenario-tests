import ballerina/http;
import ballerina/io;
import ballerina/kubernetes;

@kubernetes:Ingress {
    hostname:"ballerina.client.io",
    name:"http-client",
    path:"/"
}
@kubernetes:Service {
    serviceType:"NodePort",
    name:"http-client"
}

listener http:Listener listener2= new(9090);

@kubernetes:Deployment {
    image: "ballerina.client.io/http-client:v1.0",
    name: "http-client",
    copyFiles: [{ target: "/home", sourceFile: "/home/testFile" }],
    username:"<USERNAME>",
    password:"<PASSWORD>",
    push:true,
    imagePullPolicy:"Always"
}
service baseService on listener2 {
    resource function sendLargePayload(http:Caller caller, http:Request request) {
        http:Client jpgEnpoint = new ("http://http-service:9000/receiver/receiveLargePayload");
        io:println("Started");

        http:Request mp4file = new();
        mp4file.setFileAsPayload("../../../testFile");
        var response = jpgEnpoint->post("/", mp4file);

        if (response is http:Response) {
            var payload = response.getTextPayload();
            if (payload is error) {
                io:println(payload.detail());
            } else {
                io:println(payload);
            }
        } else {
            io:println(response);
        }
        var res = caller->respond(response.toString());
    }
}