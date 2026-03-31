{ ... }: {
  homebrew.casks = [
    "telegram"
    "firefox"
    "whatsapp"
  ];

  # T5 external ssd
  launchd.daemons.mount-t5 = {
    serviceConfig = {
      Label = "com.local.mount-t5";
      ProgramArguments = [ "/usr/sbin/diskutil" "mount" "T5" ];
      RunAtLoad = true;
    };
  };

  system.activationScripts.extraActivation.text = ''
    ln -sfn /Volumes/T5 /Users/tbrowne/T5
  '';
}
