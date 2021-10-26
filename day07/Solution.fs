open System

let readLines =
    Seq.initInfinite (fun _ -> Console.ReadLine())
    |> Seq.takeWhile (String.IsNullOrWhiteSpace >> not)
    |> Seq.toList

let listToString (s: list<char>) = s |> List.toSeq |> String.Concat

let rec hasAbba (s: string) =
    match (s |> Seq.toList) with
    | a1 :: b1 :: b2 :: a2 :: _ when a1 = a2 && b1 = b2 && a1 <> b1 -> true
    | _ :: tail -> tail |> listToString |> hasAbba
    | _ -> false

let tokenize (s: string) = s.Split [| '['; ']' |]

let isEven n = n % 2 = 0


let partitionBlocks (s: string) =
    s
    |> tokenize
    |> Array.indexed
    |> Array.partition (fst >> isEven)

let supportsTLS (s: string) : bool =
    let (supernets, hypernets) = partitionBlocks s

    let supernetContainsAbba =
        supernets |> Array.map snd |> Array.exists hasAbba

    let hypernetContainsNoAbba =
        hypernets
        |> Array.map snd
        |> Array.exists hasAbba
        |> not

    supernetContainsAbba && hypernetContainsNoAbba

let rec findABAs (s: string) : list<char * char> =
    match (s |> Seq.toList) with
    | a1 :: b :: a2 :: tail when a1 = a2 && a1 <> b ->
        (a1, b)
        :: ((b :: a2 :: tail) |> listToString |> findABAs)
    | _ :: tail -> tail |> listToString |> findABAs
    | _ -> []

let supportsSSL (s: string) : bool =
    let (supernets, hypernets) = partitionBlocks s

    let abas =
        supernets
        |> Array.map snd
        |> Array.collect (findABAs >> Array.ofList)

    hypernets
    |> Array.map snd
    |> Array.exists (fun supernet ->
        abas
        |> Array.exists (fun (a, b) -> supernet.Contains($"{b}{a}{b}")))


[<EntryPoint>]
let main argv =
    let lines = readLines

    lines
    |> List.filter supportsTLS
    |> List.length
    |> printfn "Part 1: %d"

    lines
    |> List.filter supportsSSL
    |> List.length
    |> printfn "Part 2: %d"

    0
