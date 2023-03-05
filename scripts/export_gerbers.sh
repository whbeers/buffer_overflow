#!/bin/bash

project=$(basename $(pwd))
pcb_file="hardware/${project}.kicad_pcb"

if [[ -f "$pcb_file" ]]; then
  pcb_revision=$(grep '\(rev \"\)' "$pcb_file" | awk -F\" '{print $2}') 
  if [[ -z "$pcb_revision" ]]; then
    echo "Could not determine revision."
    exit 1
  fi

  mkdir -p fabrication/$pcb_revision 2>/dev/null
  pushd fabrication/$pcb_revision
  rm * 2>/dev/null
  kicad-cli pcb export drill "../../$pcb_file" --excellon-separate-th --format gerber --generate-map --map-format gerberx2
  kicad-cli pcb export gerbers "../../$pcb_file" -l "F.Cu,B.Cu,F.SilkS,B.SilkS,F.Mask,B.Mask,Edge.Cuts"
  zip "$project-$pcb_revision-gerbers.zip" *
  popd

else
  echo "PCB file not found."
  exit 1
fi

