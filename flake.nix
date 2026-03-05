{
  description = "My Universal RAM-Booting OS";

  inputs = {
    # The source of truth for packages
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # The tool that builds the ISO
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-generators, ... }: {
    # This defines a specific "build" target called 'ventoy-nix'
    packages.x86_64-linux.ventoy-demo = nixos-generators.nixosGenerate {
      system = "x86_64-linux";
      format = "iso";
      modules = [
        ({ pkgs, ... }: {
          # --- RAM OS SETTINGS ---
          boot.kernelParams = [ "copytoram" ];
          networking.networkmanager.enable = true;

          # --- USER DEFINITION ---
          users.users.nixos = {
            isNormalUser = true;
            extraGroups = [ "wheel" "networkmanager" ];
            # Password 'nixos' for sudo/login
            initialPassword = "nixos"; 
          };

          # --- PACKAGE LIST (Replacing your .txt lists) ---
          environment.systemPackages = with pkgs; [
            # Tools from your repo
            kitty fish neofetch mc git vim tmux rclone
            # Bug Bounty toolkit
            nmap ffuf gobuster dnsrecon
            # GUI for Hyprland demo
            hyprland waybar
          ];

          # --- THE "DOTFILE" MAPPING ---
          # This replaces your install.sh logic
          system.activationScripts.dotfiles.text = ''
            USER_HOME="/home/nixos"
            mkdir -p $USER_HOME/.config
            
            # Symlink from the 'Nix Store' (the ISO) to the RAM $HOME
            ln -sfn ${./config/hypr} $USER_HOME/.config/hypr
            ln -sfn ${./config/fish} $USER_HOME/.config/fish
            ln -sfn ${./shell/bashrc} $USER_HOME/.bashrc
            ln -sfn ${./vim/vimrc} $USER_HOME/.vimrc
            
            chown -R nixos:users $USER_HOME
          '';

          # --- AUTO-MOUNT EXTERNAL DATA ---
          # Looks for your USB partition labeled 'DATA'
          fileSystems."/home/nixos/work" = {
            device = "/dev/disk/by-label/DATA";
            fsType = "auto";
            options = [ "nofail" "user" ];
          };
        })
      ];
    };
  };
}
