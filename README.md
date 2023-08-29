# Motoko Certified Assets

Designed to answer HTTP cert calls and certify assets

Started from certified-http fork.

Similar to how certified-cache works, but it's stable and doesn't store the files, only their certificates.

You handle file storage yourself.

## Installation

`mops install motoko-certified-assets`

### Run the included demo

- Clone repo
- Run `mops install`
- Make sure your dfx is running - `dfx start --clean -v`
- Deploy demo canister - `dfx deploy`
- Open Candid interface - i.e. `http://127.0.0.1:4943/?canisterId=bd3sg-teaaa-aaaaa-qaaba-cai&id=bkyz2-fmaaa-aaaaa-qaaaq-cai`
- Create a url entry to certify calling upload method. For example enter `/hello` in both fields.
- Visit your certified url - i.e. `http://bkyz2-fmaaa-aaaaa-qaaaq-cai.localhost:4943/hello`
- Open Network console and look into the headers response. You should see an Ic-Certificate like the shot below

![certified-http-shot](https://github.com/fermartz/motoko-certified-assets/blob/main/certified-http.png)


### Sample code for demo shown above
```mo

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

```

Advanced - hashing chunks when you receive them

```mo
          switch(cmd) {
                case(#store({key; val})) {
                    assert(val.chunks > 0);

                    // Allows uploads of large certified files.
                    cert.chunkedStart(key, val.chunks, val.content, func(content: [Blob]) {
                        // when done

                        // Insert the file in your store (Use your own store)
                        assets.db.insert({
                            id= key;
                            chunks= val.chunks;
                            content= content;
                            content_encoding= val.content_encoding;
                            content_type = val.content_type;
                        });
                    });

                };

                 case(#store_chunk(x)) {
                    cert.chunkedSend(x.key, x.chunk_id, x.content);
                };
          }
```

# Credits

- [Certified Http](https://github.com/infu/certified-http)
- [IC Certification](https://github.com/nomeata/ic-certification)
- [StableHashMap](https://github.com/canscale/StableHashMap#master)
- [Motoko Sha](https://github.com/enzoh/motoko-sha#master)