{
  description = "Rich's Ultimate RAM-Booting Security Lab";

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
          nixpkgs.config.allowUnfree = true;
          services.xserver.videoDrivers = [ "nvidia" ];
          hardware.graphics = {
            enable = true;
            enable32Bit = true;
          };
          hardware.nvidia = {
            modesetting.enable = true;
            powerManagement.enable = false;
            open = false; 
            nvidiaSettings = true;
            package = config.boot.kernelPackages.nvidiaPackages.stable;
          };

          # --- SECURITY & FIREWALL ---
          networking.firewall = {
            enable = true;
            allowedTCPPorts = [ 8080 4444 ];
            allowedUDPPorts = [ 4444 ];
            allowedTCPPortRanges = [ { from = 9000; to = 9010; } ];
          };
          
          # LUKS Decryption for your 'DATA' partition
          # Replace UUID with your actual UUID from 'blkid' later if label isn't enough
          boot.initrd.luks.devices."cryptdata" = {
            device = "/dev/disk/by-label/DATA"; 
            preLVM = true;
          };

          # --- USER DEFINITION ---
          users.users.nixos = {
            isNormalUser = true;
            extraGroups = [ "wheel" "networkmanager" "video" ];
            initialPassword = "nixos"; 
          };

          # Permit the Panic Script to run without password
          security.sudo.extraRules = [{
            users = [ "nixos" ];
            commands = [{
              command = "/home/nixos/.local/bin/panic";
              options = [ "NOPASSWD" ];
            }];
          }];

          # --- PACKAGE LIST ---
          environment.systemPackages = with pkgs; [
            # Core & UI
            hyprland waybar kitty fish fastfetch mc git tmux rclone
            # Editors
            kate nano vim 
            # Security Tools
            burpsuite nmap metasploit ffuf gobuster subfinder amass waybackurls httpx chromium
          ];

          # --- THE "DOTFILE" MAPPING & PANIC SCRIPT ---
          system.activationScripts.dotfiles.text = ''
            USER_HOME="/home/nixos"
            mkdir -p $USER_HOME/.config
            
            # Symlinks from the Nix Store to the RAM $HOME
            ln -sfn ${./config/hypr} $USER_HOME/.config/hypr
            ln -sfn ${./config/waybar} $USER_HOME/.config/waybar
            ln -sfn ${./config/fish} $USER_HOME/.config/fish
            ln -sfn ${./shell/bashrc} $USER_HOME/.bashrc
            ln -sfn ${./vim/vimrc} $USER_HOME/.vimrc
            
            # Create the Panic Script
            mkdir -p $USER_HOME/.local/bin
            cat << 'EOF' > $USER_HOME/.local/bin/panic
            #!/bin/sh
            sync
            echo 1 > /proc/sys/kernel/sysrq
            echo b > /proc/sys/kernel/sysrq
            EOF
            chmod +x $USER_HOME/.local/bin/panic

            chown -R nixos:users $USER_HOME
          '';

          # --- AUTO-MOUNT EXTERNAL DATA ---
          fileSystems."/home/nixos/work" = {
            device = "/dev/mapper/cryptdata";
            fsType = "ext4";
            options = [ "nofail" "user" ];
          };
        })
      ];
    };
  };
}
