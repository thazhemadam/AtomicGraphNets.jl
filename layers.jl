using Flux
using Flux: glorot_uniform
using Flux: @functor
using GeometricFlux

struct CGCNConv{T,F}
    selfweight::Array{T,2}
    convweight::Array{T,2}
    bias::Array{T,2}
    σ::F
end

"""
    CGCNConv(in=>out)
    CGCNConv(in=>out, σ)

Crystal graph convolutional layer. Almost identical to GCNConv from GeometricFlux but adapted to be most similar to Tian's original CGCNN structure, so explicitly has self and convolutional weights separately. Default activation function is softplus.

# Arguments
- `in::Integer`: the dimension of input features.
- `out::Integer`: the dimension of output features.
- `σ::F=softplus`: activation function
- `bias::Bool=true`: keyword argument, whether to learn the additive bias.
"""
function CGCNConv(ch::Pair{<:Integer,<:Integer}, σ=softplus; init=glorot_uniform, T::DataType=Float32, bias::Bool=true)
    selfweight = init(ch[2], ch[1])
    convweight = init(ch[2], ch[1])
    b = bias ? init(ch[2], 1) : zeros(T, ch[2], 1)
    CGCNConv(selfweight, convweight, b, σ) # don't add identity in here because we're doing self weight separately
end

@functor CGCNConv

# TODO here: in the case of chaining multiple of these layers together, should make a way to pass laplacian through so it doesn't have to get computed each time (maybe some kind of flag to specify which is being given?)
"""
 Define action of layer on inputs: do a graph convolution, add this (weighted by convolutional weight) to the features themselves (weighted by self weight) and the per-feature bias (concatenated to match number of nodes in graph).

# Arguments
- input: tuple of input data (stored in (# features, # nodes) order) and adjacency matrix of the graph
"""
# tuple input
#(l::CGCNConv)(input::Tuple{Array{Bool,2},SparseMatrixCSC{Float32,Int64}}) = l.σ.(l.convweight * input[1] * normalized_laplacian(input[2], Float32) + l.selfweight * input[1] + hcat([l.bias for i in 1:size(input[2], 1)]...)), input[2]

# testing without bias
(l::CGCNConv)(input::Tuple{Array{Bool,2},SparseMatrixCSC{Float32,Int64}}) = l.σ.(l.convweight * input[1] * normalized_laplacian(input[2], Float32) + l.selfweight * input[1]), input[2]

# two inputs rather than tuple
#(l::CGCNConv)(input::Array{Bool,2}, adj::SparseMatrixCSC{Float32,Int64}) = l.σ.(l.convweight * input * normalized_laplacian(adj, Float32) + l.selfweight * input + hcat([l.bias for i in 1:size(adj, 1)]...))

# two inputs, no bias, only returning matrix for now
#(l::CGCNConv)(input::Array{Bool,2}, adj::SparseMatrixCSC{Float32,Int64}) = l.σ.(l.convweight * input * normalized_laplacian(adj, Float32) + l.selfweight * input)