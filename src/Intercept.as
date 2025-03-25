// // c 2025-03-20
// // m 2025-03-21

const string CYAN     = "\\$0FD";
const string DARKGRAY = "\\$777";  // trace
const string DARKRED  = "\\$A00";
const string GREEN    = "\\$0F6";
const string ORANGE   = "\\$FA0";
const string RESET    = "\\$G";

// namespace Interceptor {
//     namespace Http {
//         bool Get(CMwStack &in stack, CMwNod@ nod) {
//             print(GREEN + "============== Http Get ==============");

//             // string headers;
//             // string url;
//             // bool   useCache;

//             // int available = stack.Count() - stack.Index() - 1;
//             // print("available: " + available);

//             // switch (available) {
//             //     case 1:
//             //         print("url: " + stack.CurrentString(0));
//             //         url = stack.CurrentString(0);

//             //         break;

//             //     case 2:
//             //         print("url: " + stack.CurrentString(1));
//             //         url = stack.CurrentString(0);

//             //         print("useCache: " + stack.CurrentBool(0));
//             //         useCache = stack.CurrentBool(0);

//             //         break;

//             //     case 3:
//             //         print("url: " + stack.CurrentString(2));
//             //         url = stack.CurrentString(2);

//             //         print("useCache: " + stack.CurrentBool(1));
//             //         useCache = stack.CurrentBool(1);

//             //         print("headers: " + stack.CurrentString(0).Replace("\n", "\\n"));
//             //         headers = stack.CurrentString(0);

//             //         break;

//             //     default:;
//             // }

//             // if (requests.Length > 0) {
//             //     if (url.Length > 0) {
//             //         HttpRequest@ latest = requests[requests.Length - 1];
//             //         if (latest.url == url) {
//             //             latest.headers = headers;
//             //             latest.useCache = useCache;
//             //         } else
//             //             warn("latest request error: " + url);
//             //     }
//             // } else
//             //     warn("no requests");

//             CNetScriptHttpManager@ Mgr = cast<CNetScriptHttpManager@>(nod);
//             if (Mgr !is null) {
//                 // print("reqs: " + Mgr.Requests.Length + ", pend: " + Mgr.PendingEvents.Length);

//                 for (uint i = 0; i < Mgr.Requests.Length; i++) {
//                     CNetScriptHttpRequest@ req = Mgr.Requests[i];
//                     if (req !is null) {
//                         // print(ORANGE + "req: " + req.StatusCode + ", " + string(req.Result).Replace("\n", "\\n"));

//                         HttpRequest@ request = HttpRequest(req);
//                         bool dupe = false;

//                         for (int j = requests.Length - 1; j >= 0; j--) {
//                             if (requests[j].id.Value == request.id.Value) {
//                                 dupe = true;
//                                 break;
//                             }
//                             if (Time::Stamp - requests[j].sentAt > 60)
//                                 break;
//                         }

//                         if (dupe) {
//                             // warn("already have req: " + request.url);
//                         } else if (capturing) {
//                             print("adding req: " + request.url);
//                             requests.InsertLast(@request);
//                         }

//                     } else
//                         warn("null req");
//                 }

//                 for (uint i = 0; i < Mgr.PendingEvents.Length; i++) {
//                     CNetScriptHttpEvent@ event = Mgr.PendingEvents[i];
//                     if (event !is null) {
//                         print(ORANGE + "event: " + event.IdName);
//                     } else
//                         warn("null event");
//                 }
//             }

//             return true;
//         }

