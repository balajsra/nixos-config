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
          fladder
          aegisub
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
      ...
    }:
    {
      config = lib.mkIf (osConfig.features.media.audio.enable) {
        home.packages = with pkgs; [
          gimp
          ristretto
        ];
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
        home.packages = with pkgs; [
          picard
        ];

        xdg.configFile."MusicBrainz/Picard-base.ini".text = ''
          [setting]
          aac_save_ape=true
          ac3_save_ape=true
          acoustid_apikey=
          acoustid_fpcalc=
          analyze_new_files=false
          artist_locales=@Variant(\0\0\0\t\0\0\0\x1\0\0\0\n\0\0\0\x4\0\x65\0n)
          artists_genres=false
          ascii_filenames=false
          browser_integration=true
          browser_integration_localhost_only=true
          browser_integration_port=8000
          builtin_search=true
          ca_providers=@Variant(\0\0\0\x7f\0\0\0\xePyQt_PyObject\0\0\0\0#\x80\x4\x95\x18\0\0\0\0\0\0\0\x8c\x11\x43over Art Archive\x94\x88\x86\x94.), @Variant(\0\0\0\x7f\0\0\0\xePyQt_PyObject\0\0\0\0\"\x80\x4\x95\x17\0\0\0\0\0\0\0\x8c\x10UrlRelationships\x94\x88\x86\x94.), @Variant(\0\0\0\x7f\0\0\0\xePyQt_PyObject\0\0\0\0!\x80\x4\x95\x16\0\0\0\0\0\0\0\x8c\xf\x43\x61\x61ReleaseGroup\x94\x88\x86\x94.), @Variant(\0\0\0\x7f\0\0\0\xePyQt_PyObject\0\0\0\0\x1d\x80\x4\x95\x12\0\0\0\0\0\0\0\x8c\vLocal Files\x94\x88\x86\x94.)
          caa_approved_only=false
          caa_image_size=500
          caa_image_types=@Variant(\0\0\0\t\0\0\0\x1\0\0\0\n\0\0\0\n\0\x66\0r\0o\0n\0t)
          caa_image_types_to_omit=matrix/runout, raw/unedited, watermark
          caa_restrict_image_types=true
          cd_lookup_device=/dev/cdrom
          check_for_plugin_updates=false
          check_for_updates=false
          cluster_lookup_threshold=0.7
          cluster_new_files=false
          completeness_ignore_data=false
          completeness_ignore_pregap=false
          completeness_ignore_silence=false
          completeness_ignore_videos=false
          convert_punctuation=false
          cover_image_filename=cover
          delete_empty_dirs=true
          dont_write_tags=false
          embed_only_one_front_image=true
          enable_ratings=false
          enable_tagger_scripts=true
          enabled_plugins=@Invalid()
          file_lookup_threshold=0.7
          file_renaming_scripts="@Variant(\0\0\0\b\0\0\0\x3\0\0\0\x10\0P\0r\0\x65\0s\0\x65\0t\0 \0\x33\0\0\0\b\0\0\0\t\0\0\0\xe\0v\0\x65\0r\0s\0i\0o\0n\0\0\0\n\0\0\0\x6\0\x31\0.\0\x30\0\0\0\n\0t\0i\0t\0l\0\x65\0\0\0\n\0\0\0\x8c\0P\0r\0\x65\0s\0\x65\0t\0 \0\x33\0:\0 \0[\0\x61\0l\0\x62\0u\0m\0 \0\x61\0r\0t\0i\0s\0t\0]\0/\0[\0\x61\0l\0\x62\0u\0m\0]\0/\0[\0\x64\0i\0s\0\x63\0 \0\x61\0n\0\x64\0 \0t\0r\0\x61\0\x63\0k\0 \0#\0]\0 \0[\0\x61\0r\0t\0i\0s\0t\0]\0 \0-\0 \0[\0t\0i\0t\0l\0\x65\0]\0\0\0.\0s\0\x63\0r\0i\0p\0t\0_\0l\0\x61\0n\0g\0u\0\x61\0g\0\x65\0_\0v\0\x65\0r\0s\0i\0o\0n\0\0\0\n\0\0\0\x6\0\x31\0.\0\x30\0\0\0\f\0s\0\x63\0r\0i\0p\0t\0\0\0\n\0\0\x1\x94\0$\0i\0\x66\0\x32\0(\0%\0\x61\0l\0\x62\0u\0m\0\x61\0r\0t\0i\0s\0t\0%\0,\0%\0\x61\0r\0t\0i\0s\0t\0%\0)\0/\0\n\0$\0i\0\x66\0(\0%\0\x61\0l\0\x62\0u\0m\0\x61\0r\0t\0i\0s\0t\0%\0,\0%\0\x61\0l\0\x62\0u\0m\0%\0/\0,\0)\0\n\0$\0i\0\x66\0(\0$\0g\0t\0(\0%\0t\0o\0t\0\x61\0l\0\x64\0i\0s\0\x63\0s\0%\0,\0\x31\0)\0,\0%\0\x64\0i\0s\0\x63\0n\0u\0m\0\x62\0\x65\0r\0%\0-\0,\0)\0\n\0$\0i\0\x66\0(\0$\0\x61\0n\0\x64\0(\0%\0\x61\0l\0\x62\0u\0m\0\x61\0r\0t\0i\0s\0t\0%\0,\0%\0t\0r\0\x61\0\x63\0k\0n\0u\0m\0\x62\0\x65\0r\0%\0)\0,\0$\0n\0u\0m\0(\0%\0t\0r\0\x61\0\x63\0k\0n\0u\0m\0\x62\0\x65\0r\0%\0,\0\x32\0)\0 \0,\0)\0\n\0$\0i\0\x66\0(\0%\0_\0m\0u\0l\0t\0i\0\x61\0r\0t\0i\0s\0t\0%\0,\0%\0\x61\0r\0t\0i\0s\0t\0%\0 \0-\0 \0,\0)\0\n\0%\0t\0i\0t\0l\0\x65\0%\0\0\0\xe\0l\0i\0\x63\0\x65\0n\0s\0\x65\0\0\0\n\0\0\0\x38\0G\0N\0U\0 \0P\0u\0\x62\0l\0i\0\x63\0 \0L\0i\0\x63\0\x65\0n\0s\0\x65\0 \0v\0\x65\0r\0s\0i\0o\0n\0 \0\x32\0\0\0\x18\0l\0\x61\0s\0t\0_\0u\0p\0\x64\0\x61\0t\0\x65\0\x64\0\0\0\n\0\0\0.\0\x32\0\x30\0\x32\0\x31\0-\0\x30\0\x34\0-\0\x31\0\x32\0 \0\x32\0\x31\0:\0\x33\0\x30\0:\0\x30\0\x30\0 \0U\0T\0\x43\0\0\0\x4\0i\0\x64\0\0\0\n\0\0\0\x10\0P\0r\0\x65\0s\0\x65\0t\0 \0\x33\0\0\0\x16\0\x64\0\x65\0s\0\x63\0r\0i\0p\0t\0i\0o\0n\0\0\0\n\0\0\0\xd2\0T\0h\0i\0s\0 \0p\0r\0\x65\0s\0\x65\0t\0 \0\x65\0x\0\x61\0m\0p\0l\0\x65\0 \0\x66\0i\0l\0\x65\0 \0n\0\x61\0m\0i\0n\0g\0 \0s\0\x63\0r\0i\0p\0t\0 \0\x64\0o\0\x65\0s\0 \0n\0o\0t\0 \0r\0\x65\0q\0u\0i\0r\0\x65\0 \0\x61\0n\0y\0 \0s\0p\0\x65\0\x63\0i\0\x61\0l\0 \0s\0\x65\0t\0t\0i\0n\0g\0s\0,\0 \0t\0\x61\0g\0g\0i\0n\0g\0 \0s\0\x63\0r\0i\0p\0t\0s\0 \0o\0r\0 \0p\0l\0u\0g\0i\0n\0s\0.\0\0\0\f\0\x61\0u\0t\0h\0o\0r\0\0\0\n\0\0\0\x46\0M\0u\0s\0i\0\x63\0\x42\0r\0\x61\0i\0n\0z\0 \0P\0i\0\x63\0\x61\0r\0\x64\0 \0\x44\0\x65\0v\0\x65\0l\0o\0p\0m\0\x65\0n\0t\0 \0T\0\x65\0\x61\0m\0\0\0\x10\0P\0r\0\x65\0s\0\x65\0t\0 \0\x32\0\0\0\b\0\0\0\t\0\0\0\xe\0v\0\x65\0r\0s\0i\0o\0n\0\0\0\n\0\0\0\x6\0\x31\0.\0\x30\0\0\0\n\0t\0i\0t\0l\0\x65\0\0\0\n\0\0\0\x66\0P\0r\0\x65\0s\0\x65\0t\0 \0\x32\0:\0 \0[\0\x61\0l\0\x62\0u\0m\0 \0\x61\0r\0t\0i\0s\0t\0]\0/\0[\0\x61\0l\0\x62\0u\0m\0]\0/\0[\0t\0r\0\x61\0\x63\0k\0 \0#\0]\0.\0 \0[\0t\0i\0t\0l\0\x65\0]\0\0\0.\0s\0\x63\0r\0i\0p\0t\0_\0l\0\x61\0n\0g\0u\0\x61\0g\0\x65\0_\0v\0\x65\0r\0s\0i\0o\0n\0\0\0\n\0\0\0\x6\0\x31\0.\0\x30\0\0\0\f\0s\0\x63\0r\0i\0p\0t\0\0\0\n\0\0\0\\\0%\0\x61\0l\0\x62\0u\0m\0\x61\0r\0t\0i\0s\0t\0%\0/\0\n\0%\0\x61\0l\0\x62\0u\0m\0%\0/\0\n\0%\0t\0r\0\x61\0\x63\0k\0n\0u\0m\0\x62\0\x65\0r\0%\0.\0 \0%\0t\0i\0t\0l\0\x65\0%\0\0\0\xe\0l\0i\0\x63\0\x65\0n\0s\0\x65\0\0\0\n\0\0\0\x38\0G\0N\0U\0 \0P\0u\0\x62\0l\0i\0\x63\0 \0L\0i\0\x63\0\x65\0n\0s\0\x65\0 \0v\0\x65\0r\0s\0i\0o\0n\0 \0\x32\0\0\0\x18\0l\0\x61\0s\0t\0_\0u\0p\0\x64\0\x61\0t\0\x65\0\x64\0\0\0\n\0\0\0.\0\x32\0\x30\0\x32\0\x31\0-\0\x30\0\x34\0-\0\x31\0\x32\0 \0\x32\0\x31\0:\0\x33\0\x30\0:\0\x30\0\x30\0 \0U\0T\0\x43\0\0\0\x4\0i\0\x64\0\0\0\n\0\0\0\x10\0P\0r\0\x65\0s\0\x65\0t\0 \0\x32\0\0\0\x16\0\x64\0\x65\0s\0\x63\0r\0i\0p\0t\0i\0o\0n\0\0\0\n\0\0\0\xd2\0T\0h\0i\0s\0 \0p\0r\0\x65\0s\0\x65\0t\0 \0\x65\0x\0\x61\0m\0p\0l\0\x65\0 \0\x66\0i\0l\0\x65\0 \0n\0\x61\0m\0i\0n\0g\0 \0s\0\x63\0r\0i\0p\0t\0 \0\x64\0o\0\x65\0s\0 \0n\0o\0t\0 \0r\0\x65\0q\0u\0i\0r\0\x65\0 \0\x61\0n\0y\0 \0s\0p\0\x65\0\x63\0i\0\x61\0l\0 \0s\0\x65\0t\0t\0i\0n\0g\0s\0,\0 \0t\0\x61\0g\0g\0i\0n\0g\0 \0s\0\x63\0r\0i\0p\0t\0s\0 \0o\0r\0 \0p\0l\0u\0g\0i\0n\0s\0.\0\0\0\f\0\x61\0u\0t\0h\0o\0r\0\0\0\n\0\0\0\x46\0M\0u\0s\0i\0\x63\0\x42\0r\0\x61\0i\0n\0z\0 \0P\0i\0\x63\0\x61\0r\0\x64\0 \0\x44\0\x65\0v\0\x65\0l\0o\0p\0m\0\x65\0n\0t\0 \0T\0\x65\0\x61\0m\0\0\0\x10\0P\0r\0\x65\0s\0\x65\0t\0 \0\x31\0\0\0\b\0\0\0\t\0\0\0\xe\0v\0\x65\0r\0s\0i\0o\0n\0\0\0\n\0\0\0\x6\0\x31\0.\0\x30\0\0\0\n\0t\0i\0t\0l\0\x65\0\0\0\n\0\0\0H\0P\0r\0\x65\0s\0\x65\0t\0 \0\x31\0:\0 \0\x44\0\x65\0\x66\0\x61\0u\0l\0t\0 \0\x66\0i\0l\0\x65\0 \0n\0\x61\0m\0i\0n\0g\0 \0s\0\x63\0r\0i\0p\0t\0\0\0.\0s\0\x63\0r\0i\0p\0t\0_\0l\0\x61\0n\0g\0u\0\x61\0g\0\x65\0_\0v\0\x65\0r\0s\0i\0o\0n\0\0\0\n\0\0\0\x6\0\x31\0.\0\x30\0\0\0\f\0s\0\x63\0r\0i\0p\0t\0\0\0\n\0\0\x1\xea\0$\0i\0\x66\0\x32\0(\0%\0\x61\0l\0\x62\0u\0m\0\x61\0r\0t\0i\0s\0t\0%\0,\0%\0\x61\0r\0t\0i\0s\0t\0%\0)\0/\0\n\0$\0i\0\x66\0(\0%\0\x61\0l\0\x62\0u\0m\0\x61\0r\0t\0i\0s\0t\0%\0,\0%\0\x61\0l\0\x62\0u\0m\0%\0/\0,\0)\0\n\0$\0i\0\x66\0(\0$\0g\0t\0(\0%\0t\0o\0t\0\x61\0l\0\x64\0i\0s\0\x63\0s\0%\0,\0\x31\0)\0,\0$\0i\0\x66\0(\0$\0g\0t\0(\0%\0t\0o\0t\0\x61\0l\0\x64\0i\0s\0\x63\0s\0%\0,\0\x39\0)\0,\0$\0n\0u\0m\0(\0%\0\x64\0i\0s\0\x63\0n\0u\0m\0\x62\0\x65\0r\0%\0,\0\x32\0)\0,\0%\0\x64\0i\0s\0\x63\0n\0u\0m\0\x62\0\x65\0r\0%\0)\0-\0,\0)\0$\0i\0\x66\0(\0$\0\x61\0n\0\x64\0(\0%\0\x61\0l\0\x62\0u\0m\0\x61\0r\0t\0i\0s\0t\0%\0,\0%\0t\0r\0\x61\0\x63\0k\0n\0u\0m\0\x62\0\x65\0r\0%\0)\0,\0$\0n\0u\0m\0(\0%\0t\0r\0\x61\0\x63\0k\0n\0u\0m\0\x62\0\x65\0r\0%\0,\0\x32\0)\0 \0,\0)\0$\0i\0\x66\0(\0%\0_\0m\0u\0l\0t\0i\0\x61\0r\0t\0i\0s\0t\0%\0,\0%\0\x61\0r\0t\0i\0s\0t\0%\0 \0-\0 \0,\0)\0%\0t\0i\0t\0l\0\x65\0%\0\0\0\xe\0l\0i\0\x63\0\x65\0n\0s\0\x65\0\0\0\n\0\0\0\x38\0G\0N\0U\0 \0P\0u\0\x62\0l\0i\0\x63\0 \0L\0i\0\x63\0\x65\0n\0s\0\x65\0 \0v\0\x65\0r\0s\0i\0o\0n\0 \0\x32\0\0\0\x18\0l\0\x61\0s\0t\0_\0u\0p\0\x64\0\x61\0t\0\x65\0\x64\0\0\0\n\0\0\0.\0\x32\0\x30\0\x31\0\x39\0-\0\x30\0\x38\0-\0\x30\0\x35\0 \0\x31\0\x33\0:\0\x34\0\x30\0:\0\x30\0\x30\0 \0U\0T\0\x43\0\0\0\x4\0i\0\x64\0\0\0\n\0\0\0\x10\0P\0r\0\x65\0s\0\x65\0t\0 \0\x31\0\0\0\x16\0\x64\0\x65\0s\0\x63\0r\0i\0p\0t\0i\0o\0n\0\0\0\n\0\0\0\xd2\0T\0h\0i\0s\0 \0p\0r\0\x65\0s\0\x65\0t\0 \0\x65\0x\0\x61\0m\0p\0l\0\x65\0 \0\x66\0i\0l\0\x65\0 \0n\0\x61\0m\0i\0n\0g\0 \0s\0\x63\0r\0i\0p\0t\0 \0\x64\0o\0\x65\0s\0 \0n\0o\0t\0 \0r\0\x65\0q\0u\0i\0r\0\x65\0 \0\x61\0n\0y\0 \0s\0p\0\x65\0\x63\0i\0\x61\0l\0 \0s\0\x65\0t\0t\0i\0n\0g\0s\0,\0 \0t\0\x61\0g\0g\0i\0n\0g\0 \0s\0\x63\0r\0i\0p\0t\0s\0 \0o\0r\0 \0p\0l\0u\0g\0i\0n\0s\0.\0\0\0\f\0\x61\0u\0t\0h\0o\0r\0\0\0\n\0\0\0\x46\0M\0u\0s\0i\0\x63\0\x42\0r\0\x61\0i\0n\0z\0 \0P\0i\0\x63\0\x61\0r\0\x64\0 \0\x44\0\x65\0v\0\x65\0l\0o\0p\0m\0\x65\0n\0t\0 \0T\0\x65\0\x61\0m)"
          file_save_warning=true
          filebrowser_horizontal_autoscroll=true
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
          interface_colors=@Variant(\0\0\0\b\0\0\0\n\0\0\0\"\0t\0\x61\0g\0s\0t\0\x61\0t\0u\0s\0_\0r\0\x65\0m\0o\0v\0\x65\0\x64\0\0\0\n\0\0\0\xe\0#\0\x66\0\x66\0\x30\0\x30\0\x30\0\x30\0\0\0\"\0t\0\x61\0g\0s\0t\0\x61\0t\0u\0s\0_\0\x63\0h\0\x61\0n\0g\0\x65\0\x64\0\0\0\n\0\0\0\xe\0#\0\x62\0\x38\0\x38\0\x36\0\x30\0\x62\0\0\0\x1e\0t\0\x61\0g\0s\0t\0\x61\0t\0u\0s\0_\0\x61\0\x64\0\x64\0\x65\0\x64\0\0\0\n\0\0\0\xe\0#\0\x30\0\x30\0\x38\0\x30\0\x30\0\x30\0\0\0\x16\0l\0o\0g\0_\0w\0\x61\0r\0n\0i\0n\0g\0\0\0\n\0\0\0\xe\0#\0\x66\0\x66\0\x38\0\x63\0\x30\0\x30\0\0\0\x10\0l\0o\0g\0_\0i\0n\0\x66\0o\0\0\0\n\0\0\0\xe\0#\0\x30\0\x30\0\x30\0\x30\0\x30\0\x30\0\0\0\x12\0l\0o\0g\0_\0\x65\0r\0r\0o\0r\0\0\0\n\0\0\0\xe\0#\0\x66\0\x66\0\x30\0\x30\0\x30\0\x30\0\0\0\x12\0l\0o\0g\0_\0\x64\0\x65\0\x62\0u\0g\0\0\0\n\0\0\0\xe\0#\0\x38\0\x30\0\x30\0\x30\0\x38\0\x30\0\0\0\x18\0\x65\0n\0t\0i\0t\0y\0_\0s\0\x61\0v\0\x65\0\x64\0\0\0\n\0\0\0\xe\0#\0\x30\0\x30\0\x61\0\x61\0\x30\0\x30\0\0\0\x1c\0\x65\0n\0t\0i\0t\0y\0_\0p\0\x65\0n\0\x64\0i\0n\0g\0\0\0\n\0\0\0\xe\0#\0\x38\0\x30\0\x38\0\x30\0\x38\0\x30\0\0\0\x18\0\x65\0n\0t\0i\0t\0y\0_\0\x65\0r\0r\0o\0r\0\0\0\n\0\0\0\xe\0#\0\x63\0\x38\0\x30\0\x30\0\x30\0\x30)
          itunes_compatible_grouping=false
          join_genres=
          list_of_scripts="@Variant(\0\0\0\t\0\0\0\x1\0\0\0\x7f\0\0\0\xePyQt_PyObject\0\0\0\x1N\x80\x4\x95\x43\x1\0\0\0\0\0\0(K\0\x8c\tNavidrome\x94\x88X*\x1\0\0# Multiple artists\n$setmulti(albumartists,%_albumartists%)\n$setmulti(albumartistssort,%_albumartists_sort%)\n$setmulti(artistssort,%_artists_sort%)\n\n# Release and Original dates\n$set(releasedate,%date%)\n$set(date,%_recording_firstreleasedate%)\n$set(originaldate,%originaldate%)\n$delete(originalyear)\x94t\x94.)"
          local_cover_regex=^(?:cover|folder|albumart)(.*)\\.(?:jpe?g|png|gif|tiff?|webp)$
          max_genres=5
          min_genre_usage=90
          move_additional_files=true
          move_additional_files_pattern=*.jpg *.png
          move_files=true
          move_files_to=/mnt/mediaserver/Music
          network_transfer_timeout_seconds=30
          only_my_genres=false
          preferred_release_countries=@Variant(\0\0\0\t\0\0\0\x1\0\0\0\n\0\0\0\x4\0U\0S)
          preferred_release_formats=Digital Media, CD
          preserve_images=false
          preserve_timestamps=false
          preserved_tags=@Invalid()
          proxy_password=
          proxy_server_host=
          proxy_server_port=80
          proxy_type=http
          proxy_username=
          query_limit=50
          quit_confirmation=true
          rating_user_email=users@musicbrainz.org
          recursively_add_files=true
          release_ars=true
          release_type_scores=@Variant(\0\0\0\x7f\0\0\0\xePyQt_PyObject\0\0\0\0\x1f\x80\x4\x95\x14\0\0\0\0\0\0\0\x8c\x5\x41lbum\x94G?\xe0\0\0\0\0\0\0\x86\x94.), @Variant(\0\0\0\x7f\0\0\0\xePyQt_PyObject\0\0\0\0 \x80\x4\x95\x15\0\0\0\0\0\0\0\x8c\x6Single\x94G?\xe0\0\0\0\0\0\0\x86\x94.), @Variant(\0\0\0\x7f\0\0\0\xePyQt_PyObject\0\0\0\0\x1c\x80\x4\x95\x11\0\0\0\0\0\0\0\x8c\x2\x45P\x94G?\xe0\0\0\0\0\0\0\x86\x94.), @Variant(\0\0\0\x7f\0\0\0\xePyQt_PyObject\0\0\0\0\x1f\x80\x4\x95\x14\0\0\0\0\0\0\0\x8c\x5Other\x94G?\xe0\0\0\0\0\0\0\x86\x94.), @Variant(\0\0\0\x7f\0\0\0\xePyQt_PyObject\0\0\0\0#\x80\x4\x95\x18\0\0\0\0\0\0\0\x8c\tBroadcast\x94G?\xe0\0\0\0\0\0\0\x86\x94.), @Variant(\0\0\0\x7f\0\0\0\xePyQt_PyObject\0\0\0\0%\x80\x4\x95\x1a\0\0\0\0\0\0\0\x8c\vAudio drama\x94G?\xe0\0\0\0\0\0\0\x86\x94.), @Variant(\0\0\0\x7f\0\0\0\xePyQt_PyObject\0\0\0\0#\x80\x4\x95\x18\0\0\0\0\0\0\0\x8c\tAudiobook\x94G?\xe0\0\0\0\0\0\0\x86\x94.), @Variant(\0\0\0\x7f\0\0\0\xePyQt_PyObject\0\0\0\0%\x80\x4\x95\x1a\0\0\0\0\0\0\0\x8c\vCompilation\x94G?\xe0\0\0\0\0\0\0\x86\x94.), @Variant(\0\0\0\x7f\0\0\0\xePyQt_PyObject\0\0\0\0 \x80\x4\x95\x15\0\0\0\0\0\0\0\x8c\x6\x44J-mix\x94G?\xe0\0\0\0\0\0\0\x86\x94.), @Variant(\0\0\0\x7f\0\0\0\xePyQt_PyObject\0\0\0\0\x1e\x80\x4\x95\x13\0\0\0\0\0\0\0\x8c\x4\x44\x65mo\x94G?\xe0\0\0\0\0\0\0\x86\x94.), @Variant(\0\0\0\x7f\0\0\0\xePyQt_PyObject\0\0\0\0)\x80\x4\x95\x1e\0\0\0\0\0\0\0\x8c\xf\x46ield recording\x94G?\xe0\0\0\0\0\0\0\x86\x94.), @Variant(\0\0\0\x7f\0\0\0\xePyQt_PyObject\0\0\0\0#\x80\x4\x95\x18\0\0\0\0\0\0\0\x8c\tInterview\x94G?\xe0\0\0\0\0\0\0\x86\x94.), @Variant(\0\0\0\x7f\0\0\0\xePyQt_PyObject\0\0\0\0\x1e\x80\x4\x95\x13\0\0\0\0\0\0\0\x8c\x4Live\x94G?\xe0\0\0\0\0\0\0\x86\x94.), @Variant(\0\0\0\x7f\0\0\0\xePyQt_PyObject\0\0\0\0(\x80\x4\x95\x1d\0\0\0\0\0\0\0\x8c\xeMixtape/Street\x94G?\xe0\0\0\0\0\0\0\x86\x94.), @Variant(\0\0\0\x7f\0\0\0\xePyQt_PyObject\0\0\0\0\x1f\x80\x4\x95\x14\0\0\0\0\0\0\0\x8c\x5Remix\x94G?\xe0\0\0\0\0\0\0\x86\x94.), @Variant(\0\0\0\x7f\0\0\0\xePyQt_PyObject\0\0\0\0$\x80\x4\x95\x19\0\0\0\0\0\0\0\x8c\nSoundtrack\x94G?\xe0\0\0\0\0\0\0\x86\x94.), @Variant(\0\0\0\x7f\0\0\0\xePyQt_PyObject\0\0\0\0$\x80\x4\x95\x19\0\0\0\0\0\0\0\x8c\nSpokenword\x94G?\xe0\0\0\0\0\0\0\x86\x94.)
          remove_ape_from_aac=false
          remove_ape_from_ac3=false
          remove_ape_from_mp3=false
          remove_id3_from_flac=false
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
          selected_file_naming_script_id=Preset 3
          server_host=musicbrainz.org
          server_port=443
          show_menu_icons=true
          show_new_user_dialog=false
          standardize_artists=true
          standardize_instruments=true
          starting_directory=false
          starting_directory_path=/home/sravan
          submit_ratings=true
          toolbar_layout=add_directory_action, add_files_action, separator, cluster_action, separator, autotag_action, analyze_action, browser_lookup_action, separator, save_action, view_info_action, remove_action, separator, cd_lookup_action, separator, submit_acoustid_action
          toolbar_multiselect=false
          toolbar_show_labels=true
          track_ars=false
          track_matching_threshold=0.4
          translate_artist_names=true
          translate_artist_names_script_exception=false
          ui_language=
          ui_theme=system
          update_check_days=7
          update_level=0
          use_adv_search_syntax=false
          use_genres=false
          use_proxy=false
          use_server_for_submission=false
          va_name=Various Artists
          wave_riff_info_encoding=windows-1252
          win_compat_replacements=@Variant(\0\0\0\b\0\0\0\a\0\0\0\x2\0|\0\0\0\n\0\0\0\x2\0_\0\0\0\x2\0?\0\0\0\n\0\0\0\x2\0_\0\0\0\x2\0>\0\0\0\n\0\0\0\x2\0_\0\0\0\x2\0<\0\0\0\n\0\0\0\x2\0_\0\0\0\x2\0:\0\0\0\n\0\0\0\x2\0_\0\0\0\x2\0*\0\0\0\n\0\0\0\x2\0_\0\0\0\x2\0\"\0\0\0\n\0\0\0\x2\0_)
          windows_compatibility=true
          windows_long_paths=false
          write_id3v1=true
          write_id3v23=false
          write_wave_riff_info=true
        '';

        # Override default picard desktop entry to load custom base config
        xdg.desktopEntries."org.musicbrainz.Picard" = {
          name = "MusicBrainz Picard";
          genericName = "Tag Editor";
          comment = "Tag your music files with MusicBrainz metadata";
          exec = "sh -c \"${pkgs.picard}/bin/picard -c \\\\$HOME/.config/MusicBrainz/Picard-base.ini \\\\$@\" _ %U";
          icon = "org.musicbrainz.Picard";
          mimeType = [
            "application/x-flac"
            "audio/mp4"
            "audio/mpeg"
            "audio/ogg"
            "audio/x-vorbis+ogg"
            "inode/directory"
          ];
          categories = [
            "AudioVideo"
            "Audio"
            "Qt"
          ];
          terminal = false;
        };
      };
    };
}
