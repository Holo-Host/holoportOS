{ stdenv, buildGoPackage, fetchFromGitHub }:
#with import <nixpkgs> {};
buildGoPackage rec {
  name    = "holo-led";


  goPackagePath = "github.com/samrose/holo-led";

  src = fetchFromGitHub {
    owner  = "samrose";
    repo   = "holo-led";
    rev    = "52fb2e5c8081884546d5490226b85121fc1feba0"; # untagged
    sha256 = "0rq9mndsgsssya4y32w8acclrvgnn548wf4b3lw307k8vb8y35wl";
  };

  goDeps = ./deps.nix;

  meta = with stdenv.lib; {
    description = "holo-led";
    homepage    = https://github.com/samrose/holo-led;
    license     = licenses.free;
    platforms   = platforms.unix;
    maintainers = [ maintainers.samrose ];
  };
}