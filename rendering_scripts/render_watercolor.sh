#!/bin/bash

# Set the base command
base_command="./pbrt"

# Set the output directory for .pbrt files
pbrt_output_directory="../scenes/watercolor/watercolor"

# Set the output directory for rendered images
rendered_output_directory="../scenes/watercolor/watercolor/rendered_images"

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
  "221.141205 122.646004 2.43404675 220.141205 122.646004 2.43404675 0 1 0 43.6028175"
  "-2.70786691 85.4769516 240.523529 -3.30121756 85.4485712 239.718582 -0.00141029898 0.999997199 -0.00191321515 22.6198654"
  "247.908615 63.4503365 125.32412 246.917603 63.4553365 125.1903 0 1 0 20.4079475"
  "246.201401 177.455338 38.538826 245.696762 176.740402 38.0548897 -0.516015887 0.699185967 -0.494840115 22.6198654"
  "231.791519 163.256424 77.3447189 231.243347 162.608231 76.8161774 -0.466618747 0.76148057 -0.44990477 22.6198654"
  "358.792725 159.74118 130.585327 358.095184 159.441794 129.927216 -0.20613049 0.95900476 -0.194474444 20.4079475"
  "228.181671 108.324684 60.8531647 227.389389 107.985006 60.3038864 -0.218338758 0.964061737 -0.151371002 33.3984871"
  "391.732391 57.1305923 -59.5856857 390.765076 57.1845923 -59.8392906 0 1 0 22.6198654"
  "293.330475 69.1135712 197.498505 292.414734 69.1479712 197.09671 0 1 0 22.6198654"
  "140.623962 374.252136 121.081261 140.667336 373.491901 120.814781 -0.472102582 0.197434932 -0.859149933 25.3607674"
  "216.766861 174.562012 -13.0396824 216.766861 173.562012 -13.0396824 0 -4.37113883e-08 -1 53.1301041"
  "344.962891 282.066315 270.674042 344.456451 281.543854 269.988068 -0.310310006 0.852665007 -0.420321375 28.3370457"
  "-10.1574497 120.926613 237.061615 -11.1574497 120.926613 237.061615 0 1 0 28.841547"
  "314.481476 150.663147 -87.968811 313.750366 150.06 -88.0103607 -0.679901421 0.732284725 -0.038640365 25.3607674"
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
Sampler "halton"

Integrator "volpath" "integer maxdepth" 15

Film "gbuffer"
     "integer yresolution" [ $height ] "integer xresolution" [ $width ]
     "string filename" [ "random_camera_$i.exr" ]

Scale -1 1 1

LookAt $eye_x $eye_y $eye_z
       $lookat_x $lookat_y $lookat_z
       $up_x $up_y $up_z

Camera "perspective"
       "float fov" [ $fov ]

WorldBegin
Include "lights-no-windowglass.pbrt"
Include "materials.pbrt"
Include "geometry.pbrt"
EOL

  for spp in "${spp_values[@]}"
  do
    spp_idx=$((start_index + i))
    # Render the image with different samples per pixel
    render_command="$base_command $pbrt_file --outfile ${rendered_output_directory}/random_camera_${spp_idx}_${spp}spp.exr --spp $spp"
    $render_command
  done
done
