#!/data/data/com.termux/files/usr/bin/bash
# ═══════════════════════════════════════════════════════════════════════════
#  SPIN.SH — Storage Permission + Module Installer + OB55-SPIN Clone + Run
#  Author: ARIYAN A9X
#  Usage : bash spin.sh
# ═══════════════════════════════════════════════════════════════════════════

RESET="\033[0m"
BOLD="\033[1m"
DIM="\033[2m"
GREEN="\033[92m"
YELLOW="\033[93m"
CYAN="\033[96m"
RED="\033[91m"
WHITE="\033[97m"
PINK="\033[38;5;206m"

RGB=(
    "\033[38;5;196m" "\033[38;5;208m" "\033[38;5;226m" "\033[38;5;118m"
    "\033[38;5;51m"  "\033[38;5;45m"  "\033[38;5;93m"  "\033[38;5;201m"
    "\033[38;5;198m" "\033[38;5;214m" "\033[38;5;220m" "\033[38;5;154m"
    "\033[38;5;57m"  "\033[38;5;129m" "\033[38;5;212m"
)
RGB_LEN=15

BOX_W=52
B="${PINK}${BOLD}"
RS="${RESET}"

# ═══════════════════════════════════════════════════════════════════════════
#  UI HELPERS
# ═══════════════════════════════════════════════════════════════════════════
box_top()  { echo -e "${B}  ╔$(printf '═%.0s' $(seq 1 $BOX_W))╗${RS}"; }
box_bot()  { echo -e "${B}  ╚$(printf '═%.0s' $(seq 1 $BOX_W))╝${RS}"; }
box_line() { echo -e "${B}  ╠$(printf '═%.0s' $(seq 1 $BOX_W))╣${RS}"; }

