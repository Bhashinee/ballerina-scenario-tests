import ballerina/http;
import ballerina/kubernetes;
import ballerina/log;
import ballerina/runtime;

// ****************************************************
//                  BACKEND SERVICE                   *
// ****************************************************

@kubernetes:Service {
    serviceType: "NodePort"
}
@kubernetes:Ingress {
	hostname: "resiliency.backend"
}
listener http:Listener http1Listener= new(10300);

int count = 0;
string servicePrefix = "[Http1Service] ";

@kubernetes:Deployment {
    image: "cb_with_retry_backend:v1.0",
    imagePullPolicy: "Always"
}
@http:ServiceConfig {
    basePath: "/"
}
service Http1Service on http1Listener {
    @http:ResourceConfig {
        methods: ["GET"]
	}
    resource function getResponse(http:Caller caller, http:Request req) {
        count += 1;
        log:printInfo(servicePrefix + "Request received. Request count: " + count.toString());
        http:Response response = new;
        int decider = count % 4;
        if (decider == 1) {
            // Imitate delayed response, so that the timeout occurs at the client
            runtime:sleep(5000);
            sendErrorResponse(caller, response, servicePrefix);
        } else if (decider == 2) {
            // Sending "501_INTERNAL_SERVER_ERROR" to imitate server failures
            sendErrorResponse(caller, response, servicePrefix);
        // We need two OK responses to switch back circuit-breaker client to closed-circuit state.
        } else if (decider == 3 || decider == 0) {
            sendNormalResponse(caller, response, servicePrefix);
        }
    }
}

function sendNormalResponse(http:Caller caller, http:Response response, string prefix) {
    string message = prefix + "OK response. Backend request count: " + count.toString();
    response.setPayload(message);
    var result = caller->respond(response);
    handleResult(result);
}

function sendErrorResponse(http:Caller caller, http:Response response, string prefix) {
    response.statusCode = 501;
    response.setPayload(prefix + "Internal error occurred. Backend request count: " + count.toString());
    var result = caller->respond(response);
}

public function handleResult(error? result) {
    if (result is error) {
        log:printError(servicePrefix + "Error occurred while sending the response", result);
    } else {
        log:printInfo(servicePrefix + "Response sent successfully\n");
    }
}
