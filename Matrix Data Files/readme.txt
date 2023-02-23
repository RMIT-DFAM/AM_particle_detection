The RAR archive file contained in this subfolder contiains three matrix files (in ".mat" format), as well as three associated text files (in ".log" format).

The ".mat" files contains data that is saved out from "Particle_Detection_Algorithm_v6.m"
The ".log" files contains the log data generated from the Micro CT reconstruction program (which takes projection data and reconstructs layer slice-data.

The ".mat" files contains the following saved out data:

imgStack                      = Details from image stack / set of reconstructed slice data
imgStackInfo                  = Details from image stack / set of reconstructed slice data
mmPerPixelFinal               = Scaled Image Pixel Size as extracted from reconstruction log files
densityThresholdLow           = Lower threshold value for binarization
densityThresholdHigh          = Upper threshold value for binarization
CC                            = List of connected components from bwconncomp - MATLAB Command 
imgStack_Adjusted_saveOut     = Adjusted data from image stack after binarization
polyBounds                    = Polygonal Boundary information
polyBoundsLength              = Data of Length of Polygonal Boundaries
bounds                        = Data on different boundary classifications

The ".log" files contains information regarding Scaled Image Pixel Size, which is saved in mmPerPixelFinal.

//

The files contained in the RAR archive have been used with the following publication: 

"Algorithmic Detection And Categorization Of Partially Attached Particles In AM Structures: A Non-Destructive Method For The Certification Of Lattice Implants"

The Publication can be found here = DOI:10.1108/RPJ-07-2022-0225

The Publication and GitHub repository should both be cited if these files are used.
