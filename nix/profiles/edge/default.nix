/**
 * The bleeding-edge profile (`edge`) uses the highest software versions, even if they are
 * not yet supported by CiviCRM.
 *
 * Note: The `dists` var provides a list of major releases of Nix upstream (eg v19.09 <=> dists.v1909).
 */
let
    dists = import ../../pins;
    stdenv = dists.default.stdenv;
    isAppleM1 = stdenv.isDarwin && stdenv.isAarch64;

in (import ../base/default.nix) ++ (import ../mgmt/default.nix) ++ [

    dists.bkit.php82
    dists.default.nodejs-14_x
    dists.default.apacheHttpd
    dists.default.mailhog
    dists.default.memcached
    /* dists.default.mariadb */
    dists.default.mysql80
    dists.default.redis
    dists.bkit.transifexClient

] ++ (if isAppleM1 then [] else [dists.default.chromium])
