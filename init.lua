dofile("http.lua");

server = httpServer.new(80);

server:start();

server:routeInsert(".*", function(response, request)
    print("file streaming");

    response:sendFile(200, request.start.uri:gsub("/", "_"));
end);