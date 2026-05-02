"""
Headless: build a low-poly endless-runner style 3D backdrop (ground + silhouettes) and export GLB.

Usage:
  blender -b -P scripts/blender_build_runner_env.py -- assets/environment.glb

No textures — Principled materials only (small file, mobile-friendly).
Axes: Blender Z-up; glTF export uses export_yup for Three.js.
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
out_path = os.path.abspath(argv[0]) if argv else os.path.join(root, "assets", "environment.glb")
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


def make_mat(name: str, rgb, roughness: float = 0.9):
    mat = bpy.data.materials.new(name=name)
    mat.use_nodes = True
    nt = mat.node_tree
    nodes = nt.nodes
    links = nt.links
    for n in list(nodes):
        nodes.remove(n)
    out = nodes.new(type="ShaderNodeOutputMaterial")
    bsdf = nodes.new(type="ShaderNodeBsdfPrincipled")
    bsdf.location = (0, 0)
    out.location = (280, 0)
    bsdf.inputs["Roughness"].default_value = roughness
    bsdf.inputs["Base Color"].default_value = (rgb[0], rgb[1], rgb[2], 1.0)
    links.new(bsdf.outputs["BSDF"], out.inputs["Surface"])
    return mat


def build_scene():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    col = bpy.data.collections.new("RunnerEnv")
    bpy.context.scene.collection.children.link(col)

    def link(obj):
        for c in obj.users_collection:
            c.objects.unlink(obj)
        col.objects.link(obj)

    # Floor: thin slab, wide X, long Y (forward into scene), Z = thickness (up)
    bpy.ops.mesh.primitive_cube_add(size=2, location=(0, 180, -6))
    floor = bpy.context.active_object
    floor.name = "EnvFloor"
    floor.scale = (1400, 420, 10)
    link(floor)

    # Soft purple ground tone (Lumendale-ish)
    mat_floor = make_mat("EnvFloorMat", (0.22, 0.12, 0.28), 0.95)
    floor.data.materials.append(mat_floor)

    # Mid-ground hills / castle silhouette — stretched cubes
    silhouettes = [
        (-520, 280, 95, 55, 140, 90),
        (-260, 320, 70, 50, 110, 120),
        (0, 300, 85, 60, 190, 100),
        (260, 310, 65, 48, 130, 85),
        (480, 290, 75, 52, 160, 95),
        (-820, 260, 55, 40, 90, 70),
        (780, 270, 60, 45, 100, 75),
    ]
    mat_castle = make_mat("EnvCastleMat", (0.35, 0.18, 0.42), 0.88)
    mat_spire = make_mat("EnvSpireMat", (0.5, 0.35, 0.62), 0.82)

    for i, (x, y, zc, sx, sy, sz) in enumerate(silhouettes):
        bpy.ops.mesh.primitive_cube_add(size=2, location=(x, y, zc + sz * 0.25))
        ob = bpy.context.active_object
        ob.name = "EnvSilhouette_%02d" % i
        ob.scale = (sx, sy, sz * 0.5)
        ob.data.materials.append(mat_castle if i % 2 == 0 else mat_spire)
        link(ob)

    # Distant “battlements” row
    for j in range(-6, 7):
        bx = j * 165 + (j % 3) * 12
        bpy.ops.mesh.primitive_cube_add(size=2, location=(bx, 520, 45))
        t = bpy.context.active_object
        t.name = "EnvBattlement_%02d" % (j + 6)
        t.scale = (38 + (j % 4) * 6, 24, 42 + (j % 5) * 8)
        t.data.materials.append(mat_spire)
        link(t)

    # Near-side lane edges (subtle)
    for side, xx in ((-1, -620), (1, 620)):
        bpy.ops.mesh.primitive_cube_add(size=2, location=(xx, 80, 4))
        e = bpy.context.active_object
        e.name = "EnvEdge_" + ("L" if side < 0 else "R")
        e.scale = (14, 300, 6)
        e.data.materials.append(make_mat("EnvEdgeMat", (0.15, 0.08, 0.22), 0.9))
        link(e)


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
    build_scene()
except Exception as e:
    print("build_scene failed:", e, file=sys.stderr)
    sys.exit(3)

try:
    export_glb(out_path)
except Exception as e:
    print("export failed:", e, file=sys.stderr)
    sys.exit(4)

print("OK", out_path)
