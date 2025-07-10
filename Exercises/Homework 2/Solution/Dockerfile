FROM aflplusplus/aflplusplus@sha256:23edea458bcc1e5647b19bfba205f21408235972ce6b346c326dbeef179919d6

RUN apt-get update && apt-get install -y git

# Clone the ImageMagick
WORKDIR /src
RUN git clone --branch 7.0.8-12 --single-branch https://github.com/ImageMagick/ImageMagick.git ImageMagick-7.0.8-12

# Set environment variables for AFL++ and build ImageMagick
WORKDIR /src/ImageMagick-7.0.8-12
RUN chmod -R 777 .
ENV CC=afl-clang-fast
ENV CXX=afl-clang-fast++
ENV AFL_HARDEN=1

# cmd ["./configure", "--disable-shared", "--without-magick-plus-plus"]

RUN ./configure --disable-shared --without-magick-plus-plus --enable-static --with-modules=no --without-perl
RUN make
RUN make install
#RUN make PERFORMANCE=1 STATIC=1 clean all

# Create fuzzing directories for
# - Inputs
# - Outputs
# - Crashes
WORKDIR /fuzzing
RUN mkdir -p /input /output /crashes

# Copy the input files (installed locally) used to feed the fuzzing process
COPY input/ ./input/

# Copy some scripts files (installed locally) used to
# - Start a chronjob that cleans the temporary files;
# - Start the multiprocessing fuzzing
COPY scripts/ ./

# Make all scripts inside this directory executable (this is where scripts have
# been put)
RUN chmod -R +x .

# To start fuzzing use this inside the container CMD ["./fuzz.sh"]
CMD ["sleep", "infinity"]