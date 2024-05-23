#!/bin/bash

# Set the base command
base_command="./pbrt"

# Set the output directory for .pbrt files
pbrt_output_directory="../scenes/sanmiguel"

# Set the output directory for rendered images
rendered_output_directory="../scenes/sanmiguel/rendered_images"

# Set the image dimensions
width=64
height=64

# Set the number of samples per pixel for each image
spp_values=(1 4 8 4096)

# Set the number of camera positions to generate
num_cameras=1

# Start index
start_index=0

# Create the rendered output directory if it doesn't exist
mkdir -p "$rendered_output_directory"

# Define the camera parameters
camera_params=(
  "6.18231 -5.32462 7.12809 6.91043 -4.63988 7.09695 0.022689 0.0213372 0.999515 81.2026"
  "6.37319 -5.62511 1.53861 7.09618 -4.94254 1.64532 -0.0775949 -0.0732566 0.99429 83.9744"
  "22.8676 -12.9289 1.94784 22.2116 -12.1807 2.04755 0.065738 -0.0749807 0.995016 83.9744"
  "27.6255 -2.42353 1.49616 26.6582 -2.17012 1.48803 -0.00786446 0.00206023 0.999967 57.2209"
  "18.984 -12.0796 5.9334 18.3525 -11.3045 5.91336 -0.0126635 0.015543 0.999799 54.4322"
  "22.8676 -12.9289 1.94784 22.2116 -12.1807 2.04755 0.065738 -0.0749807 0.995016 83.9744"
  "4.42961 -1.89153 6.75331 5.40206 -1.65858 6.74488 0.00819354 0.00196274 0.999965 65.4705"
  "26.2755 -4.93625 7.15164 25.7736 -4.07249 7.19675 0.02266 -0.0389986 0.998982 73.7398"
  "26.6878 2.71626 7.31451 25.8663 2.14962 7.37751 0.0518586 0.0357671 0.998014 78.5788"
)