box_center() {
    local text="$1" color="${2:-$WHITE}"
    local clean; clean=$(echo -e "$text" | sed 's/\x1b\[[0-9;]*m//g')
    local tlen=${#clean}
    local lpad=$(( (BOX_W - tlen) / 2 ))
    local rpad=$(( BOX_W - tlen - lpad ))
    [ $lpad -lt 0 ] && lpad=0
    [ $rpad -lt 0 ] && rpad=0
    printf "${B}  ║${RS}%${lpad}s${color}${BOLD}%s${RS}%${rpad}s${B}║${RS}\n" "" "$text" ""
}

box_left() {
    local text="$1" color="${2:-$WHITE}"
    local clean; clean=$(echo -e "$text" | sed 's/\x1b\[[0-9;]*m//g')
    local pad=$(( BOX_W - ${#clean} - 2 ))
    [ $pad -lt 0 ] && pad=0
    printf "${B}  ║${RS} ${color}${BOLD}%s${RS}%${pad}s${B} ║${RS}\n" "$text" ""
}

rgb_progress_box() {
    local done=$1 total=$2
    [ $total -eq 0 ] && total=1
    local filled=$(( done * (BOX_W - 4) / total ))
    local empty=$(( BOX_W - 4 - filled ))
    local bar=""
    for i in $(seq 1 $filled); do
        local ci=$(( (i + done) % RGB_LEN ))
        bar="${bar}${RGB[$ci]}${BOLD}▰${RESET}"
    done
    for i in $(seq 1 $empty); do
        bar="${bar}${DIM}▱${RESET}"
    done
    printf "${B}  ║${RS} ${bar} ${B}║${RS}\n"
}

# ═══════════════════════════════════════════════════════════════════════════
#  HEADER
# ═══════════════════════════════════════════════════════════════════════════
clear
box_top
box_center "⚡ ARIYAN A9X — OB55 SPIN ⚡" "$YELLOW"
box_center "Storage + Modules + Clone + Run" "$CYAN"
box_bot
echo ""

# ═══════════════════════════════════════════════════════════════════════════
#  STEP 0 — STORAGE PERMISSION (সবার আগে)
# ═══════════════════════════════════════════════════════════════════════════
box_top
box_center "📱 ধাপ ০ — Storage Permission" "$YELLOW"
box_line

box_left "🔍 Storage permission চেক করা হচ্ছে..." "$CYAN"

# Termux check
if [ -d "/data/data/com.termux" ]; then
    IS_TERMUX=1
else
    IS_TERMUX=0
fi

if [ $IS_TERMUX -eq 1 ]; then
    # termux-setup-storage কমান্ড আছে কিনা চেক
    if ! command -v termux-setup-storage &>/dev/null; then
        printf "\033[1A\033[2K"
        box_left "⚠️  termux-setup-storage কমান্ড নেই" "$YELLOW"
        box_left "📦 termux-tools ইনস্টল হচ্ছে..." "$CYAN"
        pkg install -y termux-tools &>/dev/null
        printf "\033[1A\033[2K"
    fi

    # storage ফোল্ডার আগে থেকেই আছে কিনা
    if [ -d "$HOME/storage" ] && [ -d "$HOME/storage/shared" ]; then
        printf "\033[1A\033[2K"
        box_left "✅ Storage permission আগেই দেওয়া আছে" "$GREEN"
    else
        printf "\033[1A\033[2K"
        box_left "🔐 Storage permission চাওয়া হচ্ছে..." "$YELLOW"
        box_left "👉 ফোনে 'Allow' দিন" "$CYAN"
        echo ""
        box_bot
        echo ""
        
        # Permission নেওয়ার কমান্ড
        termux-setup-storage
        
        # Popup এ Allow দেওয়ার জন্য অপেক্ষা
        echo ""
        box_top
        box_center "⏳ Popup এ Allow দেওয়ার জন্য অপেক্ষা..." "$YELLOW"
        box_line
        
        # সর্বোচ্চ ৩০ সেকেন্ড অপেক্ষা করি
        WAITED=0
        while [ $WAITED -lt 30 ]; do
            if [ -d "$HOME/storage" ] && [ -d "$HOME/storage/shared" ]; then
                break
            fi
            sleep 1
            WAITED=$(( WAITED + 1 ))
        done
        
        if [ -d "$HOME/storage" ] && [ -d "$HOME/storage/shared" ]; then
            printf "\033[1A\033[2K"
            box_left "✅ Storage permission পাওয়া গেছে" "$GREEN"
        else
            printf "\033[1A\033[2K"
            box_left "❌ Storage permission দেওয়া হয়নি" "$RED"
            box_left "💡 আবার চেষ্টা করুন: termux-setup-storage" "$YELLOW"
            box_bot
            echo ""
            exit 1
        fi
    fi
else
    printf "\033[1A\033[2K"
    box_left "ℹ️  Termux না — permission skip" "$CYAN"
fi

box_bot
echo ""

# ═══════════════════════════════════════════════════════════════════════════
#  STEP 1 — পাইথন ও পিপ প্রস্তুতি
# ═══════════════════════════════════════════════════════════════════════════
box_top
box_center "🔧 ধাপ ১ — পাইথন প্রস্তুতি" "$YELLOW"
box_line

box_left "🔍 পাইথন চেক করা হচ্ছে..." "$CYAN"
if ! command -v python &>/dev/null && ! command -v python3 &>/dev/null; then
    printf "\033[1A\033[2K"
    box_left "⬇️  পাইথন ইনস্টল হচ্ছে..." "$YELLOW"
    pkg install python -y &>/dev/null
fi
printf "\033[1A\033[2K"

if command -v python3 &>/dev/null; then
    PY=python3
else
    PY=python
fi
box_left "✅ পাইথন প্রস্তুত ($PY)" "$GREEN"

box_left "🔄 পিপ আপগ্রেড হচ্ছে..." "$CYAN"
$PY -m pip install --upgrade pip -q --break-system-packages &>/dev/null \
    || $PY -m pip install --upgrade pip -q &>/dev/null
printf "\033[1A\033[2K"
box_left "✅ পিপ প্রস্তুত" "$GREEN"
box_bot
echo ""

# ═══════════════════════════════════════════════════════════════════════════
#  STEP 2 — সব মডিউল ইনস্টল
# ═══════════════════════════════════════════════════════════════════════════
box_top
box_center "📦 ধাপ ২ — মডিউল ইনস্টল" "$YELLOW"
box_line

FAILED=()
MODULES=(
    "requests|pip"
    "urllib3|pip"
    "pycryptodome|pip"
    "protobuf==3.20.3|pip"
    "protobuf-decoder|pip"
    "blackboxprotobuf|pip"
    "colorama|pip"
    "aiohttp|pip"
    "PyJWT|pip"
    "pytz|pip"
    "pyfiglet|pip"
    "psutil|pkg"
    "flask|pip"
    "google-play-scraper|pip"
    "curl|pkg"
    "git|pkg"
    "tor|pkg"
    "nc|pkg"
)

TOTAL=${#MODULES[@]}
DONE=0

for entry in "${MODULES[@]}"; do
    name="${entry%%|*}"
    method="${entry##*|}"
    DONE=$(( DONE + 1 ))

    box_left "⏳ ${name}  [${DONE}/${TOTAL}]" "$YELLOW"

    if [ "$method" = "pkg" ]; then
        pkg install -y "$name" &>/dev/null
        RC=$?
        if [ $RC -ne 0 ]; then
            $PY -m pip install "$name" -q --break-system-packages &>/dev/null \
                || $PY -m pip install "$name" -q &>/dev/null
            RC=$?
        fi
    else
        $PY -m pip install "$name" -q --break-system-packages &>/dev/null
        RC=$?
        if [ $RC -ne 0 ]; then
            $PY -m pip install "$name" -q &>/dev/null
            RC=$?
        fi
    fi

    if [ $RC -eq 0 ]; then
        printf "\033[1A\033[2K"
        box_left "✅ ${name} (সফল)" "$GREEN"
    else
        printf "\033[1A\033[2K"
        box_left "❌ ${name} (ব্যর্থ)" "$RED"
        FAILED+=("$name")
    fi

    rgb_progress_box "$DONE" "$TOTAL"
done

echo ""
rgb_progress_box "$TOTAL" "$TOTAL"
box_bot
echo ""

if [ ${#FAILED[@]} -gt 0 ]; then
    echo -e "${YELLOW}${BOLD}  [!] ব্যর্থ মডিউল:${RESET}"
    for f in "${FAILED[@]}"; do
        echo -e "  ${RED}    ❌ $f${RESET}"
    done
    echo ""
fi

# ═══════════════════════════════════════════════════════════════════════════
#  STEP 3 — GitHub থেকে OB55-SPIN ক্লোন
# ═══════════════════════════════════════════════════════════════════════════
box_top
box_center "📥 ধাপ ৩ — OB55-SPIN ক্লোন" "$YELLOW"
box_line

# ── ইন্টারনাল স্টোরেজ পাথ ──
if [ -d "/sdcard" ]; then
    INTERNAL="/sdcard"
elif [ -d "$HOME/storage/shared" ]; then
    INTERNAL="$HOME/storage/shared"
else
    INTERNAL="$HOME"
fi

TARGET_DIR="$INTERNAL/OB55 SPIN"
REPO_URL="https://github.com/Ariyan20267/OB55-SPIN.git"

box_left "📂 টার্গেট ফোল্ডার: OB55 SPIN" "$CYAN"
box_left "🔗 রিপো: OB55-SPIN.git" "$CYAN"
box_line

# পুরনো ফোল্ডার থাকলে রিমুভ
if [ -d "$TARGET_DIR" ]; then
    box_left "🗑️  পুরনো ফোল্ডার রিমুভ করা হচ্ছে..." "$YELLOW"
    rm -rf "$TARGET_DIR" 2>/dev/null
    printf "\033[1A\033[2K"
fi

# ক্লোন
box_left "⬇️  ক্লোন করা হচ্ছে..." "$CYAN"
git clone --depth 1 "$REPO_URL" "$TARGET_DIR" &>/dev/null
CLONE_RC=$?

printf "\033[1A\033[2K"
if [ $CLONE_RC -eq 0 ] && [ -d "$TARGET_DIR" ]; then
    box_left "✅ ক্লোন সফল" "$GREEN"
else
    box_left "❌ ক্লোন ব্যর্থ — ইন্টারনেট চেক করুন" "$RED"
    box_bot
    echo ""
    echo -e "${RED}${BOLD}  ❌ spin.sh বন্ধ করা হচ্ছে${RESET}"
    exit 1
fi

box_bot
echo ""

# ═══════════════════════════════════════════════════════════════════════════
#  STEP 4 — spin.py রান
# ═══════════════════════════════════════════════════════════════════════════
box_top
box_center "🚀 ধাপ ৪ — spin.py রান করা হচ্ছে" "$YELLOW"
box_line

SPIN_FILE=""
if [ -f "$TARGET_DIR/spin.py" ]; then
    SPIN_FILE="$TARGET_DIR/spin.py"
else
    SPIN_FILE=$(find "$TARGET_DIR" -maxdepth 3 -name "spin.py" 2>/dev/null | head -n 1)
fi

if [ -z "$SPIN_FILE" ]; then
    box_left "❌ spin.py পাওয়া যায়নি" "$RED"
    box_bot
    exit 1
fi

box_left "✅ spin.py পাওয়া গেছে" "$GREEN"
box_left "▶️  রান করা হচ্ছে..." "$CYAN"
box_bot
echo ""

cd "$(dirname "$SPIN_FILE")" || exit 1
$PY "$SPIN_FILE"

# ═══════════════════════════════════════════════════════════════════════════
#  EXIT
# ═══════════════════════════════════════════════════════════════════════════
echo ""
box_top
box_center "✅ spin.py সম্পন্ন হয়েছে" "$GREEN"
box_bot
echo ""
