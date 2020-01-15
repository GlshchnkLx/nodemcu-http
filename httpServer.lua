httpServer = {
    port = nil,
    tcpServer = nil,
    tcpSocket = nil,
    routes = nil,
};
httpServer.__index = httpServer;

function httpServer.new(port)
    port = tonumber(port or '') or 80;

    local self = setmetatable({
        port = port,
        tcpServer = net.createServer(net.TCP),
        tcpSocket = nil,
        routes = {},
    }, httpServer);

    return self;
end

function httpServer:remove()
    if self.port then
        self.port = nil
    end
    
    if self.tcpServer then 
        self.tcpServer:close();
        self.tcpServer = nil;
    end

    if self.tcpSocket then 
        self.tcpSocket:close();
        self.tcpSocket = nil;
    end

    if self.routes then
        for index = 1, #self.routes do
            table.remove(self.routes, 1);
        end
    end

    collectgarbage();
end


function httpServer:start()
    if not self.port then
        print("httpd.start:", "not changed port");
        return false, -1;
    end

    if not self.tcpServer then
        print("httpd.start:", "server not exist");
        return false, -2;
    end

    if self.tcpSocket then
        print("httpd.start:", "socket exist");
        return false, -3;
    end
    
    self.tcpServer:listen(self.port, function(tcpSocket)
        self.tcpSocket = tcpSocket;

        tcpSocket:on('receive', function(responseRaw, requestRaw)
            local response = httpResponse.new(responseRaw);
            local request = httpRequest.new(requestRaw);

            for routeIndex, routeObject in pairs(self.routes or {}) do
                if request.start.uri:find(routeObject.uri) and routeObject.callback then
                    routeObject.callback(response, request);
                    break;
                end
            end

            request:remove();
        end);
    end);
end

function httpServer:stop()
    if self.tcpSocket then
        self.tcpSocket:on('sent', function() end);
        self.tcpSocket:on('receive', function() end);
        self.tcpSocket:close();
    end

    if self.tcpServer then
        self.tcpServer:close();
        self.tcpServer = nil;
    end
end


function httpServer:routeInsert(uri, callback)
    self:routeRemove(uri);
    
    table.insert(self.routes, 1, {
        uri = uri,
        callback = callback,
    });
end

function httpServer:routeRemove(uri)
    for routeIndex = #self.routes, 1, -1 do
        local routeObject = self.route[routeIndex];

        if request.starting.uri:find(routeObject.uri) then
            table.remove(self.routes, routeIndex);
        end
    end
end
