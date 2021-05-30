#!/usr/bin/env bash

# Requirements
# brew install node imagemagick
# npm install svgexport -g

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

makeIcon() {
  input="$1"
  output="$2"
  npx svgexport "${input}" "${input}_32x32.png" 32:32
  npx svgexport "${input}" "${input}_16x16.png" 16:16
  convert -units PixelsPerInch -density 144 "${input}_32x32.png" "${input}_32x32.tiff"
  convert -units PixelsPerInch -density 72  "${input}_16x16.png" "${input}_16x16.tiff"
  convert "${input}_32x32.tiff" "${input}_16x16.tiff" "${output}"
  rm -f "${input}_32x32.png" "${input}_16x16.png" "${input}_32x32.tiff" "${input}_16x16.tiff"
}

makeIcon "${DIR}/statusicon_on.svg" "${DIR}/statusicon_on.tiff"
makeIcon "${DIR}/statusicon_off.svg" "${DIR}/statusicon_off.tiff"

