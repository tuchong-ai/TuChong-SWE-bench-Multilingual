#!/usr/bin/env bash
set -e

if ! command -v ninja >/dev/null || ! command -v wayland-scanner >/dev/null || [ ! -d /usr/share/wayland-protocols ] || ! command -v pkg-config >/dev/null || ! pkg-config --exists libjpeg libpng freetype2 libavformat libavcodec libswscale libavutil; then if [ "$(id -u)" -eq 0 ]; then apt-get update -qq || { echo "LVGL dependency apt update failed" >&2; exit 1; }; env DEBIAN_FRONTEND=noninteractive apt-get install -y -qq pkg-config ninja-build libwayland-bin wayland-protocols libjpeg-dev libpng-dev libfreetype-dev libavformat-dev libavcodec-dev libswscale-dev libavutil-dev || { echo "LVGL dependency apt install failed" >&2; exit 1; }; elif command -v sudo >/dev/null; then sudo apt-get update -qq || { echo "LVGL dependency apt update failed" >&2; exit 1; }; sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y -qq pkg-config ninja-build libwayland-bin wayland-protocols libjpeg-dev libpng-dev libfreetype-dev libavformat-dev libavcodec-dev libswscale-dev libavutil-dev || { echo "LVGL dependency apt install failed" >&2; exit 1; }; else echo "LVGL dependencies missing and sudo is unavailable" >&2; exit 1; fi; fi; command -v ninja >/dev/null || { echo "LVGL dependency missing: ninja" >&2; exit 1; }; command -v wayland-scanner >/dev/null || { echo "LVGL dependency missing: wayland-scanner" >&2; exit 1; }; [ -d /usr/share/wayland-protocols ] || { echo "LVGL dependency missing: wayland-protocols" >&2; exit 1; }; command -v pkg-config >/dev/null || { echo "LVGL dependency missing: pkg-config" >&2; exit 1; }; pkg-config --exists libjpeg libpng freetype2 libavformat libavcodec libswscale libavutil || { echo "LVGL development libraries are incomplete" >&2; exit 1; }
python3 -m venv "$HOME/.claudedata-lvgl-venv"
if [ -n "${CLAUDEDATA_OFFLINE_CACHE:-}" ] && [ -d "$CLAUDEDATA_OFFLINE_CACHE/pip" ]; then "$HOME/.claudedata-lvgl-venv/bin/pip" install --no-index --find-links="$CLAUDEDATA_OFFLINE_CACHE/pip" pypng lz4; else "$HOME/.claudedata-lvgl-venv/bin/pip" install pypng lz4; fi

# Precompile public base-test targets for incremental agent and grading runs.
. "$HOME/.claudedata-lvgl-venv/bin/activate"
__lvgl_build="${CLAUDEDATA_LVGL_BUILD_DIR:-$HOME/.cache/claudedata/lvgl-build}"
__lvgl_jobs="${CLAUDEDATA_LVGL_BUILD_JOBS:-4}"
if [ ! -f "$__lvgl_build/build.ninja" ]; then cmake -S tests -B "$__lvgl_build" -GNinja -DCMAKE_BUILD_TYPE=Debug -DOPTIONS_TEST_SYSHEAP=1; fi
cmake --build "$__lvgl_build" --parallel "$__lvgl_jobs" --target test_bar test_slider test_array

__claudedata_repo_root="$(git rev-parse --show-toplevel)"
cd "$__claudedata_repo_root"
find "$__claudedata_repo_root" -type f -name __baseline__.txt -delete

# SWE-bench boundary: hide PR tests and baseline output from the agent.
__claudedata_repo_root="$(git rev-parse --show-toplevel)"
cd "$__claudedata_repo_root"
if git cat-file -e HEAD:tests/src/test_cases/widgets/test_bar.c 2>/dev/null; then
    git checkout HEAD -- tests/src/test_cases/widgets/test_bar.c
else
    rm -f -- tests/src/test_cases/widgets/test_bar.c
fi
if git cat-file -e HEAD:tests/src/test_cases/widgets/test_slider.c 2>/dev/null; then
    git checkout HEAD -- tests/src/test_cases/widgets/test_slider.c
else
    rm -f -- tests/src/test_cases/widgets/test_slider.c
fi
find "$__claudedata_repo_root" -type f -name __baseline__.txt -delete
# Remove test-runner artifacts that can retain held-out test names or bytecode.
find . -type d \( -name __pycache__ -o -name .pytest_cache -o -name .hypothesis \) -prune -exec rm -rf -- {} +
find . -type f \( -name '*.pyc' -o -name '*.pyo' -o -name '.coverage' -o -name '.coverage.*' \) -delete
rm -rf -- /tmp/pytest-of-* /tmp/pytest-* /tmp/hypothesis-* 2>/dev/null || true
rm -f __baseline__.txt
echo 'workspace ready'