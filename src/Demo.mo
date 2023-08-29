import Blob "mo:base/Blob";
import CertifiedHttp "./Cert";
import HTTP "./Http";
import HashMap "mo:base/HashMap";
import Text "mo:base/Text";
import Debug "mo:base/Debug";
import Map "mo:map/Map";


actor {

    type HttpRequest = HTTP.HttpRequest;
    type HttpResponse = HTTP.HttpResponse;

    let { thash; } = Map;

    stable var fields = Map.new<Text, Blob>(thash);
    stable var cert_store = CertifiedHttp.init();

    var cert = CertifiedHttp.CertifiedHttp(cert_store);

    public shared func upload(key: Text, val: Text) {
        let blob : Blob = Text.encodeUtf8(val);
        Map.set(fields, thash, key, blob);
        cert.put(key, blob);
    };

    public shared func delete(key: Text) {
        Map.delete(fields, thash, key);
        cert.delete(key);
    };


    public query func http_request(req : HttpRequest) : async HttpResponse {
        let ?body = Map.get(fields, thash, req.url) else return e404;
        Debug.print(debug_show(req.url));

        {
        status_code : Nat16 = 200;
        headers = [("content-type", "text/html"), cert.certificationHeader(req.url)];
        body = body;
        streaming_strategy = null;
        upgrade = null;
        };
    

    };

    let e404:HttpResponse = {
          status_code = 404;
          headers = [];
          body = "Error 404":Blob;
          streaming_strategy = null;
          upgrade = ?false;
    };
    

    public func addText(item: Text): async () {
        Map.set(fields, thash, item, Text.encodeUtf8(item));
    };

    public query func getEntries(): async [(Text, Blob)] {
        Map.toArray(fields)
    };
    
    public query func getOne(k: Text): async ?Blob {
        // let x : ?Blob = switch(Map.get(fields, thash, k)){
        //     case null { ?Text.encodeUtf8("null") };
        //     case(?v){ ?v }
        // };
        // x
        Map.get(fields, thash, k)
        
    };

   

    public func textToBlob(item: Text): async Blob {
        Debug.print(debug_show(Text.encodeUtf8(item)));
        Text.encodeUtf8(item);
    };
    
        
    public query func hello() : async Text {
        "hello there"
    };


}