# Coockbook "plate-mesh"

The following steps have been done to create the file `plate-mesh-min.pdf`

- Convert the Gmsh-Files (*.MSH) to FBX

- Import the FBX-Files to Blender and arrange them (including camera)

- Install the "Freestyle SVG Exporter" to Blender: 
  https://extensions.blender.org/add-ons/freestyle-svg-exporter/

- Activate Freestyle rendering in Blender (Render Properties)

- Activate "Freestyle SVG Export" (Render Properties)

- Remove the "Sampling" Modifier in "Freestyle Geometry" (View Layer)

- Render the image with Blender; a SVG file is written (by default to "C:\tmp")

- Minify the SVG using https://www.svgminify.com/ and save the result (again, a SVG)

- Use https://optimize.svgomg.net/ (online-tool using https://github.com/svg/svgo) for the SVG created in the last step and further reduce the file size. Download the result.

- Open the resulting SVG in Inkscape.

- In "Document Properties..." (menu "File") click "resize to content"

- Save the image as PDF.

- Done.