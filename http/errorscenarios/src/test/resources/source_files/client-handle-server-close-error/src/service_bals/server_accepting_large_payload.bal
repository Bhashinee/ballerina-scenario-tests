import ballerina/http;
import ballerina/io;
import ballerina/log;
import ballerina/kubernetes;

@kubernetes:Ingress {
    hostname:"ballerina.service.io",
    name:"http-service",
    path:"/"
}
@kubernetes:Service {
    serviceType:"NodePort",
    name:"http-service"
}

listener http:Listener listener1= new(9000);

@kubernetes:Deployment {
    image: "ballerina.service.io/http-service:v1.0",
    name: "http-service"
}

service receiver on listener1 {
    resource function receiveLargePayload(http:Caller caller, http:Request request) {
        var payload = request.getByteChannel();
            if (payload is io:ReadableByteChannel) {
            io:WritableByteChannel destinationChannel = <@untainted io:WritableByteChannel>
                                    io:openWritableFile("files/xyz.mp4");
            var result = copy(payload, destinationChannel);
            if (result is error) {
                log:printError("error occurred while performing copy ", err = result);
            }
            close(payload);
            close(destinationChannel);
            error? respond = caller->respond("Success");
        } else {
            log:printError("Error in parsing byte channel :", err = payload);
        }
    }
}

function copy(io:ReadableByteChannel src, io:WritableByteChannel dst)
                returns error? {
    while (true) {
        byte[] | io:Error result = src.read(1000);
        if (result is io:EofError) {
            break;
        } else if (result is error) {
            return <@untained> result;
        } else {
            int i = 0;
            while (i < result.length()) {
                var result2 = dst.write(result, i);
                if (result2 is error) {
                    return result2;
                } else {
                    i = i + result2;
                }
            }
        }
    }
    return;
}

function close(io:ReadableByteChannel|io:WritableByteChannel ch) {
    abstract object {
        public function close() returns error?;
    } channelResult = ch;
    var cr = channelResult.close();
    if (cr is error) {
        log:printError("Error occurred while closing the channel: ", err = cr);
    }
}