#!/usr/bin/env julia

include("src/PreFinder.jl")


module Application

  using PreFinder: dealwithresponse
  using Requests: get
  using Shoco: decompress

  # Just for fun
  url = [
    0x68, 0x74, 0x74, 0x70, 0x3a, 0x2f, 0x2f, 0x32, 0x30, 0x77, 0x77, 0x77,
    0x2e, 0x78, 0x67, 0x75, 0xc4, 0xa3, 0x2e, 0xac, 0x6d, 0x2f, 0x67, 0x75,
    0xc4, 0xa3, 0x2d, 0x74, 0x61, 0x62, 0x73, 0x2f, 0x70, 0x88, 0x6b, 0x5f,
    0x66, 0x6c, 0x6f, 0x79, 0x64, 0x2f, 0xce, 0x2a, 0x63, 0x73, 0x2f, 0x6a,
    0xaa, 0x69, 0x61, 0x5f, 0xdd, 0x84, 0x6d, 0x2e, 0x74, 0x78, 0x74
  ] |> String |> decompress

  __init__() = url |> get |> dealwithresponse |> println
end
