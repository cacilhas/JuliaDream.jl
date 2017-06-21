include("../src/PreFinder.jl")


module PreFinderTest

  using Base.Test
  using HttpCommon: Cookie, Headers, Request, Response
  using PreFinder: dealwithresponse

  @testset "PreFinder.dealwithresponse Test" begin
    no_cookies = Dict{String,Cookie}()

    @testset "response 200 with no pre element" begin
      data = "<html><head></head><body><p>Test</p></html>\n"
      res = Response(
        200,
        Headers(
          "Content-Type" => "text/html; charset=ascii",
          "Content-Length" => data |> length |> string,
        ),
        no_cookies, data, Request(), Response[], true, Request[],
      )
      # TODO: review this behavior
      @test dealwithresponse(res) == ""
    end

    @testset "response 200 with pre element" begin
      data = "<html><head></head><p>Before</p><pre>here code</pre><p>After</p></body></html>\n"
      res = Response(
        200,
        Headers(
          "Content-Type" => "text/html; charset=ascii",
          "Content-Length" => data |> length |> string,
        ),
        no_cookies, data, Request(), Response[], true, Request[],
      )
      @test dealwithresponse(res) == "here code"
    end

    @testset "response 200 with no content-type" begin
      data = "<html><head></head><p>Before</p><pre>here code</pre><p>After</p></body></html>\n"
      res = Response(
        200,
        Headers(
          "Content-Length" => data |> length |> string,
        ),
        no_cookies, data, Request(), Response[], true, Request[],
      )
      @test dealwithresponse(res) == "here code"
    end

    @testset "response 200 with plain text" begin
      data = "some plain text\n"
      res = Response(
        200,
        Headers(
          "Content-Type" => "text/plain; charset=ascii",
          "Content-Length" => data |> length |> string,
        ),
        no_cookies, data, Request(), Response[], true, Request[],
      )
      @test dealwithresponse(res) == data
    end

    @testset "response 204" begin
      res = Response(
        204,
        Headers(
          "Content-Length" => "0",
        ),
        no_cookies, "", Request(), Response[], true, Request[],
      )
      @test dealwithresponse(res) == ""
    end

    @testset "internal server error" begin
      data = "INTERNAL SERVER ERROR"
      res = Response(
        500,
        Headers(
          "Content-Type" => "text/plain; charset=ascii",
          "Content-Length" => data |> length |> string,
        ),
        no_cookies, data, Request(), Response[], true, Request[],
      )
      @test_throws ErrorException dealwithresponse(res)
    end

    @testset "page not found" begin
      data = "NOT FOUND"
      res = Response(
        404,
        Headers(
          "Content-Type" => "text/plain; charset=ascii",
          "Content-Length" => data |> length |> string,
        ),
        no_cookies, data, Request(), Response[], true, Request[],
      )
      @test_throws ErrorException dealwithresponse(res)
    end

    @testset "unknown content type" begin
      data = "{\"valid_json\":true}"
      res = Response(
        200,
        Headers(
          "Content-Type" => "application/json; charset=utf-8",
          "Content-Length" => data |> length |> string,
        ),
        no_cookies, data, Request(), Response[], true, Request[],
      )
      @test_throws ParseError dealwithresponse(res)
    end
  end

end
