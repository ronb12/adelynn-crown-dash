"""
Build a Blender scene with your Crown Dash 2D sprites as vertical reference planes.

This does NOT auto-generate a mesh from pixels — you model the 3D character in Blender
using these planes as tracing guides (normal workflow for 2D→3D).

Launch (GUI — opens Blender):
  blender --python scripts/blender_sprite_reference_setup.py -- /absolute/path/to/assets

Optional env before Blender starts:
  SPRITE_REF_HEIGHT=1.75   — world height of each sprite plane in Blender units (meters-ish).

After modeling: Export → glTF 2.0 (.glb) to assets/character.glb, or use npm run convert:character
from an FBX export.
"""
from __future__ import annotations

import math
import os
import sys


def _argv_dd():
    if "--" in sys.argv:
        return sys.argv[sys.argv.index("--") + 1 :]
    return []


args = _argv_dd()
ASSET_DIR = os.path.abspath(args[0]) if args else os.getcwd()
REF_HEIGHT = float(os.environ.get("SPRITE_REF_HEIGHT", "1.72"))

# Prefer side-view / atlas frames that exist in this repo.
REF_FILES = [
    "run_0.png",
    "idle_0.png",
    "jump_0.png",
    "dash_0.png",
    "adelynn_princess_sheet.png",
    "adelynn_atlas.png",
]


def main():
    import bpy

    bpy.ops.wm.read_factory_settings(use_empty=True)

    col_name = "SpriteReferences"
    col = bpy.data.collections.new(col_name)
    bpy.context.scene.collection.children.link(col)

    spacing = REF_HEIGHT * 0.55
    base_x = 0.0
    idx = 0

    for fname in REF_FILES:
        path = os.path.join(ASSET_DIR, fname)
        if not os.path.isfile(path):
            continue

        img = bpy.data.images.load(path, check_existing=True)

        iw = max(img.size[0], 1)
        ih = max(img.size[1], 1)
        aspect = iw / ih

        bpy.ops.mesh.primitive_plane_add(size=2.0, location=(base_x + idx * spacing, 0, REF_HEIGHT * 0.5))
        ob = bpy.context.active_object
        ob.name = "Ref_" + os.path.splitext(fname)[0]

        # Vertical billboard (XZ), facing +Y for modeling from front/side usual angles.
        ob.rotation_euler = (math.pi / 2.0, 0.0, 0.0)

        # Plane default is 2×2 in XY; after 90° X, spans X and Z. Scale to desired pixel aspect & height.
        z_world = REF_HEIGHT
        x_world = z_world * aspect
        ob.scale = (x_world / 2.0, 1.0, z_world / 2.0)

        mat = bpy.data.materials.new(name="Mat_" + fname)
        mat.use_nodes = True
        mat.blend_method = "CLIP"
        nt = mat.node_tree
        for n in nt.nodes:
            nt.nodes.remove(n)
        out = nt.nodes.new("ShaderNodeOutputMaterial")
        bsdf = nt.nodes.new("ShaderNodeBsdfPrincipled")
        tex = nt.nodes.new("ShaderNodeTexImage")
        tex.image = img
        tex.location = (-320, 240)
        bsdf.location = (0, 240)
        out.location = (280, 240)
        nt.links.new(tex.outputs["Color"], bsdf.inputs["Base Color"])
        nt.links.new(tex.outputs["Alpha"], bsdf.inputs["Alpha"])
        bsdf.inputs["Roughness"].default_value = 1.0
        bsdf.inputs["Metallic"].default_value = 0.0
        nt.links.new(bsdf.outputs["BSDF"], out.inputs["Surface"])

        ob.data.materials.append(mat)

        for c in ob.users_collection:
            c.objects.unlink(ob)
        col.objects.link(ob)

        idx += 1

    # Lights so refs are visible in Solid/Material preview.
    bpy.ops.object.light_add(type="AREA", location=(4.0 * spacing, -4.0, 5.0))
    bpy.context.active_object.data.energy = 800
    bpy.ops.object.light_add(type="AREA", location=(-2.0 * spacing, 4.0, 3.0))
    bpy.context.active_object.data.energy = 400

    # Camera for convenience (orthographic-ish framing).
    bpy.ops.object.camera_add(location=(0.0, -6.5 * spacing, REF_HEIGHT * 0.45))
    cam = bpy.context.active_object
    cam.data.type = "ORTHO"
    cam.data.ortho_scale = max(6.0 * spacing, REF_HEIGHT * 3.2)
    bpy.context.scene.camera = cam

    world = bpy.context.scene.world
    if world is None:
        world = bpy.data.worlds.new("World")
        bpy.context.scene.world = world
    world.use_nodes = False
    world.color = (0.06, 0.06, 0.07)

    print("Sprite reference scene OK.")
    print("  Assets:", ASSET_DIR)
    print("  Planes:", idx)
    print("  Next: model meshes over these refs → Export glTF Binary → assets/character.glb")


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print("ERROR:", e, file=sys.stderr)
        sys.exit(1)
