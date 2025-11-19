import paramak
from cadquery import Workplane, exporters
import cadquery_png_plugin.plugin

points = [(150, -700), (150, 0), (270, 0), (270, -700)]
divertor_lower = Workplane("XZ", origin=(0, 0, 0)).polyline(points).close().revolve(180)

my_reactor = paramak.spherical_tokamak_from_plasma(
    radial_build=[
        (paramak.LayerType.GAP, 10),
        (paramak.LayerType.SOLID, 50),
        (paramak.LayerType.SOLID, 15),
        (paramak.LayerType.GAP, 50),
        (paramak.LayerType.PLASMA, 300),
        (paramak.LayerType.GAP, 60),
        (paramak.LayerType.SOLID, 15),
        (paramak.LayerType.SOLID, 60),
        (paramak.LayerType.SOLID, 10),
    ],
    elongation=2,
    triangularity=0.55,
    rotation_angle=180,
    extra_intersect_shapes=[divertor_lower],
    colors={
        "layer_1": (0.4, 0.9, 0.4),
        "layer_2": (0.6, 0.8, 0.6),
        "plasma": (1.0, 0.7, 0.8, 0.6),
        "layer_3": (0.1, 0.1, 0.9),
        "layer_4": (0.4, 0.4, 0.8),
        "layer_5": (0.5, 0.5, 0.8),
        "divertor_lower": (1.0, 0.5, 0.0),
    },
)

compound = my_reactor.toCompound()

compound.exportStep("spherical_tokamak_from_plasma_with_divertor.step")
print("STEP file written.")

my_reactor.exportPNG(
    file_path="spherical_tokamak_from_plasma_with_divertor.png",
    options={
        "width": 1280,
        "height": 1024,
        "zoom": 1.4,
        "background_color": (1, 1, 1),
    },
)
print("PNG file written.")


top_view = Workplane("XZ").add(compound)
exporters.export(top_view, "spherical_tokamak_from_plasma_with_divertor.svg")
print("SVG file written (top view).")
