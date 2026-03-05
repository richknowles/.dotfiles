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
    packages.x86_64-linux.ventoy-nix = nixos-generators.nixosGenerate {
      system = "x86_64-linux";
      format = "iso";
      modules = [
        ({ pkgs, ... }: {
          # 1. Add this to fix the 'stateVersion' warning
          system.stateVersion = "24.11"; 

          boot.kernelParams = [ "copytoram" ];
          networking.networkmanager.enable = true;

          # --- USER DEFINITION ---
          users.users.nixos = {
            isNormalUser = true;
            extraGroups = [ "wheel" "networkmanager" ];
            initialPassword = "nixos"; 
          };

          # --- PACKAGE LIST ---
          environment.systemPackages = with pkgs; [
            kitty fish fastfetch mc git vim tmux rclone # Changed neofetch to fastfetch
            nmap ffuf gobuster dnsrecon
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
