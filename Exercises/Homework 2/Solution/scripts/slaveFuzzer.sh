#!/bin/bash

afl-fuzz -i /fuzzing/input -o /fuzzing/output -S $1 -- \
    /src/ImageMagick-7.0.8-12/utilities/magick @@ /dev/null
