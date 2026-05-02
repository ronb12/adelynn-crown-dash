"""
Headless FBX → GLB for Crown Dash (fixes common animation export issues).

Usage:
  blender -b -P scripts/blender_fbx_to_glb.py -- input.fbx output.glb

Import uses sensible FBX rig defaults; export enables animation sampling / bake options
so clips are not empty when FBX→glTF lacked channels before.

Compatible with Blender 3.x / 4.x: unknown operator kwargs are skipped.
"""
from __future__ import annotations

import sys
import os


def _argv_after_dd():
    if "--" in sys.argv:
        return sys.argv[sys.argv.index("--") + 1 :]
    try:
        i = sys.argv.index(__file__)
        return sys.argv[i + 1 :]
    except ValueError:
        return []


argv = _argv_after_dd()
if len(argv) < 2:
    print("Usage: blender -b -P blender_fbx_to_glb.py -- input.fbx output.glb", file=sys.stderr)
    sys.exit(1)

in_path = os.path.abspath(argv[0])
out_path = os.path.abspath(argv[1])

if not os.path.isfile(in_path):
    print("Missing input:", in_path, file=sys.stderr)
    sys.exit(2)

os.makedirs(os.path.dirname(out_path) or ".", exist_ok=True)

import bpy  # noqa: E402


def _filter_kwargs(op, kw):
    """Only pass keyword args that exist on this Blender build's operator."""
    try:
        rna = op.get_rna()
        props = {p.identifier for p in rna.properties if p.identifier != "rna_type"}
    except Exception:
        return kw
    out = {k: v for k, v in kw.items() if k in props}
    # filepath must survive filtering quirks across Blender versions
    if "filepath" in kw:
        out["filepath"] = kw["filepath"]
    return out


def import_fbx(path):
    bpy.ops.wm.read_factory_settings(use_empty=True)
    kw = {
        "filepath": path,
        "automatic_bone_orientation": True,
        "use_anim": True,
        "ignore_leaf_bones": False,
        "global_scale": 1.0,
    }
    kw = _filter_kwargs(bpy.ops.import_scene.fbx, kw)
    bpy.ops.import_scene.fbx(**kw)


def extend_scene_frame_range():
    """If actions exist but scene range is wrong, widen frame range for baking."""
    scene = bpy.context.scene
    start = scene.frame_start
    end = scene.frame_end
    for action in bpy.data.actions:
        if action.frame_range:
            r0, r1 = int(action.frame_range[0]), int(action.frame_range[1])
            start = min(start, r0)
            end = max(end, r1)
    if end > start:
        scene.frame_start = start
        scene.frame_end = end


def export_glb(path):
    """Export with animation-friendly options; strip unsupported keys per Blender version."""
    extend_scene_frame_range()

    candidates = [
        # Prefer full animation / sampling / bake when available (fixes empty clips).
        {
            "filepath": path,
            "check_existing": False,
            "export_format": "GLB",
            "export_animations": True,
            "export_force_sampling": True,
            "export_frame_step": 1,
            "export_frame_range": False,
            "export_materials": "EXPORT",
            "export_texcoords": True,
            "export_normals": True,
            "export_skins": True,
            "export_morph": True,
            "export_yup": True,
            "use_selection": False,
            "export_cameras": False,
            "export_lights": False,
            "export_nla_strips": True,
            "export_optimize_animation_size": True,
            "export_bake_animation": True,
            "export_rest_position_armature": True,
            "export_reset_pose_bones": True,
            "export_anim_single_armature": True,
        },
        # Slightly older io_scene_gltf (no bake flag).
        {
            "filepath": path,
            "check_existing": False,
            "export_format": "GLB",
            "export_animations": True,
            "export_force_sampling": True,
            "export_frame_step": 1,
            "export_materials": "EXPORT",
            "export_texcoords": True,
            "export_normals": True,
            "export_skins": True,
            "export_yup": True,
            "use_selection": False,
            "export_cameras": False,
            "export_lights": False,
        },
        # Minimal fallback.
        {"filepath": path, "check_existing": False, "export_format": "GLB", "export_animations": True},
    ]

    last_err = None
    for opts in candidates:
        kw = _filter_kwargs(bpy.ops.export_scene.gltf, opts)
        try:
            bpy.ops.export_scene.gltf(**kw)
            return
        except TypeError as e:
            last_err = e
            continue
        except Exception as e:
            last_err = e
            continue
    if last_err:
        raise last_err
    bpy.ops.export_scene.gltf(filepath=path, export_format="GLB")


try:
    import_fbx(in_path)
except Exception as e:
    print("FBX import failed:", e, file=sys.stderr)
    sys.exit(3)

try:
    export_glb(out_path)
except Exception as e:
    print("glTF export failed:", e, file=sys.stderr)
    sys.exit(4)

print("OK", out_path)
