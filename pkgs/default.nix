inputs: final: prev: let
  sources = prev.callPackage ./_sources/generated.nix {};
in {
  spicetify-cli = with prev;
    spicetify-cli.overrideAttrs (_: {
      inherit (sources.spicetify-cli) pname version src;
      postInstall = ''
        cp -r ./jsHelper ./Themes ./Extensions ./CustomApps ./globals.d.ts ./css-map.json $out/bin
      '';
    });
  spicetify-themes = sources.spicetify-themes.src;
  spotify-spicetified = final.callPackage ./spotify-spicetified {};

  web-greeter = final.callPackage ./web-greeter.nix {
    web-greeter-src = inputs.web-greeter;
  };

  wlroots = prev.wlroots.overrideAttrs (oldAttrs: {
    patchPhase = ''
      substituteInPlace render/gles2/renderer.c --replace "glFlush();" "glFinish();"
    '';
  });

  hyprland-nvidia = inputs.hyprland.packages.${prev.system}.default.override {inherit (final) wlroots;};
}
