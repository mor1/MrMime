open Lwt.Infix

module Client = Cohttp_lwt_unix.Client
module Body   = Cohttp_lwt_body

let iana_database =
  Uri.of_string "http://www.iana.org/assignments/media-types/media-types.xml"
let filename = "mtype.xml"

let save filename url =
  Client.call `GET url
  >>= fun (resp, body) ->
    match Cohttp.Response.status resp with
    | `OK ->
      Body.to_string body
      >>= fun body -> Lwt_io.open_file ~mode:Lwt_io.output filename
      >>= fun file -> Lwt_io.write file body
    | _ -> Lwt.return ()

let do_cmd filename url =
  Lwt_main.run (save filename url)
  |> fun () -> `Ok ()

open Cmdliner

let file =
  let doc = "Filename to save the Media types IANA database" in
  Arg.(value & opt string filename & info ["f"; "file"] ~doc)

let uri = (fun s -> `Ok (Uri.of_string s)), Uri.pp_hum

let url =
  let doc = "URL to the Media types IANA database (XML format)" in
  Arg.(value & opt uri iana_database & info ["u"; "url"] ~doc)

let cmd =
  let doc = "Downloader of Media types IANA database" in
  let man =
  [ `S "Description"
  ; `P "$(tname) download the Media types IANA database and save in file." ]
  in
  Term.(pure do_cmd $ file $ url),
  Term.info "get_mtype" ~doc ~man

let () = match Term.eval cmd with
  | `Error _ -> exit 1
  | _        -> exit 0
