{
  description = "My Ultimate RAM-Booting Security Lab";

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
          hardware.graphics.enable = true;
          hardware.nvidia = {
            modesetting.enable = true;
            open = false; 
            package = config.boot.kernelPackages.nvidiaPackages.stable;
          };

          # --- SECURITY & FIREWALL ---
          networking.firewall = {
            enable = true;
            allowedTCPPorts = [ 8080 4444 ];
          };
          
          boot.initrd.luks.devices."cryptdata" = {
            device = "/dev/disk/by-label/DATA"; 
            preLVM = true;
          };

          # --- USER & SUDO ---
          users.users.nixos = {
            isNormalUser = true;
            extraGroups = [ "wheel" "networkmanager" "video" ];
            initialPassword = "nixos"; 
          };

          security.sudo.extraRules = [{
            users = [ "nixos" ];
            commands = [{
              command = "/home/nixos/.local/bin/panic";
              options = [ "NOPASSWD" ];
            }];
          }];

          # --- PACKAGE LIST ---
          environment.systemPackages = with pkgs; [
            hyprland waybar kitty fish fastfetch mc git tmux rclone
            kate nano vim 
            burpsuite nmap metasploit ffuf gobuster subfinder amass waybackurls httpx chromium
          ];

          # --- THE "DOTFILE" MAPPING & AUTO-GENERATED CONFIGS ---
          system.activationScripts.dotfiles.text = ''
            USER_HOME="/home/nixos"
            mkdir -p $USER_HOME/.config/waybar
            mkdir -p $USER_HOME/.config/hypr
            mkdir -p $USER_HOME/.local/bin

            # 1. Symlinks from your existing Repo folders (Failsafe)
            [ -d ${./config/hypr} ] && ln -sfn ${./config/hypr} $USER_HOME/.config/hypr
            [ -f ${./shell/bashrc} ] && ln -sfn ${./shell/bashrc} $USER_HOME/.bashrc

            # 2. GENERATE PANIC SCRIPT
            cat << 'EOF' > $USER_HOME/.local/bin/panic
            #!/bin/sh
            sync
            echo 1 > /proc/sys/kernel/sysrq
            echo b > /proc/sys/kernel/sysrq
            EOF
            chmod +x $USER_HOME/.local/bin/panic

            # 3. GENERATE HYPRLAND CONFIG (Auto-starts Waybar and Fastfetch)
            cat << 'EOF' > $USER_HOME/.config/hypr/hyprland.conf
            monitor=,preferred,auto,1
            exec-once = waybar
            exec-once = kitty -e fish -c "fastfetch; exec fish"
            env = WLR_NO_HARDWARE_CURSORS,1
            env = LIBVA_DRIVER_NAME,nvidia
            input { kb_layout = us }
            general { gaps_in = 5; gaps_out = 10; border_size = 2; col.active_border = rgba(33ccffee) }
            # Simple exit bind: Super + M
            bind = SUPER, M, exit, 
            EOF

            # 4. GENERATE WAYBAR CONFIG
            cat << 'EOF' > $USER_HOME/.config/waybar/config
            {
                "layer": "top",
                "modules-left": ["hyprland/workspaces"],
                "modules-center": ["clock"],
                "modules-right": ["cpu", "memory", "network", "custom/panic"],
                "custom/panic": {
                    "format": " 💀 PANIC ",
                    "on-click": "sudo /home/nixos/.local/bin/panic",
                    "tooltip": false
                }
            }
            EOF

            # 5. GENERATE WAYBAR STYLE
            cat << 'EOF' > $USER_HOME/.config/waybar/style.css
            window#waybar { background: rgba(43, 48, 59, 0.7); color: #ffffff; font-family: sans-serif; }
            #custom-panic { background: #ff5555; color: white; font-weight: bold; padding: 0 10px; border-radius: 5px; margin: 5px; }
            EOF

            chown -R nixos:users $USER_HOME
          '';

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
