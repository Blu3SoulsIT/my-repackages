# Unpacked Chromium extension that forces `autoGainControl = false` on every
# WebRTC audio capture, so the browser can't keep turning the mic level up/down.
# Load it with `--load-extension=<this package>`.
{ runCommand, writeText }:

let
  manifest = writeText "manifest.json" (
    builtins.toJSON {
      manifest_version = 3;
      name = "Disable WebRTC auto gain";
      version = "1.0";
      content_scripts = [
        {
          matches = [ "<all_urls>" ];
          js = [ "no-agc.js" ];
          run_at = "document_start";
          all_frames = true;
          match_origin_as_fallback = true;
          world = "MAIN";
        }
      ];
    }
  );

  script = writeText "no-agc.js" ''
    (function () {
      function fix(c) {
        if (!c || !c.audio) return c;
        var audio = c.audio === true ? {} : Object.assign({}, c.audio);
        audio.autoGainControl = false;
        return Object.assign({}, c, { audio: audio });
      }
      var md = navigator.mediaDevices;
      if (md && md.getUserMedia) {
        var gum = md.getUserMedia.bind(md);
        md.getUserMedia = function (c) { return gum(fix(c)); };
      }
      var apply = MediaStreamTrack.prototype.applyConstraints;
      MediaStreamTrack.prototype.applyConstraints = function (c) {
        if (this.kind === "audio") c = Object.assign({}, c || {}, { autoGainControl: false });
        return apply.call(this, c);
      };
    })();
  '';
in
runCommand "chromium-no-agc-extension" { } ''
  mkdir -p $out
  cp ${manifest} $out/manifest.json
  cp ${script} $out/no-agc.js
''
