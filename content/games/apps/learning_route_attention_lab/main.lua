local app = {
    ready = false,
    report = {},
}

local RISK_GRID = {
    0.10, 0.35, 0.22, 0.40,
    0.60, 0.80, 0.15, 0.30,
    0.05, 0.28, 0.95, 0.42,
    0.33, 0.18, 0.25, 0.12,
}

local ROUTE_SEQUENCE = {
    1.0, 0.0, 0.0, 0.0,
    0.8, 0.2, 0.0, 0.0,
    0.5, 0.4, 0.1, 0.0,
}

local MEMORY_SEQUENCE = {
    0.6, 0.1, 0.1, 0.2,
    0.2, 0.6, 0.1, 0.1,
    0.1, 0.2, 0.5, 0.2,
}

local function run_route_pipeline()
    local conv = lurek.learning.newConv2D(1, 1, 1, 1, 1, 1, 0, 0)
    local pool = lurek.learning.newMaxPool2D(2, 2, 2, 2)
    local pe = lurek.learning.newPositionalEncoding(4, 16)
    local mha = lurek.learning.newMultiHeadAttention(4, 2)
    local enc = lurek.learning.newTransformerEncoder(4, 2, 8)
    local dec = lurek.learning.newTransformerDecoder(4, 2, 8)

    local risk_tensor = lurek.learning.newTensor({1, 4, 4}, RISK_GRID)
    local route_tensor = lurek.learning.newTensor({3, 4}, ROUTE_SEQUENCE)
    local memory_tensor = lurek.learning.newTensor({3, 4}, MEMORY_SEQUENCE)

    local conv_map = conv:forward(risk_tensor)
    local pooled_map = pool:forward(conv_map)
    local encoded_route = pe:apply(route_tensor)
    local attended_route = mha:forward(encoded_route)
    local encoded_context = enc:forward(attended_route)
    local decoded_route = dec:forward(encoded_context, memory_tensor)

    local pooled_shape = pooled_map:shape()
    local route_shape = decoded_route:shape()
    local pooled_data = pooled_map:data()

    return {
        string.format("pooled_shape=%dx%dx%d", pooled_shape[1], pooled_shape[2], pooled_shape[3]),
        string.format("route_shape=%dx%d", route_shape[1], route_shape[2]),
        string.format("max_risk_tile=%0.2f", pooled_data[3]),
    }
end

function lurek.init()
    app.report = run_route_pipeline()
    for _, line in ipairs(app.report) do
        print("[learning_route_attention_lab] " .. line)
    end
    app.ready = true
end

function lurek.process(_dt)
end

function lurek.draw()
end
