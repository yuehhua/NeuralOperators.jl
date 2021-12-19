struct SparseKernel1d{T,S}
    k::Int
    conv_blk::S
    out_weight::T
end

function SparseKernel1d(k::Int, c::Int=1; init=Flux.glorot_uniform)
    input_dim = c*k
    emb_dim = 128
    conv = Conv((3,), input_dim=>emb_dim, relu; stride=1, pad=1, init=init)
    W_out = Dense(emb_dim, input_dim; init=init)
    return SparseKernel1d(k, conv, W_out)
end

function (l::SparseKernel1d)(X::AbstractArray)
    X_ = l.conv_blk(batched_transpose(X))
    Y = l.out_weight(batched_transpose(X_))
    return Y
end


# class MWT_CZ1d(nn.Module):
#     def __init__(self,
#                  k = 3, alpha = 5,
#                  L = 0, c = 1,
#                  base = 'legendre',
#                  initializer = None,
#                  **kwargs):
#         super(MWT_CZ1d, self).__init__()
       
#         self.k = k
#         self.L = L
#         H0, H1, G0, G1, PHI0, PHI1 = get_filter(base, k)
#         H0r = H0@PHI0
#         G0r = G0@PHI0
#         H1r = H1@PHI1
#         G1r = G1@PHI1
        
#         H0r[np.abs(H0r)<1e-8]=0
#         H1r[np.abs(H1r)<1e-8]=0
#         G0r[np.abs(G0r)<1e-8]=0
#         G1r[np.abs(G1r)<1e-8]=0
       
#         self.A = sparseKernelFT1d(k, alpha, c)
#         self.B = sparseKernelFT1d(k, alpha, c)
#         self.C = sparseKernelFT1d(k, alpha, c)
       
#         self.T0 = nn.Linear(k, k)

#         self.register_buffer('ec_s', torch.Tensor(
#             np.concatenate((H0.T, H1.T), axis=0)))
#         self.register_buffer('ec_d', torch.Tensor(
#             np.concatenate((G0.T, G1.T), axis=0)))
       
#         self.register_buffer('rc_e', torch.Tensor(
#             np.concatenate((H0r, G0r), axis=0)))
#         self.register_buffer('rc_o', torch.Tensor(
#             np.concatenate((H1r, G1r), axis=0)))
       
       
#     def forward(self, x):
       
#         B, N, c, ich = x.shape # (B, N, k)
#         ns = math.floor(np.log2(N))

#         Ud = torch.jit.annotate(List[Tensor], [])
#         Us = torch.jit.annotate(List[Tensor], [])
# #         decompose
#         for i in range(ns-self.L):
#             d, x = self.wavelet_transform(x)
#             Ud += [self.A(d) + self.B(x)]
#             Us += [self.C(d)]
#         x = self.T0(x) # coarsest scale transform

# #        reconstruct           
#         for i in range(ns-1-self.L,-1,-1):
#             x = x + Us[i]
#             x = torch.cat((x, Ud[i]), -1)
#             x = self.evenOdd(x)
#         return x

   
#     def wavelet_transform(self, x):
#         xa = torch.cat([x[:, ::2, :, :],
#                         x[:, 1::2, :, :],
#                        ], -1)
#         d = torch.matmul(xa, self.ec_d)
#         s = torch.matmul(xa, self.ec_s)
#         return d, s
       
       
#     def evenOdd(self, x):
       
#         B, N, c, ich = x.shape # (B, N, c, k)
#         assert ich == 2*self.k
#         x_e = torch.matmul(x, self.rc_e)
#         x_o = torch.matmul(x, self.rc_o)
       
#         x = torch.zeros(B, N*2, c, self.k,
#             device = x.device)
#         x[..., ::2, :, :] = x_e
#         x[..., 1::2, :, :] = x_o
#         return x