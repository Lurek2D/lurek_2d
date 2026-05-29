describe("learning_route_attention_lab", function()
    it("runs deterministic conv-pool-attention-transformer pipeline", function()
        local risk_grid = {
            0.10, 0.35, 0.22, 0.40,
            0.60, 0.80, 0.15, 0.30,
            0.05, 0.28, 0.95, 0.42,
            0.33, 0.18, 0.25, 0.12,
        }

        local route_sequence = {
            1.0, 0.0, 0.0, 0.0,
            0.8, 0.2, 0.0, 0.0,
            0.5, 0.4, 0.1, 0.0,
        }

        local memory_sequence = {
            0.6, 0.1, 0.1, 0.2,
            0.2, 0.6, 0.1, 0.1,
            0.1, 0.2, 0.5, 0.2,
        }

        local conv = lurek.learning.newConv2D(1, 1, 1, 1, 1, 1, 0, 0)
        local pool = lurek.learning.newMaxPool2D(2, 2, 2, 2)
        local pe = lurek.learning.newPositionalEncoding(4, 16)
        local mha = lurek.learning.newMultiHeadAttention(4, 2)
        local enc = lurek.learning.newTransformerEncoder(4, 2, 8)
        local dec = lurek.learning.newTransformerDecoder(4, 2, 8)

        local risk_tensor = lurek.learning.newTensor({1, 4, 4}, risk_grid)
        local route_tensor = lurek.learning.newTensor({3, 4}, route_sequence)
        local memory_tensor = lurek.learning.newTensor({3, 4}, memory_sequence)

        local pooled_map = pool:forward(conv:forward(risk_tensor))
        local context = enc:forward(mha:forward(pe:apply(route_tensor)))
        local decoded = dec:forward(context, memory_tensor)

        local pooled_shape = pooled_map:shape()
        local decoded_shape = decoded:shape()

        expect_equal(pooled_shape[1], 1)
        expect_equal(pooled_shape[2], 2)
        expect_equal(pooled_shape[3], 2)
        expect_equal(decoded_shape[1], 3)
        expect_equal(decoded_shape[2], 4)
    end)
end)

test_summary()
