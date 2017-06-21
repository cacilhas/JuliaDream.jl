module PreFinder

  using AbstractTrees: PostOrderDFS
  using Gumbo: HTMLElement, HTMLNode, HTMLText, parsehtml
  using HttpCommon: Response

  export dealwithresponse

  typealias Bytes Array{UInt8,1}

  immutable Message{T}
    message::String

    Message(message::String) = new(message)
    Message(message::Bytes) = message |> String |> Message{T}
  end

  macro attr(key)
    return :( obj -> obj.$key )
  end

  macro split(sep)
    return :( s -> split(s, $sep) )
  end

  macro firstor(default)
    return :( s -> isempty(s) ? $default : first(s) )
  end

  dealwithresponse(res::Response) = res |> preparse |> parseresponse

  parseresponse(data::Message{:error}) = data.message |> error
  parseresponse(data::Message{:plain}) = data.message
  parseresponse(data::Message{:html}) =
    data.message |> parsehtml |> (@attr root) |> findpre |> @attr text
  parseresponse{T}(::Message{T}) =
    "unknown content type $T" |> ParseError |> throw

  # Do post order deep first traversal on elements to find pre element
  # http://www.geeksforgeeks.org/bfs-vs-dfs-binary-tree/
  findpre(elems::PostOrderDFS) =
    filter(ispre, elems) |> (@firstor HTMLElement(:pre)) |>
    (@attr children) |> @firstor HTMLText("")
  findpre(elems::HTMLNode) = elems |> PostOrderDFS |> findpre

  ispre(elem::HTMLElement{:pre}) = true
  ispre(elem::HTMLElement{:PRE}) = true
  ispre(elem::HTMLNode) = false

  preparse(res::Response) =
    get!(res.headers, "Content-Type", "text/html") |> lastword |> Symbol |>
    ctype -> preparse(Val{res.status}(), ctype, res.data)
  preparse(::Val{204}, ::Symbol, ::Bytes) = Message{:plain}("")
  preparse(::Val{200}, ctype::Symbol, data::Bytes) = Message{ctype}(data)
  preparse{S}(::Val{S}, ::Symbol, data::Bytes) = Message{:error}(data)

  lastword(mime::String) = split(mime, ";") |> first |> (@split "/") |> last

end
