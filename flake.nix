{
  description = "FoundationDB 6.2";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
  };

  outputs = { self, nixpkgs, ... }:

    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in rec {

      toml11 = pkgs.stdenv.mkDerivation {
        pname = "toml11";
        version = "3.5.0";

        src = pkgs.fetchurl {
          url = "https://github.com/ToruNiina/toml11/archive/v3.5.0.tar.gz";
          sha256 = "FC613874C6E80DC740134A7353CF23C7F834B59CD601AF84AB535EE16A53B1C3";
        };

        nativeBuildInputs = with pkgs; [ cmake ];
        buildInputs = with pkgs; [ boost172 ];

        cmakeFlags = [
          "-DCMAKE_INSTALL_PREFIX:PATH=$out"
          "-Dtoml11_BUILD_TEST:BOOL=OFF"
        ];

        buildPhase = "cmake .";

        installPhase = ''
          make install;
        '';
      };

      defaultPackage.x86_64-linux =
        with import nixpkgs { system = "x86_64-linux"; };

        stdenv.mkDerivation {
          pname = "foundationdb";
          version = "6.2";
          src = self;

          nativeBuildInputs = [ cmake ninja python3 openjdk mono ];
          buildInputs = [ openssl boost172 toml11 ];

          enableParallelBuilding = false;

          cmakeFlags = [
            "-DCMAKE_BUILD_TYPE=Release"

#            "-DTOML11_INCLUDE_DIR=${toml11.out}"

            "-DOPENSSL_USE_STATIC_LIBS=FALSE"
            "-DOPENSSL_INCLUDE_DIR=${openssl.dev}"
            "-DOPENSSL_CRYPTO_LIBRARY=${openssl.out}/lib/libcrypto.so"
            "-DOPENSSL_SSL_LIBRARY=${openssl.out}/lib/libssl.so"
          ];

#          patchPhase = ''
#            ln -s ${toml11.out} $src/toml11;
#          '';

        };

    };

}
