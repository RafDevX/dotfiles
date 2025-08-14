{ lib, ... }:

let
  /*
    Synopsis: mapAttrsRecursive' f attrs

    Transform a attrset by recursively mutating its name-value pairs.
    This works in the same way as lib.mapAttrs', but deep, not shallow.

    Inputs:
    - f: A function mapping a name and a value to a lib.nameValuePair object.
    - attrs: The attrset to transform.

    Output Format:
    The transformed attrset.
  */
  mapAttrsRecursive' =
    f: attrs:
    lib.mapAttrs' (
      name: value:
      let
        newValue =
          if builtins.isAttrs value && !builtins.isFunction value then mapAttrsRecursive' f value else value;
      in
      f name newValue
    ) attrs;

  /*
    Synopsis: mutFirstChar f str

    Transform a string by mutating its first character according to a given f.

    Inputs:
    - f: A function (str -> str) to apply to the first character of str.
    - str: The string to transform.

    Output Format:
    An identical string, with the exception that the first string has been
    mapped through the given function f.

    Adapted From:
    https://github.com/tweag/nix-hour/blob/master/code/76/default.nix#L4
  */
  mutFirstChar =
    f: str:
    let
      firstChar = lib.substring 0 1 str;
      mapped = f firstChar;
      rest = lib.substring 1 (-1) str;
    in
    mapped + rest;

  /*
    Synopsis: kebabToCamel str

    Transform a string from kebab-case to camelCase.

    Inputs:
    - str: The string to transform, in kebab-case.

    Output Format:
    A corresponding string, in camelCase.

    Adapted From:
    https://github.com/tweag/nix-hour/blob/master/code/76/default.nix#L16
  */
  kebabToCamel =
    str:
    let
      words = lib.splitString "-" str;
      joined = lib.concatMapStrings (mutFirstChar lib.toUpper) words;
    in
    mutFirstChar lib.toLower joined;
in
{
  inherit
    mapAttrsRecursive'
    mutFirstChar
    kebabToCamel
    ;
}
