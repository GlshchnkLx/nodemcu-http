function urlDecode(url)
    return url:gsub('%%(%x%x)', function(x)
        return string.char(tonumber(x, 16))
    end)
end

return function(raw)
    local request = {}
    
    request._start, request._header, request.body = raw:match("([^\n]+)\n(.*)\r\n(.*)");
    
    if request._start then
        request.start = {}
        request.start.method, request.start.uri, request.start.version = 
        request._start:match("(%w+)%s+([%w%p]+)%sHTTP/(.*)");
        
        request.start.uri, request.start._query = request.start.uri:match("([^?]+)?*(.*)");
        request.start._query = urlDecode(request.start._query);
        request.start.query = {};
    
        for option, value in request.start._query:gmatch("([^&]+)=([^&]*)&*") do
            request.start.query[option] = value;
        end
    
        request.start._query = nil;
        request._start = nil;
    end
    
    if request._header then
        request.header = {};
        for line in request._header:gmatch("([^\r]+)\r\n") do
            local name, value = line:match("([^:]+):%s*(.*)");
            if name and value then
                request.header[name] = value;
            end
        end
    
        request._header = nil;
    end

    return request;
end