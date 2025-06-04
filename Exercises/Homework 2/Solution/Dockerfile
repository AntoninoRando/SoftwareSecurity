FROM aflplusplus/aflplusplus@sha256:23edea458bcc1e5647b19bfba205f21408235972ce6b346c326dbeef179919d6

RUN apt-get update && apt-get install -y git

# Clone the ImageMagick
WORKDIR /src
RUN git clone --branch 7.0.8-12 --single-branch https://github.com/ImageMagick/ImageMagick.git ImageMagick-7.0.8-12
# COPY ImageMagick-7.0.8-12/ ./ImageMagick-7.0.8-12/

# Set environment variables for AFL++ and build ImageMagick
WORKDIR /src/ImageMagick-7.0.8-12
RUN chmod -R 777 .
ENV CC=afl-clang-fast
ENV CXX=afl-clang-fast++
ENV AFL_HARDEN=1

RUN ./configure && make
#RUN make PERFORMANCE=1 STATIC=1 clean all

# Create fuzzing directories for
# - Inputs
# - Outputs
# - Crashes
WORKDIR /fuzzing

RUN mkdir -p /input /output /crashes

COPY input/ ./input/
COPY scripts/ ./

# Make all scripts inside this directory executable (this is where scripts have
# been put)
RUN chmod -R +x .

# CMD ["./fuzz.sh"]
#RUN /src/ImageMagick-7.0.8-12/configure -help
CMD ["/src/ImageMagick-7.0.8-12/utilities/magick", "/fuzzing/input/id_000000", "/dev/null"]
# CMD ["sleep", "1d"]