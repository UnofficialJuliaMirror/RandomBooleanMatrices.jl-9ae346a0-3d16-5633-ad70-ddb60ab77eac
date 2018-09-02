module RandomBooleanMatrices

using Random
using RandomNumbers.Xorshifts
using SparseArrays
using StatsBase

include("curveball.jl")

@enum matrixrandomizations curveball

"""
    randomize_matrix!(m; method = curveball)

Randomize the sparse boolean Matrix `m` while maintaining row and column sums
"""
function randomize_matrix!(m, rng = Random.GLOBAL_RNG; method::matrixrandomizations = curveball)
    if method == curveball
        return _curveball!(m, rng)
    end
    error("undefined method")
end

struct MatrixGenerator{R<:AbstractRNG}
    m::SparseMatrixCSC{Bool, Int}
    method::matrixrandomizations
    rng::R
end

"""
    random_matrices(m [,rng]; method = curveball)

Create a matrix generator function that will return a random boolean matrix
every time it is called, maintaining row and column sums. Non-boolean input
matrix are interpreted as boolean, where values != 0 are `true`.

# Examples
```
m = rand(0:4, 5, 6)
rmg = random_matrices(m)

random1 = rmg()
random2 = rmg()
``
"""
random_matrices(m::AbstractMatrix, rng = Xoroshiro128Plus(); method::matrixrandomizations = curveball) =
    MatrixGenerator{typeof(rng)}(dropzeros!(sparse(m)), method, rng)
random_matrices(m::SparseMatrixCSC{Bool, Int}, rng = Xoroshiro128Plus(); method::matrixrandomizations = curveball) =
    MatrixGenerator{typeof(rng)}(dropzeros(m), method, rng)

(r::MatrixGenerator)(; method::matrixrandomizations = curveball) = copy(randomize_matrix!(r.m, r.rng, method = r.method))

export randomize_matrix!, random_matrices
export curveball

end
