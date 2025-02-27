export FourierTransform

struct FourierTransform{N, S} <: AbstractTransform
    modes::NTuple{N, S} # N == ndims(x)
end

Base.ndims(::FourierTransform{N}) where {N} = N
Base.eltype(::Type{FourierTransform}) = ComplexF32

function transform(ft::FourierTransform, 𝐱::AbstractArray)
    return rfft(Zygote.hook(real, 𝐱), 1:ndims(ft)) # [size(x)..., in_chs, batch]
end

function low_pass(ft::FourierTransform, 𝐱_fft::AbstractArray)
    return view(𝐱_fft, map(d -> 1:d, ft.modes)..., :, :) # [ft.modes..., in_chs, batch]
end

truncate_modes(ft::FourierTransform, 𝐱_fft::AbstractArray) = low_pass(ft, 𝐱_fft)

function inverse(ft::FourierTransform, 𝐱_fft::AbstractArray{T, N},
                 M::NTuple{N, Int64}) where {T, N}
    return real(irfft(𝐱_fft, M[1], 1:ndims(ft))) # [size(x_fft)..., out_chs, batch]
end
