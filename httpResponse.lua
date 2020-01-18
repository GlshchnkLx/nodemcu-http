httpResponse = {
    connection = nil,
};
httpResponse.__index = httpResponse;

function httpResponse.new(connection)
    local self = setmetatable({
        connection = connection,
    }, httpResponse);

    return self;  
end

function httpResponse:remove()
    self.connection:on('sent', function() end) -- release closures context
    self.connection:on('receive', function() end)
    self.connection:close();
    self.connection = nil;
end


function httpResponse:sendHeader(status, header)
    status = status or 200;
    header = header or {};

    local data = string.format("HTTP/1.1 %s\r\nCache-Control: no-cache\r\n%s\r\n\r\n",
        status,
        table.concat(header, "\r\n")
    );

    self.connection:send(data);
end


function httpResponse:sendBody(status, header, body)
    self:sendHeader(status, header); 

    self.connection:on('sent', function()
        self.connection:send(body);
        self:remove();
    end)
end

function httpResponse:sendFile(status, filename)
    if not file.exists(filename) then
        if filename == "404.html" then
            self:sendBody(404, {
                "Content-Type: text/html", "Connection: close",
            }, "404");
        else
            self:sendFile(404, "404.html");
        end

        file.close();
        return false;
    end

    self:sendHeader(status, {
        "Content-Type: text/html", "Connection: close"
    }); 

    local _file = file.open(filename,"r");
    local cursor = 0;
    self.connection:on('sent', function()
        if _file:seek("set", cursor) then
            cursor = cursor + 1024;
            self.connection:send(_file:read(1024));
        else
            file:close();
            self:remove();
        end
    end)
end
