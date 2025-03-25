// c 2025-03-20
// m 2025-03-20

// HttpRequest@[] requests;

// enum HttpMethod {
//     Get,
//     Post,
//     Put
// }

// class HttpRequest {
//     string       filename;
//     string       headers;
//     MwId         id;
//     HttpMethod   method     = HttpMethod::Get;
//     Json::Value@ parsed;
//     string       resource;
//     string       result;
//     int64        sentAt     = -1;
//     int          statusCode = -1;
//     string       url;
//     bool         useCache   = false;

//     // HttpRequest() { }
//     HttpRequest(CNetScriptHttpRequest@ scriptReq) {
//         id         = scriptReq.Id;
//         result     = string(scriptReq.Result);
//         sentAt     = Time::Stamp;
//         statusCode = scriptReq.StatusCode;
//         url        = scriptReq.Url;

//         try {
//             @parsed = Json::Parse(result);
//         } catch {
//             warn("can't parse result: " + result);
//         }
//     }
// }
