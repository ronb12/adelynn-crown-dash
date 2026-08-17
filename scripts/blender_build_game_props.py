"""
Headless: low-poly hazards + coin + pickups → assets/game_props.glb

Top-level object names (Prop_<key>):
  beam, thorn, water, rock, coin,
  pickup_magnet, pickup_shield, pickup_double

  blender -b -P scripts/blender_build_game_props.py -- assets/game_props.glb
"""
from __future__ import annotations

import os
import sys


def _argv_after_dd():
    if "--" in sys.argv:
        return sys.argv[sys.argv.index("--") + 1 :]
    try:
        i = sys.argv.index(__file__)
        return sys.argv[i + 1 :]
    except ValueError:
        return []


argv = _argv_after_dd()
root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
out_path = os.path.abspath(argv[0]) if argv else os.path.join(root, "assets", "game_props.glb")
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


def mat(rgb, rough=0.88):
    m = bpy.data.materials.new(name="M")
    m.use_nodes = True
    nt = m.node_tree
    for n in list(nt.nodes):
        nt.nodes.remove(n)
    out = nt.nodes.new(type="ShaderNodeOutputMaterial")
    bsdf = nt.nodes.new(type="ShaderNodeBsdfPrincipled")
    bsdf.inputs["Base Color"].default_value = (rgb[0], rgb[1], rgb[2], 1.0)
    bsdf.inputs["Roughness"].default_value = rough
    nt.links.new(bsdf.outputs["BSDF"], out.inputs["Surface"])
    return m


def add_box(name, loc, scale, rgb):
    bpy.ops.mesh.primitive_cube_add(size=2, location=loc)
    ob = bpy.context.active_object
    ob.name = name
    ob.scale = scale
    me = mat(rgb)
    if ob.data.materials:
        ob.data.materials[0] = me
    else:
        ob.data.materials.append(me)
    return ob


def add_cyl(name, loc, scale, rgb, rot=(0, 0, 0)):
    bpy.ops.mesh.primitive_cylinder_add(vertices=20, radius=1, depth=2, location=loc)
    ob = bpy.context.active_object
    ob.name = name
    ob.scale = scale
    ob.rotation_euler = rot
    me = mat(rgb)
    if ob.data.materials:
        ob.data.materials[0] = me
    else:
        ob.data.materials.append(me)
    return ob


def parent_to(child, parent):
    child.parent = parent
    return child


def add_sentinel(name, loc):
    """Dark-sector soldier hazard: readable armored silhouette, not a gray block."""
    bpy.ops.object.empty_add(type="PLAIN_AXES", location=loc)
    root = bpy.context.active_object
    root.name = name

    armor = (0.10, 0.11, 0.17)
    armor_hi = (0.24, 0.28, 0.36)
    violet = (0.34, 0.24, 0.62)
    visor = (0.78, 0.60, 1.00)
    metal = (0.62, 0.68, 0.74)

    parts = [
        add_box(name + "_cloak", (loc[0], loc[1] + 2, loc[2] + 3), (23, 5, 33), (0.05, 0.05, 0.09)),
        add_box(name + "_torso", (loc[0], loc[1], loc[2] + 10), (16, 11, 21), armor),
        add_box(name + "_chest", (loc[0], loc[1] - 0.8, loc[2] + 16), (12, 12, 5), armor_hi),
        add_box(name + "_helm", (loc[0], loc[1], loc[2] + 36), (14, 12, 9), armor),
        add_box(name + "_visor", (loc[0], loc[1] - 12.4, loc[2] + 36), (9, 1.2, 2.4), visor),
        add_box(name + "_crest", (loc[0], loc[1] - 1, loc[2] + 47), (4, 8, 7), violet),
        add_box(name + "_left_arm", (loc[0] - 18, loc[1], loc[2] + 12), (4.5, 5, 19), armor_hi),
        add_box(name + "_right_arm", (loc[0] + 18, loc[1], loc[2] + 12), (4.5, 5, 19), armor_hi),
        add_box(name + "_left_leg", (loc[0] - 7, loc[1], loc[2] - 15), (5.5, 6, 18), armor),
        add_box(name + "_right_leg", (loc[0] + 7, loc[1], loc[2] - 15), (5.5, 6, 18), armor),
        add_box(name + "_shield", (loc[0] - 25, loc[1] - 4, loc[2] + 10), (7, 3, 20), violet),
        add_cyl(name + "_spear", (loc[0] + 27, loc[1] - 3, loc[2] + 18), (1.8, 1.8, 31), metal, (0, 0.28, 0)),
        add_box(name + "_spear_tip", (loc[0] + 34, loc[1] - 3, loc[2] + 51), (5, 3, 7), metal),
    ]
    for part in parts:
        parent_to(part, root)
    return root


def build():
    bpy.ops.wm.read_factory_settings(use_empty=True)

    add_box("Prop_beam", (0, 0, 28), (13, 9, 30), (0.22, 0.18, 0.28))
    add_box("Prop_thorn", (40, 0, 30), (22, 22, 32), (0.18, 0.42, 0.2))
    add_box("Prop_water", (90, 0, 6), (46, 22, 8), (0.08, 0.52, 0.85))
    add_sentinel("Prop_rock", (150, 0, 26))

    add_cyl("Prop_coin", (210, 0, 10), (14, 14, 4), (0.98, 0.82, 0.22), (1.5708, 0, 0))

    add_box("Prop_pickup_magnet", (270, 0, 16), (16, 10, 22), (0.24, 0.78, 0.98))
    add_cyl("Prop_pickup_shield", (330, 0, 18), (16, 16, 6), (0.98, 0.28, 0.48), (0, 0, 0))
    add_box("Prop_pickup_double", (390, 0, 16), (18, 12, 18), (0.72, 0.38, 0.98))


def export_glb(path: str) -> None:
    candidates = [
        {
            "filepath": path,
            "check_existing": False,
            "export_format": "GLB",
            "export_animations": False,
            "export_materials": "EXPORT",
            "export_texcoords": True,
            "export_normals": True,
            "export_yup": True,
            "use_selection": False,
            "export_cameras": False,
            "export_lights": False,
        },
        {"filepath": path, "check_existing": False, "export_format": "GLB", "export_animations": False},
    ]
    last_err = None
    for opts in candidates:
        kw = _filter_kwargs(bpy.ops.export_scene.gltf, opts)
        try:
            bpy.ops.export_scene.gltf(**kw)
            return
        except Exception as e:
            last_err = e
            continue
    if last_err:
        raise last_err
    bpy.ops.export_scene.gltf(filepath=path, export_format="GLB")


try:
    build()
except Exception as e:
    print("build failed:", e, file=sys.stderr)
    sys.exit(3)

try:
    export_glb(out_path)
except Exception as e:
    print("export failed:", e, file=sys.stderr)
    sys.exit(4)

print("OK", out_path)
