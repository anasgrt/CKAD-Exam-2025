#!/bin/bash
#===============================================================================
# SOLUTION: Question 13 - Docker Build + OCI Export
#===============================================================================

# Step 1: Review the Dockerfile
cat /tmp/app/Dockerfile

# Step 2: Build the image (Docker)
cd /tmp/app
docker build -t myapp:v1 .

# OR using Podman:
# podman build -t myapp:v1 .

# Step 3: Verify image was created
docker images myapp:v1
# OR: podman images myapp:v1

# Step 4: Export to OCI format (tar file)
docker save -o /tmp/myapp-v1.tar myapp:v1

# OR using Podman:
# podman save -o /tmp/myapp-v1.tar myapp:v1

# Step 5: Verify export
ls -la /tmp/myapp-v1.tar
tar -tf /tmp/myapp-v1.tar | head -20

#===============================================================================
# KEY POINTS - DOCKER/PODMAN COMMANDS:
#===============================================================================
# Build:
#   docker build -t <tag> <path>
#   docker build -t myapp:v1 .
#   docker build -t myapp:v1 -f Dockerfile.custom .
#
# Save/Export:
#   docker save -o <output.tar> <image>         # Save image to tar
#   docker export <container> > file.tar        # Export container filesystem
#
# Load/Import:
#   docker load -i <file.tar>                   # Load image from tar
#   docker import <file.tar> <new_image>        # Import as new image
#
# Tag:
#   docker tag <image> <new_tag>
#
# Push:
#   docker push <registry>/<image>:<tag>
#===============================================================================

#===============================================================================
# OCI FORMAT:
#===============================================================================
# OCI (Open Container Initiative) is a standard format for container images.
# docker save produces Docker format by default, compatible with OCI.
# For strict OCI format, use:
#   skopeo copy docker-daemon:myapp:v1 oci-archive:/tmp/myapp-v1.tar
#===============================================================================

: '
================================================================================
⚡ FASTEST EXAM APPROACH (< 30 seconds)
================================================================================
Two commands only!

1. Build the image (10 sec)
   cd /tmp/app && docker build -t myapp:v1 .

2. Save to tar file (10 sec)
   docker save -o /tmp/myapp-v1.tar myapp:v1

3. Verify (10 sec)
   ls -la /tmp/myapp-v1.tar

TIP: docker build -t <name:tag> <path>
     docker save -o <output.tar> <image:tag>
These are the ONLY commands you need for this question!
================================================================================
'
