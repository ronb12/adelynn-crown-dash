#!/usr/bin/env python3
"""
Crown Dash — Blender 3D automation hub (batch / CLI).

What this *can* automate: imports/exports, procedural placeholder meshes, basic rig
keyframes, material prep, sprite reference planes, glTF export — the repetitive
pipeline around your assets.

What it *cannot* replace: creative modeling, sculpting, topology decisions, final
character art, hand-polished animation. Those still need a human (or external AI)
and Blender’s interactive tools.

Run (recommended — Blender supplies bpy.app.binary_path for child processes):

  blender -b -P scripts/blender_3d_automation.py -- help
  blender -b -P scripts/blender_3d_automation.py -- fbx-to-glb assets/character.fbx assets/character.glb
  blender -b -P scripts/blender_3d_automation.py -- prep-fbx assets/character.fbx assets/character.glb
  blender -b -P scripts/blender_3d_automation.py -- proc-runner [assets/runner_cli_demo.glb]
  blender -b -P scripts/blender_3d_automation.py -- sprite-refs [path/to/assets]

Or from system Python (no bpy): set BLENDER to the Blender executable; this script
will subprocess each job into Blender batch mode.

See also: package.json npm scripts (convert:character, blender:cli-runner-demo, …).
"""
from __future__ import annotations

import os
import shutil
import subprocess
import sys

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(SCRIPT_DIR)


def _blender_executable() -> str:
    try:
        import bpy  # type: ignore

        return bpy.app.binary_path
    except Exception:
        env = os.environ.get("BLENDER")
        if env and os.path.isfile(env):
            return env
        which = shutil.which("blender")
        if which:
            return which
        mac = "/Applications/Blender.app/Contents/MacOS/Blender"
        if os.path.isfile(mac):
            return mac
    raise RuntimeError(
        "Could not find Blender. Run this script with Blender (blender -b -P …), "
        "or set BLENDER=/path/to/Blender."
    )


def _run_blender_script(py_basename: str, argv_tail: list[str]) -> int:
    """Spawn blender -b -P <script> -- argv_tail."""
    exe = _blender_executable()
    script_path = os.path.join(SCRIPT_DIR, py_basename)
    if not os.path.isfile(script_path):
        print("Missing script:", script_path, file=sys.stderr)
        return 2
    cmd = [exe, "-b", "-P", script_path, "--"] + argv_tail
    print("[blender_3d_automation]", " ".join(cmd))
    r = subprocess.run(cmd, cwd=ROOT)
    return int(r.returncode if r.returncode is not None else 1)


def _args_after_dd() -> list[str]:
    if "--" in sys.argv:
        return sys.argv[sys.argv.index("--") + 1 :]
    return sys.argv[1:]


def _usage() -> None:
    print(
        """Usage:
  blender -b -P scripts/blender_3d_automation.py -- <command> [arguments]

Commands:
  help                  Show this text.
  fbx-to-glb <in.fbx> <out.glb>
                        Import FBX, export glTF (animations baked).
  prep-fbx <in.fbx> <out.glb>
                        Like fbx-to-glb plus mesh material fill for empty slots.
  proc-runner [out.glb] Procedural runner mesh + Idle/Run/Jump/Fall/Land/Hurt/Dash.
                        Default out: assets/runner_cli_demo.glb
  sprite-refs [assets_dir]
                        Create PNG reference planes (model by hand on top).
                        Default dir: ./assets

Automation limits:
  • No full artistic character generation — only pipeline steps above.
  • For production art: model in Blender UI, then use fbx-to-glb or prep-fbx.
"""
    )


def main() -> int:
    raw = _args_after_dd()
    if not raw:
        _usage()
        return 1
    if raw[0].lower() in ("-h", "--help", "help"):
        _usage()
        return 0

    cmd = raw[0].lower()
    rest = raw[1:]

    if cmd == "fbx-to-glb":
        if len(rest) < 2:
            print("fbx-to-glb: need <input.fbx> <output.glb>", file=sys.stderr)
            return 1
        return _run_blender_script("blender_fbx_to_glb.py", [rest[0], rest[1]])

    if cmd == "prep-fbx":
        if len(rest) < 2:
            print("prep-fbx: need <input.fbx> <output.glb>", file=sys.stderr)
            return 1
        return _run_blender_script("blender_prep_runner_from_fbx.py", [rest[0], rest[1]])

    if cmd == "proc-runner":
        out = rest[0] if rest else os.path.join(ROOT, "assets", "runner_cli_demo.glb")
        out = out if os.path.isabs(out) else os.path.join(ROOT, out)
        return _run_blender_script("blender_cli_runner_demo.py", [out])

    if cmd == "sprite-refs":
        d = rest[0] if rest else os.path.join(ROOT, "assets")
        d = d if os.path.isabs(d) else os.path.join(ROOT, d)
        return _run_blender_script("blender_sprite_reference_setup.py", [d])

    print("Unknown command:", cmd, file=sys.stderr)
    _usage()
    return 1


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except RuntimeError as e:
        print(str(e), file=sys.stderr)
        raise SystemExit(2)