//         void Init() {
//             // try { Dev::InterceptProc("CNetScriptHttpManager", "CreateGet",      Get);  } catch { warn("failed to intercept get requests");      }
//             // try { Dev::InterceptProc("CNetScriptHttpManager", "CreateGet2",     Get);  } catch { warn("failed to intercept get2 requests");     }
//             try { Dev::InterceptProc("CNetScriptHttpManager", "CreateGet3",     Get);  } catch { warn("failed to intercept get3 requests");     }
//             // try { Dev::InterceptProc("CNetScriptHttpManager", "CreatePost",     Post); } catch { warn("failed to intercept post requests");     }
//             // try { Dev::InterceptProc("CNetScriptHttpManager", "CreatePost2",    Post); } catch { warn("failed to intercept post2 requests");    }
//             // try { Dev::InterceptProc("CNetScriptHttpManager", "CreatePostFile", Post); } catch { warn("failed to intercept postfile requests"); }
//             // try { Dev::InterceptProc("CNetScriptHttpManager", "CreatePut",      Put);  } catch { warn("failed to intercept put requests");      }
//         }

//         bool Post(CMwStack &in stack, CMwNod@ nod) {
//             print(GREEN + "============== Http Post =============");

//             CNetScriptHttpManager@ Mgr = cast<CNetScriptHttpManager@>(nod);
//             if (Mgr !is null) {
//                 print("reqs: " + Mgr.Requests.Length + ", pend: " + Mgr.PendingEvents.Length);

//                 for (uint i = 0; i < Mgr.Requests.Length; i++) {
//                     CNetScriptHttpRequest@ req = Mgr.Requests[i];
//                     if (req !is null) {
//                         print(ORANGE + "req: " + req.StatusCode + ", " + string(req.Result).Replace("\n", "\\n"));

//                         if (requests.FindByRef(req) == -1)
//                             requests.InsertLast(@req);
//                     }
//                 }

//                 for (uint i = 0; i < Mgr.PendingEvents.Length; i++) {
//                     CNetScriptHttpEvent@ event = Mgr.PendingEvents[i];
//                     if (event !is null) {
//                         print(ORANGE + "event: " + event.IdName);
//                     }
//                 }
//             }

//             int available = stack.Count() - stack.Index() - 1;
//             print("available: " + available);

//             ;

//             return true;
//         }

//         bool Put(CMwStack &in stack, CMwNod@ nod) {
//             print(GREEN + "============== Http Put ==============");

//             CNetScriptHttpManager@ Mgr = cast<CNetScriptHttpManager@>(nod);
//             if (Mgr !is null) {
//                 print("reqs: " + Mgr.Requests.Length + ", pend: " + Mgr.PendingEvents.Length);

//                 for (uint i = 0; i < Mgr.Requests.Length; i++) {
//                     CNetScriptHttpRequest@ req = Mgr.Requests[i];
//                     if (req !is null) {
//                         print(ORANGE + "req: " + req.StatusCode + ", " + string(req.Result).Replace("\n", "\\n"));

//                         if (requests.FindByRef(req) == -1)
//                             requests.InsertLast(@req);
//                     }
//                 }

//                 for (uint i = 0; i < Mgr.PendingEvents.Length; i++) {
//                     CNetScriptHttpEvent@ event = Mgr.PendingEvents[i];
//                     if (event !is null) {
//                         print(ORANGE + "event: " + event.IdName);
//                     }
//                 }
//             }

//             int available = stack.Count() - stack.Index() - 1;
//             print("available: " + available);

//             ;

//             return true;
//         }

//         void Reset() {
//             try { Dev::ResetInterceptProc("CNetScriptHttpManager", "CreateGet");      } catch { }
//             try { Dev::ResetInterceptProc("CNetScriptHttpManager", "CreateGet2");     } catch { }
//             try { Dev::ResetInterceptProc("CNetScriptHttpManager", "CreateGet3");     } catch { }
//             try { Dev::ResetInterceptProc("CNetScriptHttpManager", "CreatePost");     } catch { }
//             try { Dev::ResetInterceptProc("CNetScriptHttpManager", "CreatePost2");    } catch { }
//             try { Dev::ResetInterceptProc("CNetScriptHttpManager", "CreatePostFile"); } catch { }
//             try { Dev::ResetInterceptProc("CNetScriptHttpManager", "CreatePut");      } catch { }
//         }
//     }
// }
