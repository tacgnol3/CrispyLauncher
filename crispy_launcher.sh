#!/bin/bash

# Define ANSI color codes
RED='\e[31m'
BLACK_BG='\e[40m'
RESET='\e[0m'

# Define local directories
WAD_DIR="$HOME/Games/Doom + Doom 2"
HH_DIR="$HOME/Games/Heretic + Hexen"

# Define Steam directories for scanning
STEAM_DOOM_DIR="$HOME/.local/share/Steam/steamapps/common/Ultimate Doom/rerelease"
STEAM_HH_DIR="$HOME/.local/share/Steam/steamapps/common/Heretic + Hexen"

# Define mod sub-directories
DOOM1_PWAD_DIR="$WAD_DIR/doom1_mods"
DOOM2_PWAD_DIR="$WAD_DIR/doom2_mods"
HERETIC_PWAD_DIR="$HH_DIR/heretic_mods"
HEXEN_PWAD_DIR="$HH_DIR/hexen_mods"

# Create local directories if they do not exist
mkdir -p "$DOOM1_PWAD_DIR"
mkdir -p "$DOOM2_PWAD_DIR"
mkdir -p "$HERETIC_PWAD_DIR"
mkdir -p "$HEXEN_PWAD_DIR"

# ==========================================
#               WAD SCANNER
# ==========================================
DOOM_WADS=("doom.wad" "doom2.wad" "plutonia.wad" "tnt.wad" "sigil.wad" "sigil2.wad" "nerve.wad" "id1.wad")
HH_WADS=("heretic.wad" "heretic_fr.wad" "hexen.wad" "hexdd.wad" "hexen_vog.wad")

steam_detected=false
files_copied=false

echo -e "${BLACK_BG}\c"
clear
echo -e "${RED}${BLACK_BG}Scanning for base WADs...${RESET}"

# Scan and copy from Doom Steam directory
if [[ -d "$STEAM_DOOM_DIR" ]]; then
    steam_detected=true
    for wad in "${DOOM_WADS[@]}"; do
        if [[ -f "$STEAM_DOOM_DIR/$wad" && ! -f "$WAD_DIR/$wad" ]]; then
            echo "Copying $wad from Steam to local folder..."
            cp "$STEAM_DOOM_DIR/$wad" "$WAD_DIR/"
            files_copied=true
        fi
    done
fi

# Scan and copy from Heretic+Hexen Steam directory
if [[ -d "$STEAM_HH_DIR" ]]; then
    steam_detected=true
    for wad in "${HH_WADS[@]}"; do
        if [[ -f "$STEAM_HH_DIR/$wad" && ! -f "$HH_DIR/$wad" ]]; then
            echo "Copying $wad from Steam to local folder..."
            cp "$STEAM_HH_DIR/$wad" "$HH_DIR/"
            files_copied=true
        fi
    done
fi

# Check if any base WADs are already in the local directories
local_wads_detected=false
for wad in "${DOOM_WADS[@]}"; do
    if [[ -f "$WAD_DIR/$wad" ]]; then local_wads_detected=true; break; fi
done
if [[ "$local_wads_detected" == false ]]; then
    for wad in "${HH_WADS[@]}"; do
        if [[ -f "$HH_DIR/$wad" ]]; then local_wads_detected=true; break; fi
    done
fi

# Warnings and pauses before launching menu
if [[ "$steam_detected" == false && "$local_wads_detected" == false ]]; then
    echo -e "${RED}Warning: Steam installation folders not detected, and no base WADs found locally.${RESET}"
    echo "Please ensure you manually copy your base WADs into:"
    echo " - $WAD_DIR"
    echo " - $HH_DIR"
    echo "Press [Enter] to continue to the launcher..."
    read
elif [[ "$files_copied" == true ]]; then
    echo "Finished copying missing WADs."
    echo "Press [Enter] to start launcher..."
    read
fi

