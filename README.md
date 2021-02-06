[![compatibility](https://github.com/ctuning/ck-guide-images/blob/master/ck-compatible.svg)](https://github.com/ctuning/ck)
[![automation](https://github.com/ctuning/ck-guide-images/blob/master/ck-artifact-automated-and-reusable.svg)](http://cTuning.org/ae)

[![DOI](https://zenodo.org/badge/61487596.svg)](https://zenodo.org/badge/latestdoi/61487596)
[![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)

**All CK components can be found at [cKnowledge.io](https://cKnowledge.io) and in [one GitHub repository](https://github.com/ctuning/ai)!**

*This project is hosted by the [cTuning foundation](https://cTuning.org).*

This Collective Knowledge repository contains various mathematical libraries 
in the [portable and customizable CK format](http://github.com/ctuning/ck) 
with Js SON API and JSON meta information to be used 
in portable, customizable and reproducible [CK research workflows](https://github.com/ctuning/ck/wiki/Portable-workflows).

Please feel free to provide extra packages to [enable open and reproducible R&D](https://github.com/ctuning/ck/wiki/Enabling-open-science)!

Contributors
============

* [Grigori Fursin](https://fursin.net), cTuning foundation
* [Anton Lokhmotov](https://www.linkedin.com/in/lokhmotov/), dividiti
* [Leo Gordon](https://www.linkedin.com/in/leo-gordon-cambridge/), dividiti
* [Flavio Vella](https://www.linkedin.com/in/flaviovella/), Free University of Bozen-Bolzano
* [Marco Cianfriglia](https://www.linkedin.com/in/marco-cianfriglia-phd-68432687/), The National Research Council of Italy
* [Nikolay Chunosov](https://www.linkedin.com/in/nikolay-chunosov-94366b136/), Xored Software

License
=======
* BSD, 3-clause

Prerequisites
=============
* [Collective Knowledge Framework](http://github.com/ctuning/ck)

Installation
============
```
 $ ck pull repo:ck-math
```

Usage
=====

See available packages in this repository:
```
 $ ck list ck-math:package: | sort
```

Install any package on the host machine (Linux, MacOS or Windows) e.g.:
```
 $ ck install package:lib-openblas-0.3.3-universal
```

Install the above package for an Android target (if the Android SDK and NDK are installed):
```
 $ ck install package:lib-openblas-0.3.3-universal --target_os=android21-arm64
```

Example: how to build and use the Arm Compute Library
=====================================================

You can build library for Android/aarch64 (NEON) and run a simple SGEMM benchmark as follows:
```
$ ck install package:lib-armcl-cpu-master --target_os=android21-arm64 --env.USE_NEON=ON
$ ck compile program:acl-sgemm-neon-example --target_os=android21-arm64
$ ck run program:acl-sgemm-neon-example --target_os=android21-arm64
```

Publications
============

```
@article {29db2248aba45e59:a31e374796869125,
   author = {Fursin, Grigori and Kashnikov, Yuriy and Memon, Abdul Wahid and Chamski, Zbigniew and Temam, Olivier and Namolaru, Mircea and Yom-Tov, Elad and Mendelson, Bilha and Zaks, Ayal and Courtois, Eric and Bodin, Francois and Barnard, Phil and Ashton, Elton and Bonilla, Edwin and Thomson, John and Williams, Christopher and O'Boyle, Michael F. P.},
   affiliation = {INRIA Saclay, Parc Club Orsay Universite, 3 rue Jean Rostand, 91893 Orsay, France},
   title = {Milepost GCC: Machine Learning Enabled Self-tuning Compiler},
   journal = {International Journal of Parallel Programming},
   publisher = {Springer Netherlands},
   issn = {0885-7458},
   keyword = {Computer Science},
   pages = {296-327},
   volume = {39},
   issue = {3},
   note = {10.1007/s10766-010-0161-2},
   year = {2011},
   url = {https://scholar.google.com/citations?view_op=view_citation&hl=en&user=IwcnpkwAAAAJ&citation_for_view=IwcnpkwAAAAJ:LkGwnXOMwfcC},
   keywords = {machine learning compiler, self-tuning compiler, adaptive compiler, automatic performance tuning, machine learning, program characterization, program features, collective optimization, continuous optimization, multi-objective optimization, empirical performance tuning, optimization repository, iterative compilation, feedback-directed compilation, adaptive compilation, optimization prediction, portable optimization}
}

@inproceedings{Fur2009,
  author =    {Grigori Fursin},
  title =     {{Collective Tuning Initiative}: automating and accelerating development and optimization of computing systems},
  booktitle = {Proceedings of the GCC Developers' Summit},
  year =      {2009},
  month =     {June},
  location =  {Montreal, Canada},
  keys =      {http://www.gccsummit.org/2009}
  url  =      {https://scholar.google.com/citations?view_op=view_citation&hl=en&user=IwcnpkwAAAAJ&cstart=20&citation_for_view=IwcnpkwAAAAJ:8k81kl-MbHgC}
}
```

* http://arxiv.org/abs/1506.06256
* http://hal.inria.fr/hal-01054763
* https://hal.inria.fr/inria-00436029
* http://arxiv.org/abs/1407.4075
* https://scholar.google.com/citations?view_op=view_citation&hl=en&user=IwcnpkwAAAAJ&citation_for_view=IwcnpkwAAAAJ:LkGwnXOMwfcC

Feedback
========

If you have any problems, questions or suggestions, please do not hesitate to get in touch
via the following mailing lists:
* https://groups.google.com/forum/#!forum/collective-knowledge
* https://groups.google.com/forum/#!forum/ctuning-discussions
