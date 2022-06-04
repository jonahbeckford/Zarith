let () = Printexc.record_backtrace true

let () =
  if Array.length Sys.argv <> 4 then (
    print_endline "Usage: ./configure_env.exe %{cc} %{ccomp_type} %{context_name}";
    exit 1)

let uname () =
  let ic = Unix.open_process_in "uname -s" in
  let s = input_line ic in
  String.trim s

module Var : sig
  val os : string
  val is_homebrew_amr64 : bool
end = struct
  let is_homebrew_amr64 = Sys.file_exists "/opt/homebrew/bin/brew"

  let normalise raw =
    match String.lowercase_ascii raw with "darwin" | "osx" -> "macos" | s -> s

  let os = normalise (match Sys.os_type with "Unix" -> uname () | s -> s)
end

let cc = Sys.argv.(1)
let ccomp_type = Sys.argv.(2)
let context_name = Sys.argv.(3)

let ldflags =
  match Unix.getenv "LDFLAGS" with exception Not_found -> "" | s -> s

let cflags =
  match Unix.getenv "CFLAGS" with exception Not_found -> "" | s -> s

let os_derived_flags =
  match Var.os with
  | "openbsd" | "freebsd" ->
      Printf.sprintf
        "LDFLAGS=\"%s -L/usr/local/lib\" CFLAGS=\"%s -I/usr/local/include\""
        ldflags cflags
  | "macos" when Var.is_homebrew_amr64 ->
      Printf.sprintf
        "LDFLAGS=\"%s -L/opt/homebrew/lib\" CFLAGS=\"%s \
         -I/opt/homebrew/include\""
        ldflags cflags
  | "macos" ->
      Printf.sprintf
        "LDFLAGS=\"%s -L/opt/local/lib -L/usr/local/lib\" CFLAGS=\"%s \
         -I/opt/local/include -I/usr/local/include\""
        ldflags cflags
  | _ -> ""

let fmt_list_of_string_with_space fmt l =
  List.iteri
    (fun i s ->
      if i > 0 then Format.fprintf fmt " ";
      Format.fprintf fmt "%s" s)
    l

let flags =
  let open Dkml_c_probe in
  match C_conf.load_from_dune_context_name context_name with
  | Error msg ->
    Printf.eprintf "WARNING: [loading C_conf] %s\n" msg;
    os_derived_flags
  | Ok c_conf ->
    match C_conf.compiler_flags_of_ccomp_type c_conf ~ccomp_type ~clibrary:"gmp" with
    | Error msg ->
      Printf.eprintf "WARNING: [compiler_flags] %s\n" msg;
      os_derived_flags
    | Ok None -> os_derived_flags
    | Ok Some flags ->
      Format.asprintf
        "LDFLAGS=\"%a\" CFLAGS=\"%a\""
        fmt_list_of_string_with_space (C_conf.C_flags.link_flags_pathonly flags)
        fmt_list_of_string_with_space (C_conf.C_flags.cc_flags flags)

let () = Printf.printf "CC=\"%s\" %s%!" cc flags