# Generate and render images for each camera position
for ((i=1; i<=num_cameras; i++))
do
  # Generate random camera parameters by interpolating between the given examples
  index1=$((RANDOM % ${#camera_params[@]}))
  index2=$((RANDOM % ${#camera_params[@]}))
  
  IFS=' ' read -r -a params1 <<< "${camera_params[$index1]}"
  IFS=' ' read -r -a params2 <<< "${camera_params[$index2]}"
  
  ratio=$(awk -v min=0 -v max=1 'BEGIN{srand(); print min+rand()*(max-min)}')
  
  eye_x=$(awk -v v1="${params1[0]}" -v v2="${params2[0]}" -v r="$ratio" 'BEGIN{print v1*(1-r)+v2*r}')
  eye_y=$(awk -v v1="${params1[1]}" -v v2="${params2[1]}" -v r="$ratio" 'BEGIN{print v1*(1-r)+v2*r}')
  eye_z=$(awk -v v1="${params1[2]}" -v v2="${params2[2]}" -v r="$ratio" 'BEGIN{print v1*(1-r)+v2*r}')
  
  lookat_x=$(awk -v v1="${params1[3]}" -v v2="${params2[3]}" -v r="$ratio" 'BEGIN{print v1*(1-r)+v2*r}')
  lookat_y=$(awk -v v1="${params1[4]}" -v v2="${params2[4]}" -v r="$ratio" 'BEGIN{print v1*(1-r)+v2*r}')
  lookat_z=$(awk -v v1="${params1[5]}" -v v2="${params2[5]}" -v r="$ratio" 'BEGIN{print v1*(1-r)+v2*r}')
  
  up_x=$(awk -v v1="${params1[6]}" -v v2="${params2[6]}" -v r="$ratio" 'BEGIN{print v1*(1-r)+v2*r}')
  up_y=$(awk -v v1="${params1[7]}" -v v2="${params2[7]}" -v r="$ratio" 'BEGIN{print v1*(1-r)+v2*r}')
  up_z=$(awk -v v1="${params1[8]}" -v v2="${params2[8]}" -v r="$ratio" 'BEGIN{print v1*(1-r)+v2*r}')
  
  fov=$(awk -v v1="${params1[9]}" -v v2="${params2[9]}" -v r="$ratio" 'BEGIN{print v1*(1-r)+v2*r}')
  
  pbrt_idx=$((start_index + i))
  
  # Create the .pbrt file with the interpolated camera parameters
  pbrt_file="${pbrt_output_directory}/random_camera_$pbrt_idx.pbrt"
  cat > "$pbrt_file" <<EOL
# Gtool Exporter Ver. 1.00 for pbrt v2.0 Render, www.pbrt.org 
# Created by Guillermo M. Leal LLaguno,  g.llaguno@evvisual.com,  www.evvisual.com 
# Exported on: $(date)
Scale -1 1 1

LookAt $eye_x $eye_y $eye_z
       $lookat_x $lookat_y $lookat_z
       $up_x $up_y $up_z

Camera "perspective"
    "float focaldistance" [ 1000000 ]
    "float lensradius" [ 0 ]
    "float shutterclose" [ 1 ]
    "float shutteropen" [ 0 ]
    "float fov" [ $fov ]

Film "rgb"
    "string filename" [ "${rendered_output_directory}/random_camera_${pbrt_idx}.exr" ]
    "float cropwindow" [ 0.025 0.975 0 1 ]
    "integer yresolution" [ $height ]
    "integer xresolution" [ $width ]

Sampler "halton"
    "integer pixelsamples" [ 2048 ]
Integrator "volpath"

WorldBegin

# Environment 
AttributeBegin
    Rotate 105 0 0 1
    LightSource "infinite"
        "float scale" [33]
        "string filename" "textures/sky.exr"
AttributeEnd

# ***** Lights ***** 
# ***** End  Lights *****

#Main File
Include "geometry/sanmiguel-mat.pbrt"
Include "geometry/sanmiguel-geom.pbrt"

#Trees
Include "geometry/arbol-mat.pbrt"
Include "geometry/troncoA-geom.pbrt"
Include "geometry/troncoB-geom.pbrt"

#Trees Leaves
Include "geometry/hojas_a1-geom.pbrt"
# tapa ventanas
Include "geometry/hojas_a2-geom.pbrt"
Include "geometry/hojas_a3-geom.pbrt"
Include "geometry/hojas_a4-geom.pbrt"
Include "geometry/hojas_a5-geom.pbrt"
# es arriba no se ve en cam9
Include "geometry/hojas_a6-geom.pbrt"
Include "geometry/hojas_a7-geom.pbrt"
Include "geometry/hojas_b2-geom.pbrt"
# rama abajo atravezada
Include "geometry/hojas_b3-geom.pbrt"
Include "geometry/hojas_b4-geom.pbrt"
# rama abajo atravezada

#Wall Ivy
Include "geometry/enredadera-mat.pbrt"
Include "geometry/enredadera-geom.pbrt"

#Pots
Include "geometry/macetas-mat.pbrt"
Include "geometry/macetas-geom.pbrt"

#Plants
Include "geometry/plantas-mat.pbrt"
Include "geometry/plantas-geom.pbrt"

#Tables Downstairs
Include "geometry/mesas_abajo-mat.pbrt"
Include "geometry/mesas_abajo-geom.pbrt"

#Tables Upstairs
Include "geometry/mesas_arriba-mat.pbrt"
Include "geometry/mesas_arriba-geom.pbrt"

#Table Downstairs open space
Include "geometry/mesas_patio-mat.pbrt"
Include "geometry/mesas_patio-geom.pbrt"

#Silverware
Include "geometry/platos-mat.pbrt"
Include "geometry/platos-geom.pbrt"
EOL

  for spp in "${spp_values[@]}"
  do
    spp_idx=$((start_index + i))
    # Render the image with different samples per pixel
    render_command="$base_command $pbrt_file --outfile ${rendered_output_directory}/random_camera_${spp_idx}_${spp}spp.exr --spp $spp"
    $render_command
  done
done