# ==========================================
#               INPUT FUNCTION
# ==========================================
# Captures input instantly. Supports multi-digit typing and instant ESC key escape.
get_choice() {
    local prompt="$1"
    local var_name="$2"
    local input=""
    local char=""
    echo -n "$prompt"

    while true; do
        read -r -s -n 1 char
        if [[ "$char" == $'\e' ]]; then
            # Consume any trailing characters from escape sequences (like arrow keys)
            while read -r -s -n 1 -t 0.01; do : ; done
            input="ESC"
            break
        elif [[ -z "$char" ]]; then
            break # Enter key pressed
        elif [[ "$char" == $'\x7f' || "$char" == $'\b' ]]; then
            # Backspace pressed
            if [ ${#input} -gt 0 ]; then
                input="${input%?}"
                echo -en "\b \b"
            fi
        else
            echo -n "$char"
            input="${input}${char}"
        fi
    done
    echo # Move to the next line after loop
    printf -v "$var_name" "%s" "$input"
}

# ==========================================
#               MAIN MENU
# ==========================================
while true; do
    echo -e "${BLACK_BG}\c"
    clear

    echo -e "${RED}${BLACK_BG}"
    echo "==================================================================================="
cat << 'EOF'
   ____      _                 _                           _
  / ___|_ __(_)___ _ __  _   _| |    __ _ _   _ _ __   ___| |__   ___ _ __
 | |   | '__| / __| '_ \| | | | |   / _` | | | | '_ \ / __| '_ \ / _ \ '__|
 | |___| |  | \__ \ |_) | |_| | |__| (_| | |_| | | | | (__| | | |  __/ |
  \____|_|  |_|___/ .__/ \__, |_____\__,_|\__,_|_| |_|\___|_| |_|\___|_|
                  |_|    |___/

EOF
    echo "==================================================================================="

    # Main menu options
    main_options=(
        "Doom + Doom II"
        "Heretic + Hexen"
    )

    # Print the main menu list
    for i in "${!main_options[@]}"; do
        echo "  $((i+1))) ${main_options[$i]}"
    done

    echo "  0) Cancel / Exit"
    echo "==================================================================================="

    get_choice "  Select a category: " main_choice
    echo -e "${RESET}"

    if [[ "$main_choice" == "0" ]]; then
        echo "Exiting launcher..."
        break
    elif [[ "$main_choice" == "ESC" ]]; then
        continue # Refresh menu instead of exiting
    elif [[ "$main_choice" =~ ^[0-9]+$ ]] && [ "$main_choice" -gt 0 ] && [ "$main_choice" -le "${#main_options[@]}" ]; then
        selected_main_action="${main_options[$((main_choice-1))]}"

        case "$selected_main_action" in
            "Doom + Doom II")
                # ==========================================
                #             DOOM + DOOM2 MENU
                # ==========================================
                while true; do
                    echo -e "${BLACK_BG}\c"
                    clear
                    echo -e "${RED}${BLACK_BG}"
                    echo "==================================================================================="
cat << 'EOF'
______  _____  _____ ___  ___         ______  _____  _____ ___  ___   _____  _____
|  _  \|  _  ||  _  ||  \/  |    _    |  _  \|  _  ||  _  ||  \/  |  |_   _||_   _|
| | | || | | || | | || .  . |  _| |_  | | | || | | || | | || .  . |    | |    | |
| | | || | | || | | || |\/| | |_   _| | | | || | | || | | || |\/| |    | |    | |
| |/ / \ \_/ /\ \_/ /| |  | |   |_|   | |/ / \ \_/ /\ \_/ /| |  | |   _| |_  _| |_
|___/   \___/  \___/ \_|  |_/         |___/   \___/  \___/ \_|  |_/   \___/  \___/

EOF
                    echo "==================================================================================="

                    doom_options=()

                    # Base games and expansions
                    [[ -f "$WAD_DIR/doom.wad" ]] && doom_options+=("Play DOOM (doom.wad)")
                    [[ -f "$WAD_DIR/doom2.wad" ]] && doom_options+=("Play DOOM II (doom2.wad)")
                    [[ -f "$WAD_DIR/plutonia.wad" ]] && doom_options+=("Play Plutonia (plutonia.wad)")
                    [[ -f "$WAD_DIR/tnt.wad" ]] && doom_options+=("Play TNT Evilution (tnt.wad)")
                    [[ -f "$WAD_DIR/doom.wad" && -f "$WAD_DIR/sigil.wad" ]] && doom_options+=("Play SIGIL (sigil.wad)")
                    [[ -f "$WAD_DIR/doom.wad" && -f "$WAD_DIR/sigil2.wad" ]] && doom_options+=("Play SIGIL II (sigil2.wad)")
                    [[ -f "$WAD_DIR/doom2.wad" && -f "$WAD_DIR/nerve.wad" ]] && doom_options+=("Play No Rest for the Living (nerve.wad)")
                    [[ -f "$WAD_DIR/doom2.wad" && -f "$WAD_DIR/id1.wad" ]] && doom_options+=("Play Legacy of Rust (id1.wad)")

                    # Custom WAD sub-menus
                    doom_options+=("DOOM 1 Custom WADs Menu")
                    doom_options+=("DOOM 2 Custom WADs Menu")

                    for i in "${!doom_options[@]}"; do
                        echo "  $((i+1))) ${doom_options[$i]}"
                    done

                    echo "  0) Return to Main Menu"
                    echo "==================================================================================="

                    get_choice "  Select an option: " doom_choice
                    echo -e "${RESET}"

                    if [[ "$doom_choice" == "0" || "$doom_choice" == "ESC" ]]; then
                        break
                    elif [[ "$doom_choice" =~ ^[0-9]+$ ]] && [ "$doom_choice" -gt 0 ] && [ "$doom_choice" -le "${#doom_options[@]}" ]; then
                        selected_doom_action="${doom_options[$((doom_choice-1))]}"

                        case "$selected_doom_action" in
                            "Play DOOM (doom.wad)") echo "Launching DOOM..."; crispy-doom -iwad "$WAD_DIR/doom.wad" ;;
                            "Play DOOM II (doom2.wad)") echo "Launching DOOM II..."; crispy-doom -iwad "$WAD_DIR/doom2.wad" ;;
                            "Play Plutonia (plutonia.wad)") echo "Launching Plutonia..."; crispy-doom -iwad "$WAD_DIR/plutonia.wad" ;;
                            "Play TNT Evilution (tnt.wad)") echo "Launching TNT Evilution..."; crispy-doom -iwad "$WAD_DIR/tnt.wad" ;;
                            "Play SIGIL (sigil.wad)") echo "Launching SIGIL..."; crispy-doom -iwad "$WAD_DIR/doom.wad" -file "$WAD_DIR/sigil.wad" ;;
                            "Play SIGIL II (sigil2.wad)") echo "Launching SIGIL II..."; crispy-doom -iwad "$WAD_DIR/doom.wad" -file "$WAD_DIR/sigil2.wad" ;;
                            "Play No Rest for the Living (nerve.wad)") echo "Launching No Rest for the Living..."; crispy-doom -iwad "$WAD_DIR/doom2.wad" -file "$WAD_DIR/nerve.wad" ;;
                            "Play Legacy of Rust (id1.wad)") echo "Launching Legacy of Rust..."; crispy-doom -iwad "$WAD_DIR/doom2.wad" -file "$WAD_DIR/id1.wad" ;;

                            "DOOM 1 Custom WADs Menu")
                                while true; do
                                    echo -e "${BLACK_BG}\c"; clear; echo -e "${RED}${BLACK_BG}"
                                    echo "==================================================================================="
                                    echo "                                DOOM 1 CUSTOM WADS"
                                    echo "==================================================================================="
                                    shopt -s nullglob; wad_files=("$DOOM1_PWAD_DIR"/*.wad "$DOOM1_PWAD_DIR"/*.WAD); shopt -u nullglob
                                    if [ ${#wad_files[@]} -eq 0 ]; then
                                        echo "  [No custom WADs found in:"
                                        echo "   $DOOM1_PWAD_DIR]"
                                    else
                                        for i in "${!wad_files[@]}"; do echo "  $((i+1))) Play $(basename "${wad_files[$i]}")"; done
                                    fi
                                    echo "  0) Return to Doom Menu"
                                    echo "==================================================================================="

                                    get_choice "  Select an option: " custom_choice
                                    echo -e "${RESET}"

                                    if [[ "$custom_choice" == "0" || "$custom_choice" == "ESC" ]]; then break
                                    elif [[ "$custom_choice" =~ ^[0-9]+$ ]] && [ "$custom_choice" -gt 0 ] && [ "$custom_choice" -le "${#wad_files[@]}" ]; then
                                        selected_wad="${wad_files[$((custom_choice-1))]}"
                                        if [[ -f "$WAD_DIR/doom.wad" ]]; then
                                            echo "Launching $(basename "$selected_wad")..."
                                            crispy-doom -iwad "$WAD_DIR/doom.wad" -file "$selected_wad"
                                        else
                                            echo -e "${RED}Error: doom.wad is missing. Press [Enter].${RESET}"; read
                                        fi
                                    else
                                        echo -e "${RED}Invalid option. Press [Enter].${RESET}"; read
                                    fi
                                done
                                ;;

                            "DOOM 2 Custom WADs Menu")
                                while true; do
                                    echo -e "${BLACK_BG}\c"; clear; echo -e "${RED}${BLACK_BG}"
                                    echo "==================================================================================="
                                    echo "                                DOOM 2 CUSTOM WADS"
                                    echo "==================================================================================="
                                    shopt -s nullglob; wad_files=("$DOOM2_PWAD_DIR"/*.wad "$DOOM2_PWAD_DIR"/*.WAD); shopt -u nullglob
                                    if [ ${#wad_files[@]} -eq 0 ]; then
                                        echo "  [No custom WADs found in:"
                                        echo "   $DOOM2_PWAD_DIR]"
                                    else
                                        for i in "${!wad_files[@]}"; do echo "  $((i+1))) Play $(basename "${wad_files[$i]}")"; done
                                    fi
                                    echo "  0) Return to Doom Menu"
                                    echo "==================================================================================="

                                    get_choice "  Select an option: " custom_choice
                                    echo -e "${RESET}"

                                    if [[ "$custom_choice" == "0" || "$custom_choice" == "ESC" ]]; then break
                                    elif [[ "$custom_choice" =~ ^[0-9]+$ ]] && [ "$custom_choice" -gt 0 ] && [ "$custom_choice" -le "${#wad_files[@]}" ]; then
                                        selected_wad="${wad_files[$((custom_choice-1))]}"
                                        if [[ -f "$WAD_DIR/doom2.wad" ]]; then
                                            echo "Launching $(basename "$selected_wad")..."
                                            crispy-doom -iwad "$WAD_DIR/doom2.wad" -file "$selected_wad"
                                        else
                                            echo -e "${RED}Error: doom2.wad is missing. Press [Enter].${RESET}"; read
                                        fi
                                    else
                                        echo -e "${RED}Invalid option. Press [Enter].${RESET}"; read
                                    fi
                                done
                                ;;
                        esac
                    else
                        echo -e "${RED}Invalid option. Press [Enter] to try again.${RESET}"
                        read
                    fi
                done
                ;;

            "Heretic + Hexen")
                # ==========================================
                #             HERETIC + HEXEN MENU
                # ==========================================
                while true; do
                    echo -e "${BLACK_BG}\c"
                    clear
                    echo -e "${RED}${BLACK_BG}"
                    echo "==================================================================================="
cat << 'EOF'
                    _   _ ___________ _____ _____ _____ _____
                   | | | |  ___| ___ \  ___|_   _|_   _/  __ \
                   | |_| | |__ | |_/ / |__   | |   | | | /  \/
                   |  _  |  __||    /|  __|  | |   | | | |
                   | | | | |___| |\ \| |___  | |  _| |_| \__/\
                   \_| |_|____/\_| \_\____/  \_/  \___/ \____/
                                        +
                         _   _ _______   __ _____ _   _
                        | | | |  ___\ \ / /|  ___| \ | |
                        | |_| | |__  \ V / | |__ |  \| |
                        |  _  |  __| /   \ |  __|| . ` |
                        | | | | |___/ /^\ \| |___| |\  |
                        \_| |_|____/\/   \/\____/\_| \_/

EOF
                    echo "==================================================================================="

                    hh_options=()

                    # Base games and expansions grouped logically
                    [[ -f "$HH_DIR/heretic.wad" ]] && hh_options+=("Play Heretic (heretic.wad)")
                    [[ -f "$HH_DIR/heretic.wad" && -f "$HH_DIR/heretic_fr.wad" ]] && hh_options+=("Play Faith Renewed (heretic_fr.wad)")

                    [[ -f "$HH_DIR/hexen.wad" ]] && hh_options+=("Play Hexen (hexen.wad)")
                    [[ -f "$HH_DIR/hexen.wad" && -f "$HH_DIR/hexdd.wad" ]] && hh_options+=("Play Deathkings of the Dark Citadel (hexdd.wad)")
                    [[ -f "$HH_DIR/hexen.wad" && -f "$HH_DIR/hexen_vog.wad" ]] && hh_options+=("Play Vestiges of Grandeur (hexen_vog.wad)")

                    # Custom WAD sub-menus
                    hh_options+=("Heretic Custom WADs Menu")
                    hh_options+=("Hexen Custom WADs Menu")

                    for i in "${!hh_options[@]}"; do
                        echo "  $((i+1))) ${hh_options[$i]}"
                    done

                    echo "  0) Return to Main Menu"
                    echo "==================================================================================="

                    get_choice "  Select an option: " hh_choice
                    echo -e "${RESET}"

                    if [[ "$hh_choice" == "0" || "$hh_choice" == "ESC" ]]; then
                        break
                    elif [[ "$hh_choice" =~ ^[0-9]+$ ]] && [ "$hh_choice" -gt 0 ] && [ "$hh_choice" -le "${#hh_options[@]}" ]; then
                        selected_hh_action="${hh_options[$((hh_choice-1))]}"

                        case "$selected_hh_action" in
                            "Play Heretic (heretic.wad)") echo "Launching Heretic..."; crispy-heretic -iwad "$HH_DIR/heretic.wad" ;;
                            "Play Faith Renewed (heretic_fr.wad)") echo "Launching Faith Renewed..."; crispy-heretic -iwad "$HH_DIR/heretic.wad" -file "$HH_DIR/heretic_fr.wad" ;;

                            "Play Hexen (hexen.wad)") echo "Launching Hexen..."; crispy-hexen -iwad "$HH_DIR/hexen.wad" ;;
                            "Play Deathkings of the Dark Citadel (hexdd.wad)") echo "Launching Deathkings..."; crispy-hexen -iwad "$HH_DIR/hexen.wad" -file "$HH_DIR/hexdd.wad" ;;
                            "Play Vestiges of Grandeur (hexen_vog.wad)") echo "Launching Vestiges of Grandeur..."; crispy-hexen -iwad "$HH_DIR/hexen.wad" -file "$HH_DIR/hexen_vog.wad" ;;

                            "Heretic Custom WADs Menu")
                                while true; do
                                    echo -e "${BLACK_BG}\c"; clear; echo -e "${RED}${BLACK_BG}"
                                    echo "==================================================================================="
                                    echo "                                HERETIC CUSTOM WADS"
                                    echo "==================================================================================="
                                    shopt -s nullglob; wad_files=("$HERETIC_PWAD_DIR"/*.wad "$HERETIC_PWAD_DIR"/*.WAD); shopt -u nullglob
                                    if [ ${#wad_files[@]} -eq 0 ]; then
                                        echo "  [No custom WADs found in:"
                                        echo "   $HERETIC_PWAD_DIR]"
                                    else
                                        for i in "${!wad_files[@]}"; do echo "  $((i+1))) Play $(basename "${wad_files[$i]}")"; done
                                    fi
                                    echo "  0) Return to Heretic/Hexen Menu"
                                    echo "==================================================================================="

                                    get_choice "  Select an option: " custom_choice
                                    echo -e "${RESET}"

                                    if [[ "$custom_choice" == "0" || "$custom_choice" == "ESC" ]]; then break
                                    elif [[ "$custom_choice" =~ ^[0-9]+$ ]] && [ "$custom_choice" -gt 0 ] && [ "$custom_choice" -le "${#wad_files[@]}" ]; then
                                        selected_wad="${wad_files[$((custom_choice-1))]}"
                                        if [[ -f "$HH_DIR/heretic.wad" ]]; then
                                            echo "Launching $(basename "$selected_wad")..."
                                            crispy-heretic -iwad "$HH_DIR/heretic.wad" -file "$selected_wad"
                                        else
                                            echo -e "${RED}Error: heretic.wad is missing. Press [Enter].${RESET}"; read
                                        fi
                                    else
                                        echo -e "${RED}Invalid option. Press [Enter].${RESET}"; read
                                    fi
                                done
                                ;;

                            "Hexen Custom WADs Menu")
                                while true; do
                                    echo -e "${BLACK_BG}\c"; clear; echo -e "${RED}${BLACK_BG}"
                                    echo "==================================================================================="
                                    echo "                                 HEXEN CUSTOM WADS"
                                    echo "==================================================================================="
                                    shopt -s nullglob; wad_files=("$HEXEN_PWAD_DIR"/*.wad "$HEXEN_PWAD_DIR"/*.WAD); shopt -u nullglob
                                    if [ ${#wad_files[@]} -eq 0 ]; then
                                        echo "  [No custom WADs found in:"
                                        echo "   $HEXEN_PWAD_DIR]"
                                    else
                                        for i in "${!wad_files[@]}"; do echo "  $((i+1))) Play $(basename "${wad_files[$i]}")"; done
                                    fi
                                    echo "  0) Return to Heretic/Hexen Menu"
                                    echo "==================================================================================="

                                    get_choice "  Select an option: " custom_choice
                                    echo -e "${RESET}"

                                    if [[ "$custom_choice" == "0" || "$custom_choice" == "ESC" ]]; then break
                                    elif [[ "$custom_choice" =~ ^[0-9]+$ ]] && [ "$custom_choice" -gt 0 ] && [ "$custom_choice" -le "${#wad_files[@]}" ]; then
                                        selected_wad="${wad_files[$((custom_choice-1))]}"
                                        if [[ -f "$HH_DIR/hexen.wad" ]]; then
                                            echo "Launching $(basename "$selected_wad")..."
                                            crispy-hexen -iwad "$HH_DIR/hexen.wad" -file "$selected_wad"
                                        else
                                            echo -e "${RED}Error: hexen.wad is missing. Press [Enter].${RESET}"; read
                                        fi
                                    else
                                        echo -e "${RED}Invalid option. Press [Enter].${RESET}"; read
                                    fi
                                done
                                ;;
                        esac
                    else
                        echo -e "${RED}Invalid option. Press [Enter] to try again.${RESET}"
                        read
                    fi
                done
                ;;
        esac
    else
        echo -e "${RED}Invalid option. Press [Enter] to try again.${RESET}"
        read
    fi
done

# Final color reset on exit
echo -e "${RESET}"
clear
