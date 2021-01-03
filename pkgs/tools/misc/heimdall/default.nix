{ stdenv, mkDerivation, fetchFromGitHub, cmake, zlib, libusb1
, enableGUI ? false, qtbase ? null
}:

let version = "1.4.2"; in

mkDerivation {
  name = "heimdall-${if enableGUI then "gui-" else ""}${version}";

  src = fetchFromGitHub {
    owner  = "Benjamin-Dobell";
    repo   = "Heimdall";
    rev    = "v${version}";
    sha256 = "1ygn4snvcmi98rgldgxf5hwm7zzi1zcsihfvm6awf9s6mpcjzbqz";
  };

  buildInputs = [
    zlib libusb1
  ] ++ stdenv.lib.optional enableGUI qtbase;
  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    "-DDISABLE_FRONTEND=${if enableGUI then "OFF" else "ON"}"
    "-DLIBUSB_LIBRARY=${libusb1}"
  ];

  preConfigure = ''
    # Give ownership of the Galaxy S USB device to the logged in user.
    substituteInPlace heimdall/60-heimdall.rules --replace 'MODE="0666"' 'TAG+="uaccess"'
  '' + stdenv.lib.optionalString stdenv.isDarwin ''
    substituteInPlace libpit/CMakeLists.txt --replace "-std=gnu++11" ""
  '';

  installPhase = ''
    mkdir -p $out/{bin,share/doc/heimdall,lib/udev/rules.d}
    install -m755 -t $out/bin                bin/*
    install -m644 -t $out/lib/udev/rules.d   ../heimdall/60-heimdall.rules
    install -m644 ../Linux/README   $out/share/doc/heimdall/README.linux
    install -m644 ../OSX/README.txt $out/share/doc/heimdall/README.osx
  '';

  meta = with stdenv.lib; {
    homepage    = "http://www.glassechidna.com.au/products/heimdall/";
    description = "A cross-platform tool suite to flash firmware onto Samsung Galaxy S devices";
    license     = licenses.mit;
    maintainers = with maintainers; [ peterhoeg ];
    platforms   = platforms.unix;
  };
}
