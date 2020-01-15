httpRequest = {
    start = nil,
    header = nil,
    body = nil,
}
httpRequest.__index = httpRequest;

function httpRequest.new(requestRaw)
    local self = setmetatable(dofile("httpRequest_parser.lua")(requestRaw), httpRequest);

    return self;
end

function httpRequest:remove()
    if self.start then
       self.start.method = nil;
       self.start.uri = nil;
       self.start.version = nil;

        for name, value in pairs(self.start.query) do
            table.remove(self.start.query, 1);
        end
    end

    if self.header then
        for name, value in pairs(self.header) do
            table.remove(self.header, 1);
        end
    end

    self.body = nil;

    collectgarbage();
end