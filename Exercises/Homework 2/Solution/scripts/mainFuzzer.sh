#!/bin/bash

afl-fuzz -i /fuzzing/input -o /fuzzing/output -M $1 -- \
    /src/ImageMagick-7.0.8-12/utilities/magick @@ /dev/null
