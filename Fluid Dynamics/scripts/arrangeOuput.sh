#!/bin/bash

mkdir -p output
for file in ../output/fluid_*.png; do
    base=$(basename "$file" .png)
    vfile="../output/fluid_v_${base#fluid_}.png"
    if [[ -f "$vfile" ]]; then
        magick "$file" -colorspace sRGB \( -size 24x258 canvas:"rgb(64,64,64)" \) "$vfile" +append "output/$file"
    fi
done

ffmpeg -r 15 -f image2 -s 100x100  -i output/fluid_%06d.png -vcodec libx264 -crf 25 -pix_fmt yuv420p output/fluid-demo.mp4