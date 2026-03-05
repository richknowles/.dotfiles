{
  description = "My Universal RAM-Booting OS with Nvidia Support";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-generators, ... }: {
    packages.x86_64-linux.ventoy-nix = nixos-generators.nixosGenerate {
      system = "x86_64-linux";
      format = "iso";
      modules = [
        ({ pkgs, config, ... }: {
          system.stateVersion = "24.11"; 

          # --- KERNEL & BOOT ---
          boot.kernelParams = [ "copytoram" ];
          networking.networkmanager.enable = true;

          # --- NVIDIA & GRAPHICS ---
          # 1. Allow unfree for the proprietary driver
          nixpkgs.config.allowUnfree = true;
          
          # 2. Load the driver
          services.xserver.videoDrivers = [ "nvidia" ];
          
          hardware.graphics = {
            enable = true;
            enable32Bit = true;
          };

          hardware.nvidia = {
            modesetting.enable = true;
            powerManagement.enable = false;
            open = false; # Set to true only if you want the experimental open-source kernel module
            nvidiaSettings = true;
            package = config.boot.kernelPackages.nvidiaPackages.stable;
          };

          # --- USER DEFINITION ---
          users.users.nixos = {
            isNormalUser = true;
            extraGroups = [ "wheel" "networkmanager" "video" ];
            initialPassword = "nixos"; 
          };

          # --- PACKAGE LIST ---
          environment.systemPackages = with pkgs; [
            kitty fish fastfetch mc git vim tmux rclone 
            nmap ffuf gobuster dnsrecon
            hyprland waybar
          ];

          # --- THE "DOTFILE" MAPPING ---
          system.activationScripts.dotfiles.text = ''
            USER_HOME="/home/nixos"
            mkdir -p $USER_HOME/.config
            
            # Symlinks from the Nix Store to the RAM $HOME
            ln -sfn ${./config/hypr} $USER_HOME/.config/hypr
            ln -sfn ${./config/fish} $USER_HOME/.config/fish
            ln -sfn ${./shell/bashrc} $USER_HOME/.bashrc
            ln -sfn ${./vim/vimrc} $USER_HOME/.vimrc
            
            chown -R nixos:users $USER_HOME
          '';

          # --- AUTO-MOUNT EXTERNAL DATA ---
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
