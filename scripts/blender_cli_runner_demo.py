"""
Headless Blender: procedural runner mesh + armature + game-ready animation clips → GLB.

Exports clips named for Crown Dash `charClipForGameAnim` matching:
  Idle, Run, Jump, Fall, Land, Hurt, Dash

Use as placeholder motion (`assets/runner_cli_demo.glb`) or retarget in Blender onto
your real princess mesh. Does not replace hand-authored animation on production art.

Usage:
  blender -b -P scripts/blender_cli_runner_demo.py -- [output.glb]

Default output (when argv omitted): <repo>/assets/runner_cli_demo.glb
"""
from __future__ import annotations

import math
import os
import sys


def _argv_dd():
    if "--" in sys.argv:
        return sys.argv[sys.argv.index("--") + 1 :]
    return []


def _repo_root():
    here = os.path.dirname(os.path.abspath(__file__))
    return os.path.dirname(here)


argv = _argv_dd()
ROOT = _repo_root()
DEFAULT_OUT = os.path.join(ROOT, "assets", "runner_cli_demo.glb")
out_path = os.path.abspath(argv[0]) if argv else DEFAULT_OUT
os.makedirs(os.path.dirname(out_path) or ".", exist_ok=True)


def main():
    import bpy

    bpy.ops.wm.read_factory_settings(use_empty=True)

    # --- Mesh: simple torso + head (joined) ---------------------------------
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0.0, 0.0, 1.02))
    body = bpy.context.active_object
    body.name = "RunnerMesh"
    body.scale = (0.34, 0.2, 0.48)
    bpy.ops.object.transform_apply(scale=True)

    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.13, segments=16, ring_count=12, location=(0.0, 0.0, 1.52))
    head = bpy.context.active_object
    head.name = "HeadTemp"

    bpy.ops.object.select_all(action="DESELECT")
    head.select_set(True)
    body.select_set(True)
    bpy.context.view_layer.objects.active = body
    bpy.ops.object.join()
    mesh_obj = bpy.context.active_object
    mesh_obj.name = "RunnerMesh"

    # --- Armature -------------------------------------------------------------
    bpy.ops.object.armature_add(location=(0.0, 0.0, 0.0))
    arm_obj = bpy.context.active_object
    arm_obj.name = "RunnerArmature"
    arm_data = arm_obj.data
    arm_data.name = "RunnerArmatureData"

    bpy.context.view_layer.objects.active = arm_obj
    bpy.ops.object.mode_set(mode="EDIT")
    eb = arm_data.edit_bones
    while eb:
        eb.remove(eb[0])

    def eb_new(name, head_p, tail_p):
        b = eb.new(name)
        b.head = head_p
        b.tail = tail_p
        return b

    root = eb_new("Root", (0.0, 0.0, 0.05), (0.0, 0.0, 0.75))
    spine = eb_new("Spine", (0.0, 0.0, 0.78), (0.0, 0.0, 1.05))
    spine.parent = root
    chest = eb_new("Chest", (0.0, 0.0, 1.08), (0.0, 0.0, 1.38))
    chest.parent = spine
    neck = eb_new("Neck", (0.0, 0.0, 1.4), (0.0, 0.0, 1.52))
    neck.parent = chest
    head_b = eb_new("Head", (0.0, 0.0, 1.55), (0.0, 0.0, 1.72))
    head_b.parent = neck

    upleg_l = eb_new("UpperLeg_L", (0.0, 0.0, 0.72), (0.12, 0.0, 0.38))
    upleg_l.parent = root
    lowleg_l = eb_new("LowerLeg_L", (0.12, 0.0, 0.38), (0.12, 0.0, 0.06))
    lowleg_l.parent = upleg_l

    upleg_r = eb_new("UpperLeg_R", (0.0, 0.0, 0.72), (-0.12, 0.0, 0.38))
    upleg_r.parent = root
    lowleg_r = eb_new("LowerLeg_R", (-0.12, 0.0, 0.38), (-0.12, 0.0, 0.06))
    lowleg_r.parent = upleg_r

    bpy.ops.object.mode_set(mode="OBJECT")

    # Parent mesh with automatic weights
    bpy.ops.object.select_all(action="DESELECT")
    mesh_obj.select_set(True)
    arm_obj.select_set(True)
    bpy.context.view_layer.objects.active = arm_obj
    bpy.ops.object.parent_set(type="ARMATURE_AUTO")

    # --- Materials (simple) -------------------------------------------------
    mat = bpy.data.materials.new(name="RunnerDemoMat")
    mat.use_nodes = True
    nt = mat.node_tree
    for n in nt.nodes:
        nt.nodes.remove(n)
    out = nt.nodes.new("ShaderNodeOutputMaterial")
    bsdf = nt.nodes.new("ShaderNodeBsdfPrincipled")
    bsdf.inputs["Base Color"].default_value = (0.78, 0.55, 0.62, 1.0)
    bsdf.inputs["Roughness"].default_value = 0.65
    nt.links.new(bsdf.outputs["BSDF"], out.inputs["Surface"])
    mesh_obj.data.materials.append(mat)

    scene = bpy.context.scene
    scene.frame_start = 1
    scene.frame_end = 48

    # --- Actions: Idle / Run / Jump -----------------------------------------
    def push_pose(frame, pose_rots):
        bpy.context.view_layer.objects.active = arm_obj
        bpy.ops.object.mode_set(mode="POSE")
        for bone_name, euler in pose_rots.items():
            pb = arm_obj.pose.bones[bone_name]
            pb.rotation_mode = "XYZ"
            pb.rotation_euler = euler
            pb.keyframe_insert(data_path="rotation_euler", frame=frame)

        bpy.ops.object.mode_set(mode="OBJECT")

    idle_frames = [
        (
            1,
            {
                "Chest": (0.05, 0.0, 0.0),
                "UpperLeg_L": (0.0, 0.0, 0.05),
                "UpperLeg_R": (0.0, 0.0, -0.05),
            },
        ),
        (
            24,
            {
                "Chest": (-0.04, 0.0, 0.0),
                "UpperLeg_L": (0.0, 0.0, -0.05),
                "UpperLeg_R": (0.0, 0.0, 0.05),
            },
        ),
        (
            48,
            {
                "Chest": (0.05, 0.0, 0.0),
                "UpperLeg_L": (0.0, 0.0, 0.05),
                "UpperLeg_R": (0.0, 0.0, -0.05),
            },
        ),
    ]

    run_frames = [
        (1, {"UpperLeg_L": (0.55, 0.0, 0.0), "UpperLeg_R": (-0.35, 0.0, 0.0), "Chest": (0.12, 0.0, 0.0)}),
        (8, {"UpperLeg_L": (-0.2, 0.0, 0.0), "UpperLeg_R": (0.45, 0.0, 0.0), "Chest": (0.1, 0.0, 0.0)}),
        (16, {"UpperLeg_L": (0.55, 0.0, 0.0), "UpperLeg_R": (-0.35, 0.0, 0.0), "Chest": (0.12, 0.0, 0.0)}),
    ]

    jump_frames = [
        (1, {"UpperLeg_L": (0.38, 0.0, 0.0), "UpperLeg_R": (0.38, 0.0, 0.0), "Chest": (-0.1, 0.0, 0.0)}),
        (4, {"UpperLeg_L": (0.15, 0.0, 0.0), "UpperLeg_R": (0.15, 0.0, 0.0), "Chest": (-0.02, 0.0, 0.0)}),
        (8, {"Root": (0.42, 0.0, 0.0), "UpperLeg_L": (-0.45, 0.0, 0.0), "UpperLeg_R": (-0.45, 0.0, 0.0), "Chest": (0.08, 0.0, 0.0)}),
        (14, {"Root": (0.12, 0.0, 0.0), "UpperLeg_L": (-0.28, 0.0, 0.0), "UpperLeg_R": (-0.28, 0.0, 0.0), "Chest": (0.05, 0.0, 0.0)}),
        (20, {"Root": (0.0, 0.0, 0.0), "UpperLeg_L": (0.05, 0.0, 0.0), "UpperLeg_R": (0.05, 0.0, 0.0)}),
    ]

    fall_frames = [
        (1, {"Chest": (0.16, 0.0, 0.0), "UpperLeg_L": (-0.22, 0.0, 0.0), "UpperLeg_R": (-0.22, 0.0, 0.0), "Head": (0.08, 0.0, 0.0)}),
        (12, {"Chest": (0.2, 0.0, 0.0), "UpperLeg_L": (-0.28, 0.0, 0.08), "UpperLeg_R": (-0.28, 0.0, -0.08)}),
        (24, {"Chest": (0.16, 0.0, 0.0), "UpperLeg_L": (-0.22, 0.0, 0.0), "UpperLeg_R": (-0.22, 0.0, 0.0), "Head": (0.08, 0.0, 0.0)}),
    ]

    land_frames = [
        (1, {"UpperLeg_L": (0.82, 0.0, 0.0), "UpperLeg_R": (0.82, 0.0, 0.0), "Chest": (-0.22, 0.0, 0.0), "Root": (-0.08, 0.0, 0.0)}),
        (5, {"UpperLeg_L": (0.48, 0.0, 0.0), "UpperLeg_R": (0.48, 0.0, 0.0), "Chest": (-0.05, 0.0, 0.0), "Root": (-0.02, 0.0, 0.0)}),
        (12, {"UpperLeg_L": (0.18, 0.0, 0.0), "UpperLeg_R": (0.18, 0.0, 0.0), "Chest": (0.06, 0.0, 0.0), "Root": (0.0, 0.0, 0.0)}),
    ]

    hurt_frames = [
        (1, {"Chest": (-0.42, 0.0, 0.14), "Head": (0.32, 0.0, -0.1), "Spine": (0.0, 0.0, 0.18)}),
        (6, {"Chest": (-0.15, 0.0, 0.06), "Head": (0.1, 0.0, -0.04)}),
        (14, {"Chest": (0.04, 0.0, 0.0), "Head": (0.0, 0.0, 0.0), "Spine": (0.0, 0.0, 0.0)}),
    ]

    dash_frames = [
        (1, {"UpperLeg_L": (0.62, 0.0, 0.0), "UpperLeg_R": (-0.48, 0.0, 0.0), "Chest": (0.26, 0.0, 0.0)}),
        (5, {"UpperLeg_L": (-0.18, 0.0, 0.0), "UpperLeg_R": (0.58, 0.0, 0.0), "Chest": (0.24, 0.0, 0.0)}),
        (10, {"UpperLeg_L": (0.62, 0.0, 0.0), "UpperLeg_R": (-0.48, 0.0, 0.0), "Chest": (0.26, 0.0, 0.0)}),
    ]

    def strip_to_action(name, frames):
        arm_obj.animation_data_clear()
        arm_obj.animation_data_create()
        act = bpy.data.actions.new(name=name)
        arm_obj.animation_data.action = act
        for fr, rots in frames:
            push_pose(fr, rots)
        act.use_fake_user = True
        return act

    idle_act = strip_to_action("Idle", idle_frames)
    run_act = strip_to_action("Run", run_frames)
    jump_act = strip_to_action("Jump", jump_frames)
    fall_act = strip_to_action("Fall", fall_frames)
    land_act = strip_to_action("Land", land_frames)
    hurt_act = strip_to_action("Hurt", hurt_frames)
    dash_act = strip_to_action("Dash", dash_frames)

    # One NLA strip per track (glTF exporter requirement in 'actions' mode).
    arm_obj.animation_data_clear()
    arm_obj.animation_data_create()
    for tname, act, start in (
        ("Idle", idle_act, 1),
        ("Run", run_act, 55),
        ("Jump", jump_act, 105),
        ("Fall", fall_act, 165),
        ("Land", land_act, 225),
        ("Hurt", hurt_act, 275),
        ("Dash", dash_act, 325),
    ):
        tr = arm_obj.animation_data.nla_tracks.new()
        tr.name = tname
        tr.strips.new(tname, start, act)

    scene.frame_start = 1
    scene.frame_end = 400

    # --- Export GLB -----------------------------------------------------------
    kw = {
        "filepath": out_path,
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
        "export_nla_strips": True,
        "export_bake_animation": True,
    }

    try:
        bpy.ops.export_scene.gltf(**kw)
    except TypeError:
        kw.pop("export_bake_animation", None)
        bpy.ops.export_scene.gltf(**kw)

    print("OK", out_path)


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print("ERROR:", e, file=sys.stderr)
        import traceback

        traceback.print_exc()
        sys.exit(1)
