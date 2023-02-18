This codebase, as found here (https://github.com/RMIT-DFAM/AM_particle_detection),
was developed for use for the following publication (DOI: 10.1108/RPJ-07-2022-0225).

Please cite both the publication and GitHub repository if using or modifying this work.

//

This codebase is used to generate a basic, thresholded, microCT test dataset equivalent. Using cylinders and spheres, the intent is to generate a 3D 
model of a circle intersecting a cyclinder, rotate the view to be looking from a birds eye view and record the result within a black and white image.
This works recursively based on you chosen parameters.

This code was used as a part of Figure 14 of the priorly described publication, generating a 3D model by combining two datasets from this codebase.

Variables for this code were implemented manually. The variables include:

Cylinder Radius

Cylinder Height

Sphere Offset 
 => How far the sphere origin is positioned to the left (select negative value) or the right (select positive value) of the cylinder radius.

Sphere Radius
 => In the current format, the sphere radius per slice layer is not actually analogous to the spherical curve of a sphere, it just reduces by a factor 
of one unit each iteration.





