Grigori Fursin converted the original sconscript 
from the [ARM Compute Library](https://github.com/ARM-software/ComputeLibrary)
into the CK format in order to add ARMCL to CK auto/crowd-tuning workflows.

To install the package from a separate branch (other than master), use the following command:

 $ ck install package:lib-armcl-opencl-master

You can also install a specific sub-branch as follows:
 $ ck install package:lib-armcl-opencl-master (--env.PACKAGE_GIT_CHECKOUT=your_branch --extra_version=-your_branch)

This will create a new env entry without conflicting with the already installed master entry.
