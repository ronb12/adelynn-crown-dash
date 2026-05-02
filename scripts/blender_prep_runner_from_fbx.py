"""
Import legacy princess FBX → prep for Crown Dash runner → export GLB.

Use when you want a cleaner mobile-ready glTF after Blender handles materials
and scene normalization (meshes without materials get a simple skin-tone).

Usage:
  blender -b -P scripts/blender_prep_runner_from_fbx.py -- input.fbx output.glb

Same argv convention as blender_fbx_to_glb.py.
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
    print(
        "Usage: blender -b -P blender_prep_runner_from_fbx.py -- input.fbx output.glb",
        file=sys.stderr,
    )
    sys.exit(1)

in_path = os.path.abspath(argv[0])
out_path = os.path.abspath(argv[1])

if not os.path.isfile(in_path):
    print("Missing input:", in_path, file=sys.stderr)
    sys.exit(2)

os.makedirs(os.path.dirname(out_path) or ".", exist_ok=True)

import bpy  # noqa: E402


def _filter_kwargs(op, kw):
    try:
        rna = op.get_rna()
        props = {p.identifier for p in rna.properties if p.identifier != "rna_type"}
    except Exception:
        return kw
    out = {k: v for k, v in kw.items() if k in props}
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


def _get_or_create_mat(name, diffuse=(0.82, 0.65, 0.72, 1.0)):
    if name in bpy.data.materials:
        return bpy.data.materials[name]
    mat = bpy.data.materials.new(name=name)
    mat.use_nodes = True
    nodes = mat.node_tree.nodes
    links = mat.node_tree.links
    nodes.clear()
    out = nodes.new(type="ShaderNodeOutputMaterial")
    principled = nodes.new(type="ShaderNodeBsdfPrincipled")
    principled.inputs["Base Color"].default_value = diffuse
    principled.inputs["Roughness"].default_value = 0.55
    principled.location = (0, 0)
    out.location = (300, 0)
    links.new(principled.outputs["BSDF"], out.inputs["Surface"])
    return mat


def prep_runner_scene():
    """Assign default materials to naked meshes; normalize units; avoid destructive rig edits."""
    try:
        bpy.context.scene.unit_settings.system = "METRIC"
        bpy.context.scene.unit_settings.scale_length = 1.0
    except Exception:
        pass

    skin = _get_or_create_mat(
        "CrownDash_RunnerSkin",
        diffuse=(0.85, 0.68, 0.74, 1.0),
    )
    cloth = _get_or_create_mat(
        "CrownDash_RunnerCloth",
        diffuse=(0.35, 0.38, 0.72, 1.0),
    )

    for obj in bpy.data.objects:
        if obj.type != "MESH" or obj.data is None:
            continue
        data = obj.data
        if len(data.materials) == 0:
            data.materials.append(skin)
            continue
        # Replace empty slots
        for i, slot in enumerate(obj.material_slots):
            if slot.material is None:
                # Alternate slightly so dress vs skin reads in viewport
                slot.material = cloth if i % 2 else skin


def extend_scene_frame_range():
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
    extend_scene_frame_range()

    candidates = [
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
    prep_runner_scene()
except Exception as e:
    print("Prep warning (continuing):", e, file=sys.stderr)

try:
    export_glb(out_path)
except Exception as e:
    print("glTF export failed:", e, file=sys.stderr)
    sys.exit(4)

print("OK", out_path)
