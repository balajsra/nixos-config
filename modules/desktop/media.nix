{ self, ... }:

{
  flake.homeModules.media = {
    imports = [
      self.homeModules.media-scraper
      self.homeModules.video
      self.homeModules.audio
      self.homeModules.image
      self.homeModules.media-management
    ];
  };

  flake.homeModules.media-scraper =
    {
      pkgs,
      osConfig,
      lib,
      ...
    }:
    {
      config = lib.mkIf (osConfig.features.media.scraper.enable) {
        home.packages = with pkgs; [
          ani-cli
          yt-dlp
          parabolic
        ];
      };
    };

  flake.homeModules.video =
    {
      pkgs,
      osConfig,
      lib,
      ...
    }:
    {
      config = lib.mkIf (osConfig.features.media.video.enable) {
        # https://wiki.nixos.org/wiki/MPV
        programs.mpv = {
          enable = true;
          config = {
            profile = "high-quality";
            hwdec = "auto";
            sub-auto = "fuzzy";
            sub-bold = "yes";
          };
        };

        home.packages = with pkgs; [
          mpv
          celluloid
          handbrake
          mkvtoolnix
          ffmpeg
          jellyfin-desktop
          aegisub
          kdePackages.kdenlive
        ];

        # https://wiki.nixos.org/wiki/Default_applications
        xdg.mimeApps = {
          enable = true;
          defaultApplications = {
            "video/x-matroska" = "io.github.celluloid_player.Celluloid.desktop";
            "video/mp4" = "io.github.celluloid_player.Celluloid.desktop";
            "audio/mpeg" = "io.github.celluloid_player.Celluloid.desktop";
            "audio/flac" = "io.github.celluloid_player.Celluloid.desktop";
          };
        };
      };
    };

  flake.homeModules.audio =
    {
      pkgs,
      osConfig,
      lib,
      ...
    }:
    {
      config = lib.mkIf (osConfig.features.media.audio.enable) {
        home.packages = with pkgs; [
          feishin
          pocket-casts
        ];
      };
    };

  flake.homeModules.image =
    {
      pkgs,
      osConfig,
      lib,
      inputs,
      ...
    }:
    let
      gimpVersion = lib.versions.majorMinor pkgs.gimp.version;
    in
    {
      config = lib.mkIf (osConfig.features.media.image.enable) {
        home.packages = with pkgs; [
          gimp
          ristretto
        ];

        xdg.configFile."GIMP/${gimpVersion}/themes/Dracula".source = "${inputs.dracula-gimp}/Dracula";
        xdg.configFile."GIMP/${gimpVersion}/gimprc".text = ''
          (theme "Dracula")
        '';
      };
    };

  flake.homeModules.media-management =
    {
      pkgs,
      osConfig,
      lib,
      ...
    }:
    {
      config = lib.mkIf (osConfig.features.media.management.enable) {
        # Point Picard at custom configuration
        home.packages = with pkgs; [
          (symlinkJoin {
            name = "picard-wrapped";
            paths = [ picard ];
            buildInputs = [ makeWrapper ];
            postBuild = ''
              wrapProgram $out/bin/picard \
                --add-flags "-c \$HOME/.config/MusicBrainz/Picard-custom.ini"
            '';
          })
        ];

        xdg.configFile."MusicBrainz/Picard-custom.ini".text = ''
          [setting]
          aac_save_ape=true
          ac3_save_ape=true
          acoustid_apikey=
          acoustid_fpcalc=
          active_file_naming_script_id=Preset 3
          allow_multi_dirs_selection=false
          always_standardize_multivalue_artist=false
          analyze_new_files=false
          artists_genres=false
          ascii_filenames=true
          autobackup_directory=/data/sravan/Documents
          browser_integration=true
          browser_integration_localhost_only=true
          browser_integration_port=8000
          builtin_search=true
          ca_providers=@Variant(\0\0\0\x7f\0\0\0\xePyQt_PyObject\0\0\0\0!\x80\x5\x95\x16\0\0\0\0\0\0\0\x8c\xf\x43\x61\x61ReleaseGroup\x94\x88\x86\x94.), @Variant(\0\0\0\x7f\0\0\0\xePyQt_PyObject\0\0\0\0#\x80\x5\x95\x18\0\0\0\0\0\0\0\x8c\x11\x43over Art Archive\x94\x88\x86\x94.), @Variant(\0\0\0\x7f\0\0\0\xePyQt_PyObject\0\0\0\0\"\x80\x5\x95\x17\0\0\0\0\0\0\0\x8c\x10UrlRelationships\x94\x88\x86\x94.), @Variant(\0\0\0\x7f\0\0\0\xePyQt_PyObject\0\0\0\0\x1d\x80\x5\x95\x12\0\0\0\0\0\0\0\x8c\vLocal Files\x94\x89\x86\x94.)
          caa_approved_only=false
          caa_image_size=500
          caa_image_types=@Variant(\0\0\0\t\0\0\0\x1\0\0\0\n\0\0\0\n\0\x66\0r\0o\0n\0t)
          caa_image_types_to_omit=matrix/runout, raw/unedited, watermark
          caa_restrict_image_types=true
          cd_lookup_device=/dev/cdrom
          check_for_plugin_updates=false
          check_for_updates=false
          check_rtd_updates=false
          clear_existing_tags=false
          cluster_new_files=true
          completeness_ignore_data=false
          completeness_ignore_pregap=false
          completeness_ignore_silence=false
          completeness_ignore_videos=false
          convert_punctuation=true
          cover_file_convert_images=false
          cover_file_convert_to_format=jpeg
          cover_file_enlarge=false
          cover_file_resize=false
          cover_file_resize_mode=0
          cover_file_resize_target_height=1000
          cover_file_resize_target_width=1000
          cover_image_filename=cover
          cover_image_quality=90
          cover_minimum_height=250
          cover_minimum_width=250
          cover_tags_convert_images=false
          cover_tags_convert_to_format=jpeg
          cover_tags_enlarge=false
          cover_tags_resize=false
          cover_tags_resize_mode=0
          cover_tags_resize_target_height=1000
          cover_tags_resize_target_width=1000
          delete_empty_dirs=true
          disable_date_sanitization_formats=@Invalid()
          discouraged_release_types=@Invalid()
          dont_replace_cover_of_types=false
          dont_replace_included_types=@Variant(\0\0\0\x7f\0\0\0\xePyQt_PyObject\0\0\0\0\x16\x80\x5\x95\v\0\0\0\0\0\0\0\x8c\x5\x66ront\x94\x85\x94.)
          dont_replace_with_smaller_cover=false
          embed_only_one_front_image=true
          enable_ratings=false
          enable_tag_saving=true
          enable_tagger_scripts=true
          enable_user_collections=true
          file_renaming_scripts="@Variant(\0\0\0\b\0\0\0\x3\0\0\0\x10\0P\0r\0\x65\0s\0\x65\0t\0 \0\x31\0\0\0\b\0\0\0\t\0\0\0\f\0\x61\0u\0t\0h\0o\0r\0\0\0\n\0\0\0\x46\0M\0u\0s\0i\0\x63\0\x42\0r\0\x61\0i\0n\0z\0 \0P\0i\0\x63\0\x61\0r\0\x64\0 \0\x44\0\x65\0v\0\x65\0l\0o\0p\0m\0\x65\0n\0t\0 \0T\0\x65\0\x61\0m\0\0\0\x16\0\x64\0\x65\0s\0\x63\0r\0i\0p\0t\0i\0o\0n\0\0\0\n\0\0\0\xd2\0T\0h\0i\0s\0 \0p\0r\0\x65\0s\0\x65\0t\0 \0\x65\0x\0\x61\0m\0p\0l\0\x65\0 \0\x66\0i\0l\0\x65\0 \0n\0\x61\0m\0i\0n\0g\0 \0s\0\x63\0r\0i\0p\0t\0 \0\x64\0o\0\x65\0s\0 \0n\0o\0t\0 \0r\0\x65\0q\0u\0i\0r\0\x65\0 \0\x61\0n\0y\0 \0s\0p\0\x65\0\x63\0i\0\x61\0l\0 \0s\0\x65\0t\0t\0i\0n\0g\0s\0,\0 \0t\0\x61\0g\0g\0i\0n\0g\0 \0s\0\x63\0r\0i\0p\0t\0s\0 \0o\0r\0 \0p\0l\0u\0g\0i\0n\0s\0.\0\0\0\x4\0i\0\x64\0\0\0\n\0\0\0\x10\0P\0r\0\x65\0s\0\x65\0t\0 \0\x31\0\0\0\x18\0l\0\x61\0s\0t\0_\0u\0p\0\x64\0\x61\0t\0\x65\0\x64\0\0\0\n\0\0\0.\0\x32\0\x30\0\x31\0\x39\0-\0\x30\0\x38\0-\0\x30\0\x35\0 \0\x31\0\x33\0:\0\x34\0\x30\0:\0\x30\0\x30\0 \0U\0T\0\x43\0\0\0\xe\0l\0i\0\x63\0\x65\0n\0s\0\x65\0\0\0\n\0\0\0\x38\0G\0N\0U\0 \0P\0u\0\x62\0l\0i\0\x63\0 \0L\0i\0\x63\0\x65\0n\0s\0\x65\0 \0v\0\x65\0r\0s\0i\0o\0n\0 \0\x32\0\0\0\f\0s\0\x63\0r\0i\0p\0t\0\0\0\n\0\0\x1\xea\0$\0i\0\x66\0\x32\0(\0%\0\x61\0l\0\x62\0u\0m\0\x61\0r\0t\0i\0s\0t\0%\0,\0%\0\x61\0r\0t\0i\0s\0t\0%\0)\0/\0\n\0$\0i\0\x66\0(\0%\0\x61\0l\0\x62\0u\0m\0\x61\0r\0t\0i\0s\0t\0%\0,\0%\0\x61\0l\0\x62\0u\0m\0%\0/\0,\0)\0\n\0$\0i\0\x66\0(\0$\0g\0t\0(\0%\0t\0o\0t\0\x61\0l\0\x64\0i\0s\0\x63\0s\0%\0,\0\x31\0)\0,\0$\0i\0\x66\0(\0$\0g\0t\0(\0%\0t\0o\0t\0\x61\0l\0\x64\0i\0s\0\x63\0s\0%\0,\0\x39\0)\0,\0$\0n\0u\0m\0(\0%\0\x64\0i\0s\0\x63\0n\0u\0m\0\x62\0\x65\0r\0%\0,\0\x32\0)\0,\0%\0\x64\0i\0s\0\x63\0n\0u\0m\0\x62\0\x65\0r\0%\0)\0-\0,\0)\0$\0i\0\x66\0(\0$\0\x61\0n\0\x64\0(\0%\0\x61\0l\0\x62\0u\0m\0\x61\0r\0t\0i\0s\0t\0%\0,\0%\0t\0r\0\x61\0\x63\0k\0n\0u\0m\0\x62\0\x65\0r\0%\0)\0,\0$\0n\0u\0m\0(\0%\0t\0r\0\x61\0\x63\0k\0n\0u\0m\0\x62\0\x65\0r\0%\0,\0\x32\0)\0 \0,\0)\0$\0i\0\x66\0(\0%\0_\0m\0u\0l\0t\0i\0\x61\0r\0t\0i\0s\0t\0%\0,\0%\0\x61\0r\0t\0i\0s\0t\0%\0 \0-\0 \0,\0)\0%\0t\0i\0t\0l\0\x65\0%\0\0\0.\0s\0\x63\0r\0i\0p\0t\0_\0l\0\x61\0n\0g\0u\0\x61\0g\0\x65\0_\0v\0\x65\0r\0s\0i\0o\0n\0\0\0\n\0\0\0\x6\0\x31\0.\0\x30\0\0\0\n\0t\0i\0t\0l\0\x65\0\0\0\n\0\0\0H\0P\0r\0\x65\0s\0\x65\0t\0 \0\x31\0:\0 \0\x44\0\x65\0\x66\0\x61\0u\0l\0t\0 \0\x66\0i\0l\0\x65\0 \0n\0\x61\0m\0i\0n\0g\0 \0s\0\x63\0r\0i\0p\0t\0\0\0\xe\0v\0\x65\0r\0s\0i\0o\0n\0\0\0\n\0\0\0\x6\0\x31\0.\0\x30\0\0\0\x10\0P\0r\0\x65\0s\0\x65\0t\0 \0\x32\0\0\0\b\0\0\0\t\0\0\0\f\0\x61\0u\0t\0h\0o\0r\0\0\0\n\0\0\0\x46\0M\0u\0s\0i\0\x63\0\x42\0r\0\x61\0i\0n\0z\0 \0P\0i\0\x63\0\x61\0r\0\x64\0 \0\x44\0\x65\0v\0\x65\0l\0o\0p\0m\0\x65\0n\0t\0 \0T\0\x65\0\x61\0m\0\0\0\x16\0\x64\0\x65\0s\0\x63\0r\0i\0p\0t\0i\0o\0n\0\0\0\n\0\0\0\xd2\0T\0h\0i\0s\0 \0p\0r\0\x65\0s\0\x65\0t\0 \0\x65\0x\0\x61\0m\0p\0l\0\x65\0 \0\x66\0i\0l\0\x65\0 \0n\0\x61\0m\0i\0n\0g\0 \0s\0\x63\0r\0i\0p\0t\0 \0\x64\0o\0\x65\0s\0 \0n\0o\0t\0 \0r\0\x65\0q\0u\0i\0r\0\x65\0 \0\x61\0n\0y\0 \0s\0p\0\x65\0\x63\0i\0\x61\0l\0 \0s\0\x65\0t\0t\0i\0n\0g\0s\0,\0 \0t\0\x61\0g\0g\0i\0n\0g\0 \0s\0\x63\0r\0i\0p\0t\0s\0 \0o\0r\0 \0p\0l\0u\0g\0i\0n\0s\0.\0\0\0\x4\0i\0\x64\0\0\0\n\0\0\0\x10\0P\0r\0\x65\0s\0\x65\0t\0 \0\x32\0\0\0\x18\0l\0\x61\0s\0t\0_\0u\0p\0\x64\0\x61\0t\0\x65\0\x64\0\0\0\n\0\0\0.\0\x32\0\x30\0\x32\0\x31\0-\0\x30\0\x34\0-\0\x31\0\x32\0 \0\x32\0\x31\0:\0\x33\0\x30\0:\0\x30\0\x30\0 \0U\0T\0\x43\0\0\0\xe\0l\0i\0\x63\0\x65\0n\0s\0\x65\0\0\0\n\0\0\0\x38\0G\0N\0U\0 \0P\0u\0\x62\0l\0i\0\x63\0 \0L\0i\0\x63\0\x65\0n\0s\0\x65\0 \0v\0\x65\0r\0s\0i\0o\0n\0 \0\x32\0\0\0\f\0s\0\x63\0r\0i\0p\0t\0\0\0\n\0\0\0\\\0%\0\x61\0l\0\x62\0u\0m\0\x61\0r\0t\0i\0s\0t\0%\0/\0\n\0%\0\x61\0l\0\x62\0u\0m\0%\0/\0\n\0%\0t\0r\0\x61\0\x63\0k\0n\0u\0m\0\x62\0\x65\0r\0%\0.\0 \0%\0t\0i\0t\0l\0\x65\0%\0\0\0.\0s\0\x63\0r\0i\0p\0t\0_\0l\0\x61\0n\0g\0u\0\x61\0g\0\x65\0_\0v\0\x65\0r\0s\0i\0o\0n\0\0\0\n\0\0\0\x6\0\x31\0.\0\x30\0\0\0\n\0t\0i\0t\0l\0\x65\0\0\0\n\0\0\0\x66\0P\0r\0\x65\0s\0\x65\0t\0 \0\x32\0:\0 \0[\0\x61\0l\0\x62\0u\0m\0 \0\x61\0r\0t\0i\0s\0t\0]\0/\0[\0\x61\0l\0\x62\0u\0m\0]\0/\0[\0t\0r\0\x61\0\x63\0k\0 \0#\0]\0.\0 \0[\0t\0i\0t\0l\0\x65\0]\0\0\0\xe\0v\0\x65\0r\0s\0i\0o\0n\0\0\0\n\0\0\0\x6\0\x31\0.\0\x30\0\0\0\x10\0P\0r\0\x65\0s\0\x65\0t\0 \0\x33\0\0\0\b\0\0\0\t\0\0\0\f\0\x61\0u\0t\0h\0o\0r\0\0\0\n\0\0\0\x46\0M\0u\0s\0i\0\x63\0\x42\0r\0\x61\0i\0n\0z\0 \0P\0i\0\x63\0\x61\0r\0\x64\0 \0\x44\0\x65\0v\0\x65\0l\0o\0p\0m\0\x65\0n\0t\0 \0T\0\x65\0\x61\0m\0\0\0\x16\0\x64\0\x65\0s\0\x63\0r\0i\0p\0t\0i\0o\0n\0\0\0\n\0\0\0\xd2\0T\0h\0i\0s\0 \0p\0r\0\x65\0s\0\x65\0t\0 \0\x65\0x\0\x61\0m\0p\0l\0\x65\0 \0\x66\0i\0l\0\x65\0 \0n\0\x61\0m\0i\0n\0g\0 \0s\0\x63\0r\0i\0p\0t\0 \0\x64\0o\0\x65\0s\0 \0n\0o\0t\0 \0r\0\x65\0q\0u\0i\0r\0\x65\0 \0\x61\0n\0y\0 \0s\0p\0\x65\0\x63\0i\0\x61\0l\0 \0s\0\x65\0t\0t\0i\0n\0g\0s\0,\0 \0t\0\x61\0g\0g\0i\0n\0g\0 \0s\0\x63\0r\0i\0p\0t\0s\0 \0o\0r\0 \0p\0l\0u\0g\0i\0n\0s\0.\0\0\0\x4\0i\0\x64\0\0\0\n\0\0\0\x10\0P\0r\0\x65\0s\0\x65\0t\0 \0\x33\0\0\0\x18\0l\0\x61\0s\0t\0_\0u\0p\0\x64\0\x61\0t\0\x65\0\x64\0\0\0\n\0\0\0.\0\x32\0\x30\0\x32\0\x31\0-\0\x30\0\x34\0-\0\x31\0\x32\0 \0\x32\0\x31\0:\0\x33\0\x30\0:\0\x30\0\x30\0 \0U\0T\0\x43\0\0\0\xe\0l\0i\0\x63\0\x65\0n\0s\0\x65\0\0\0\n\0\0\0\x38\0G\0N\0U\0 \0P\0u\0\x62\0l\0i\0\x63\0 \0L\0i\0\x63\0\x65\0n\0s\0\x65\0 \0v\0\x65\0r\0s\0i\0o\0n\0 \0\x32\0\0\0\f\0s\0\x63\0r\0i\0p\0t\0\0\0\n\0\0\x1\x94\0$\0i\0\x66\0\x32\0(\0%\0\x61\0l\0\x62\0u\0m\0\x61\0r\0t\0i\0s\0t\0%\0,\0%\0\x61\0r\0t\0i\0s\0t\0%\0)\0/\0\n\0$\0i\0\x66\0(\0%\0\x61\0l\0\x62\0u\0m\0\x61\0r\0t\0i\0s\0t\0%\0,\0%\0\x61\0l\0\x62\0u\0m\0%\0/\0,\0)\0\n\0$\0i\0\x66\0(\0$\0g\0t\0(\0%\0t\0o\0t\0\x61\0l\0\x64\0i\0s\0\x63\0s\0%\0,\0\x31\0)\0,\0%\0\x64\0i\0s\0\x63\0n\0u\0m\0\x62\0\x65\0r\0%\0-\0,\0)\0\n\0$\0i\0\x66\0(\0$\0\x61\0n\0\x64\0(\0%\0\x61\0l\0\x62\0u\0m\0\x61\0r\0t\0i\0s\0t\0%\0,\0%\0t\0r\0\x61\0\x63\0k\0n\0u\0m\0\x62\0\x65\0r\0%\0)\0,\0$\0n\0u\0m\0(\0%\0t\0r\0\x61\0\x63\0k\0n\0u\0m\0\x62\0\x65\0r\0%\0,\0\x32\0)\0 \0,\0)\0\n\0$\0i\0\x66\0(\0%\0_\0m\0u\0l\0t\0i\0\x61\0r\0t\0i\0s\0t\0%\0,\0%\0\x61\0r\0t\0i\0s\0t\0%\0 \0-\0 \0,\0)\0\n\0%\0t\0i\0t\0l\0\x65\0%\0\0\0.\0s\0\x63\0r\0i\0p\0t\0_\0l\0\x61\0n\0g\0u\0\x61\0g\0\x65\0_\0v\0\x65\0r\0s\0i\0o\0n\0\0\0\n\0\0\0\x6\0\x31\0.\0\x30\0\0\0\n\0t\0i\0t\0l\0\x65\0\0\0\n\0\0\0\x8c\0P\0r\0\x65\0s\0\x65\0t\0 \0\x33\0:\0 \0[\0\x61\0l\0\x62\0u\0m\0 \0\x61\0r\0t\0i\0s\0t\0]\0/\0[\0\x61\0l\0\x62\0u\0m\0]\0/\0[\0\x64\0i\0s\0\x63\0 \0\x61\0n\0\x64\0 \0t\0r\0\x61\0\x63\0k\0 \0#\0]\0 \0[\0\x61\0r\0t\0i\0s\0t\0]\0 \0-\0 \0[\0t\0i\0t\0l\0\x65\0]\0\0\0\xe\0v\0\x65\0r\0s\0i\0o\0n\0\0\0\n\0\0\0\x6\0\x31\0.\0\x30)"
          file_save_warning=true
          filebrowser_horizontal_autoscroll=true
          filter_cover_by_size=false
          fingerprinting_system=acoustid
          fix_missing_seekpoints_flac=false
          folksonomy_tags=false
          fpcalc_threads=2
          genres_filter=-seen live\n-favorites\n-fixme\n-owned
          guess_tracknumber_and_title=true
          id3v23_join_with=/
          id3v2_encoding=utf-8
          ignore_existing_acoustid_fingerprints=false
          ignore_file_mbids=false
          ignore_hidden_files=false
          ignore_regex=
          ignore_track_duration_difference_under=2
          image_type_as_filename=false
          interface_colors=@Variant(\0\0\0\b\0\0\0\x15\0\0\0\x18\0\x65\0n\0t\0i\0t\0y\0_\0\x65\0r\0r\0o\0r\0\0\0\n\0\0\0\xe\0#\0\x63\0\x38\0\x30\0\x30\0\x30\0\x30\0\0\0\x1c\0\x65\0n\0t\0i\0t\0y\0_\0p\0\x65\0n\0\x64\0i\0n\0g\0\0\0\n\0\0\0\xe\0#\0\x38\0\x30\0\x38\0\x30\0\x38\0\x30\0\0\0\x18\0\x65\0n\0t\0i\0t\0y\0_\0s\0\x61\0v\0\x65\0\x64\0\0\0\n\0\0\0\xe\0#\0\x30\0\x30\0\x61\0\x61\0\x30\0\x30\0\0\0\x1c\0\x66\0i\0r\0s\0t\0_\0\x63\0o\0v\0\x65\0r\0_\0h\0l\0\0\0\n\0\0\0\xe\0#\0\x62\0\x38\0\x38\0\x36\0\x30\0\x62\0\0\0\x12\0l\0o\0g\0_\0\x64\0\x65\0\x62\0u\0g\0\0\0\n\0\0\0\xe\0#\0\x38\0\x30\0\x30\0\x30\0\x38\0\x30\0\0\0\x12\0l\0o\0g\0_\0\x65\0r\0r\0o\0r\0\0\0\n\0\0\0\xe\0#\0\x66\0\x66\0\x30\0\x30\0\x30\0\x30\0\0\0\x10\0l\0o\0g\0_\0i\0n\0\x66\0o\0\0\0\n\0\0\0\xe\0#\0\x30\0\x30\0\x30\0\x30\0\x30\0\x30\0\0\0\x16\0l\0o\0g\0_\0w\0\x61\0r\0n\0i\0n\0g\0\0\0\n\0\0\0\xe\0#\0\x66\0\x66\0\x38\0\x63\0\x30\0\x30\0\0\0(\0m\0\x61\0t\0\x63\0h\0_\0s\0i\0m\0i\0l\0\x61\0r\0i\0t\0y\0_\0l\0o\0w\0\0\0\n\0\0\0\xe\0#\0\x64\0\x66\0\x37\0\x64\0\x37\0\x64\0\0\0\x1a\0p\0r\0o\0\x66\0i\0l\0\x65\0_\0h\0l\0_\0\x62\0g\0\0\0\n\0\0\0\xe\0#\0\x66\0\x39\0\x66\0\x39\0\x30\0\x36\0\0\0\x1a\0p\0r\0o\0\x66\0i\0l\0\x65\0_\0h\0l\0_\0\x66\0g\0\0\0\n\0\0\0\xe\0#\0\x30\0\x30\0\x30\0\x30\0\x30\0\x30\0\0\0\x1e\0s\0y\0n\0t\0\x61\0x\0_\0h\0l\0_\0\x65\0r\0r\0o\0r\0\0\0\n\0\0\0\xe\0#\0\x66\0\x66\0\x30\0\x30\0\x30\0\x30\0\0\0 \0s\0y\0n\0t\0\x61\0x\0_\0h\0l\0_\0\x65\0s\0\x63\0\x61\0p\0\x65\0\0\0\n\0\0\0\xe\0#\0\x38\0\x62\0\x30\0\x30\0\x30\0\x30\0\0\0\x1c\0s\0y\0n\0t\0\x61\0x\0_\0h\0l\0_\0\x66\0u\0n\0\x63\0\0\0\n\0\0\0\xe\0#\0\x30\0\x30\0\x30\0\x30\0\x66\0\x66\0\0\0\x1c\0s\0y\0n\0t\0\x61\0x\0_\0h\0l\0_\0n\0o\0o\0p\0\0\0\n\0\0\0\xe\0#\0\x61\0\x39\0\x61\0\x39\0\x61\0\x39\0\0\0\"\0s\0y\0n\0t\0\x61\0x\0_\0h\0l\0_\0s\0p\0\x65\0\x63\0i\0\x61\0l\0\0\0\n\0\0\0\xe\0#\0\x30\0\x30\0\x30\0\x30\0\x66\0\x66\0\0\0\"\0s\0y\0n\0t\0\x61\0x\0_\0h\0l\0_\0u\0n\0i\0\x63\0o\0\x64\0\x65\0\0\0\n\0\0\0\xe\0#\0\x38\0\x62\0\x30\0\x30\0\x30\0\x30\0\0\0\x1a\0s\0y\0n\0t\0\x61\0x\0_\0h\0l\0_\0v\0\x61\0r\0\0\0\n\0\0\0\xe\0#\0\x30\0\x30\0\x38\0\x62\0\x38\0\x62\0\0\0\x1e\0t\0\x61\0g\0s\0t\0\x61\0t\0u\0s\0_\0\x61\0\x64\0\x64\0\x65\0\x64\0\0\0\n\0\0\0\xe\0#\0\x30\0\x30\0\x38\0\x30\0\x30\0\x30\0\0\0\"\0t\0\x61\0g\0s\0t\0\x61\0t\0u\0s\0_\0\x63\0h\0\x61\0n\0g\0\x65\0\x64\0\0\0\n\0\0\0\xe\0#\0\x62\0\x38\0\x38\0\x36\0\x30\0\x62\0\0\0\"\0t\0\x61\0g\0s\0t\0\x61\0t\0u\0s\0_\0r\0\x65\0m\0o\0v\0\x65\0\x64\0\0\0\n\0\0\0\xe\0#\0\x66\0\x66\0\x30\0\x30\0\x30\0\x30)
          interface_colors_dark=@Variant(\0\0\0\b\0\0\0\x15\0\0\0\x18\0\x65\0n\0t\0i\0t\0y\0_\0\x65\0r\0r\0o\0r\0\0\0\n\0\0\0\xe\0#\0\x63\0\x38\0\x30\0\x30\0\x30\0\x30\0\0\0\x1c\0\x65\0n\0t\0i\0t\0y\0_\0p\0\x65\0n\0\x64\0i\0n\0g\0\0\0\n\0\0\0\xe\0#\0\x38\0\x30\0\x38\0\x30\0\x38\0\x30\0\0\0\x18\0\x65\0n\0t\0i\0t\0y\0_\0s\0\x61\0v\0\x65\0\x64\0\0\0\n\0\0\0\xe\0#\0\x30\0\x30\0\x61\0\x61\0\x30\0\x30\0\0\0\x1c\0\x66\0i\0r\0s\0t\0_\0\x63\0o\0v\0\x65\0r\0_\0h\0l\0\0\0\n\0\0\0\xe\0#\0\x66\0\x66\0\x61\0\x35\0\x30\0\x30\0\0\0\x12\0l\0o\0g\0_\0\x64\0\x65\0\x62\0u\0g\0\0\0\n\0\0\0\xe\0#\0\x64\0\x64\0\x61\0\x30\0\x64\0\x64\0\0\0\x12\0l\0o\0g\0_\0\x65\0r\0r\0o\0r\0\0\0\n\0\0\0\xe\0#\0\x66\0\x66\0\x30\0\x30\0\x30\0\x30\0\0\0\x10\0l\0o\0g\0_\0i\0n\0\x66\0o\0\0\0\n\0\0\0\xe\0#\0\x66\0\x66\0\x66\0\x66\0\x66\0\x66\0\0\0\x16\0l\0o\0g\0_\0w\0\x61\0r\0n\0i\0n\0g\0\0\0\n\0\0\0\xe\0#\0\x66\0\x66\0\x38\0\x63\0\x30\0\x30\0\0\0(\0m\0\x61\0t\0\x63\0h\0_\0s\0i\0m\0i\0l\0\x61\0r\0i\0t\0y\0_\0l\0o\0w\0\0\0\n\0\0\0\xe\0#\0\x64\0\x66\0\x37\0\x64\0\x37\0\x64\0\0\0\x1a\0p\0r\0o\0\x66\0i\0l\0\x65\0_\0h\0l\0_\0\x62\0g\0\0\0\n\0\0\0\xe\0#\0\x31\0\x63\0\x37\0\x31\0\x64\0\x38\0\0\0\x1a\0p\0r\0o\0\x66\0i\0l\0\x65\0_\0h\0l\0_\0\x66\0g\0\0\0\n\0\0\0\xe\0#\0\x66\0\x66\0\x66\0\x66\0\x66\0\x66\0\0\0\x1e\0s\0y\0n\0t\0\x61\0x\0_\0h\0l\0_\0\x65\0r\0r\0o\0r\0\0\0\n\0\0\0\xe\0#\0\x66\0\x31\0\x36\0\x31\0\x36\0\x31\0\0\0 \0s\0y\0n\0t\0\x61\0x\0_\0h\0l\0_\0\x65\0s\0\x63\0\x61\0p\0\x65\0\0\0\n\0\0\0\xe\0#\0\x34\0\x62\0\x65\0\x66\0\x31\0\x66\0\0\0\x1c\0s\0y\0n\0t\0\x61\0x\0_\0h\0l\0_\0\x66\0u\0n\0\x63\0\0\0\n\0\0\0\xe\0#\0\x66\0\x66\0\x35\0\x37\0\x61\0\x30\0\0\0\x1c\0s\0y\0n\0t\0\x61\0x\0_\0h\0l\0_\0n\0o\0o\0p\0\0\0\n\0\0\0\xe\0#\0\x30\0\x34\0\x65\0\x37\0\x64\0\x35\0\0\0\"\0s\0y\0n\0t\0\x61\0x\0_\0h\0l\0_\0s\0p\0\x65\0\x63\0i\0\x61\0l\0\0\0\n\0\0\0\xe\0#\0\x66\0\x66\0\x35\0\x37\0\x61\0\x30\0\0\0\"\0s\0y\0n\0t\0\x61\0x\0_\0h\0l\0_\0u\0n\0i\0\x63\0o\0\x64\0\x65\0\0\0\n\0\0\0\xe\0#\0\x34\0\x62\0\x65\0\x66\0\x31\0\x66\0\0\0\x1a\0s\0y\0n\0t\0\x61\0x\0_\0h\0l\0_\0v\0\x61\0r\0\0\0\n\0\0\0\xe\0#\0\x66\0\x63\0\x62\0\x62\0\x35\0\x31\0\0\0\x1e\0t\0\x61\0g\0s\0t\0\x61\0t\0u\0s\0_\0\x61\0\x64\0\x64\0\x65\0\x64\0\0\0\n\0\0\0\xe\0#\0\x30\0\x30\0\x38\0\x30\0\x30\0\x30\0\0\0\"\0t\0\x61\0g\0s\0t\0\x61\0t\0u\0s\0_\0\x63\0h\0\x61\0n\0g\0\x65\0\x64\0\0\0\n\0\0\0\xe\0#\0\x62\0\x38\0\x38\0\x36\0\x30\0\x62\0\0\0\"\0t\0\x61\0g\0s\0t\0\x61\0t\0u\0s\0_\0r\0\x65\0m\0o\0v\0\x65\0\x64\0\0\0\n\0\0\0\xe\0#\0\x66\0\x66\0\x30\0\x30\0\x30\0\x30)
          itunes_compatible_grouping=false
          join_genres=
          list_of_scripts="@Variant(\0\0\0\t\0\0\0\x1\0\0\0\x7f\0\0\0\xePyQt_PyObject\0\0\0\x1N\x80\x4\x95\x43\x1\0\0\0\0\0\0(K\0\x8c\tNavidrome\x94\x88X*\x1\0\0# Multiple artists\n$setmulti(albumartists,%_albumartists%)\n$setmulti(albumartistssort,%_albumartists_sort%)\n$setmulti(artistssort,%_artists_sort%)\n\n# Release and Original dates\n$set(releasedate,%date%)\n$set(date,%_recording_firstreleasedate%)\n$set(originaldate,%originaldate%)\n$delete(originalyear)\x94t\x94.)"
          listenbrainz_enabled=false
          listenbrainz_submit_only_tagged=true
          listenbrainz_token=
          local_cover_regex=^(?:cover|folder|albumart)(.*)\\.(?:jpe?g|png|gif|tiff?|webp)$
          log_verbosity=20
          match_min_margin=0.02
          match_min_similarity=0.25
          max_genres=5
          min_genre_usage=90
          move_additional_files=true
          move_additional_files_pattern=*.jpg *.png *.pdf *.txt
          move_files=true
          move_files_to=/mnt/mediaserver/Music
          move_overwrite_existing_files=true
          network_cache_size_bytes=100000000
          network_transfer_timeout_seconds=30
          only_my_genres=false
          player_now_playing=true
          preferred_release_countries=@Invalid()
          preferred_release_formats=Digital Media, CD
          preferred_release_types=@Invalid()
          preserve_images=false
          preserve_timestamps=false
          preserved_tags=@Invalid()
          proxy_password=
          proxy_server_host=
          proxy_server_port=80
          proxy_type=http
          proxy_username=
          query_limit=50
          quick_menu_items=enable_tag_saving, save_images_to_tags, move_files, rename_files, save_images_to_files
          quit_confirmation=true
          rating_user_email=users@musicbrainz.org
          read_isrcs_from_disc=true
          recursively_add_files=true
          release_ars=true
          remove_ape_from_aac=false
          remove_ape_from_ac3=false
          remove_ape_from_mp3=false
          remove_complete_albums_after_save=false
          remove_id3_from_flac=false
          remove_images_from_tags=false
          remove_wave_riff_info=false
          rename_files=true
          replace_dir_separator=_
          replace_spaces_with_underscores=false
          save_acoustid_fingerprints=false
          save_images_overwrite=true
          save_images_to_files=true
          save_images_to_tags=true
          save_only_one_front_image=false
          script_exceptions=@Invalid()
          server_host=musicbrainz.org
          server_port=443
          session_autosave_interval_min=0
          session_backup_on_crash=true
          session_folder_path=
          session_include_mb_data=true
          session_load_last_on_startup=false
          session_no_mb_requests_on_load=true
          session_safe_restore=true
          show_cover_art_details=false
          show_cover_art_details_dimensions=true
          show_cover_art_details_filesize=true
          show_cover_art_details_mimetype=true
          show_cover_art_details_type=false
          show_menu_icons=true
          show_new_user_dialog=false
          standardize_artist_names=variations
          standardize_instruments=true
          standardize_vocals=true
          starting_directory=true
          starting_directory_path=/home/sravan/Downloads
          submit_ratings=true
          toolbar_layout=add_directory_action, add_files_action, -, cluster_action, -, autotag_action, analyze_action, browser_lookup_action, -, save_action, view_info_action, remove_action, -, cd_lookup_action, -, submit_acoustid_action
          toolbar_show_labels=true
          track_ars=true
          track_matching_threshold=0.4
          translate_album_titles=true
          translate_artist_names=true
          translate_artist_names_script_exception=false
          translate_from_sortname=false
          translate_track_titles=true
          translation_locales=@Variant(\0\0\0\t\0\0\0\x1\0\0\0\n\0\0\0\x4\0\x65\0n)
          ui_theme=dark
          update_check_days=7
          update_level=0
          use_adv_search_syntax=false
          use_genres=true
          use_proxy=false
          use_server_for_submission=false
          va_name=Various Artists
          wave_riff_info_encoding=windows-1252
          win_compat_replacements=@Variant(\0\0\0\b\0\0\0\a\0\0\0\x2\0\"\0\0\0\n\0\0\0\x2\0_\0\0\0\x2\0*\0\0\0\n\0\0\0\x2\0_\0\0\0\x2\0:\0\0\0\n\0\0\0\x2\0_\0\0\0\x2\0<\0\0\0\n\0\0\0\x2\0_\0\0\0\x2\0>\0\0\0\n\0\0\0\x2\0_\0\0\0\x2\0?\0\0\0\n\0\0\0\x2\0_\0\0\0\x2\0|\0\0\0\n\0\0\0\x2\0_)
          windows_compatibility=true
          windows_long_paths=false
          write_id3v1=true
          write_id3v23=false
          write_wave_riff_info=true
        '';
      };
    };
}
