import paramak
from cadquery import exporters
import cadquery_png_plugin.plugin

my_reactor = paramak.tokamak_from_plasma(
    radial_build=[
        (paramak.LayerType.GAP, 10),
        (paramak.LayerType.SOLID, 30),
        (paramak.LayerType.SOLID, 50),
        (paramak.LayerType.SOLID, 10),
        (paramak.LayerType.SOLID, 120),
        (paramak.LayerType.SOLID, 20),
        (paramak.LayerType.GAP, 60),
        (paramak.LayerType.PLASMA, 300),
        (paramak.LayerType.GAP, 60),
        (paramak.LayerType.SOLID, 20),
        (paramak.LayerType.SOLID, 120),
        (paramak.LayerType.SOLID, 10),
    ],
    elongation=2,
    triangularity=0.55,
    rotation_angle=180,
    colors={
        "layer_1": (0.4, 0.9, 0.4),
        "layer_2": (0.6, 0.8, 0.6),
        "plasma": (1., 0.7, 0.8, 0.6),
        "layer_3": (0.1, 0.1, 0.9),
        "layer_4": (0.4, 0.4, 0.8),
        "layer_5": (0.5, 0.5, 0.8),
    }
)

exporters.export(my_reactor.toCompound(), "tokamak_with_colors.step")
print("Saved tokamak_with_colors.step")

my_reactor.exportPNG(
    options={
        "width": 1280,
        "height": 1024,
        "zoom": 1.4,
    },
    file_path="tokamak_from_plasma_with_colors.png"
)
print("Saved tokamak_from_plasma_with_colors.png")
