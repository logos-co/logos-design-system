{ pkgs, program, seconds ? 10 }:

# Launches `program` (what `nix run` executes) offscreen with an empty
# environment. A healthy app is still running when `timeout` stops it (124);
# an unwrapped binary exited at once with `plugin "..." not found`.
pkgs.runCommand "logos-storybook-launch-check" { } ''
  mkdir -p home xdg && chmod 700 xdg
  status=0
  # Off a TTY, Linux Qt logs to journald unless told to use stderr.
  timeout --kill-after=10 ${toString seconds} env -i \
    HOME="$PWD/home" XDG_RUNTIME_DIR="$PWD/xdg" \
    QT_QPA_PLATFORM=offscreen QT_FORCE_STDERR_LOGGING=1 \
    ${program} > app.log 2>&1 || status=$?
  cat app.log

  if [ "$status" -ne 124 ]; then
    echo "FAIL: ${program} exited with status $status within ${toString seconds}s" >&2
    exit 1
  fi
  if grep -E 'failed to load component|plugin ".*" not found|is not installed' app.log >&2; then
    echo "FAIL: QML import errors (above) while launching ${program}" >&2
    exit 1
  fi
  touch $out
''
