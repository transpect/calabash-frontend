# calabash-distro

This repo contains the default XML Calabash distribution as downloadable from http://xmlcalabash.com/download/. Don’t wonder why there’s a README in addition to this README.md. The README.md is the only file that does not originate from the distro. README is XML Calabash’s original README.

Its purpose is to provide a place for svn or git based projects to attach their XPRoc runtime via external or submodule.

It contains the modularized version of Calabash, currently 1.1.0 for Saxon 9.6.

This Calabash distro, together with a few other modules that almost every transpect projects needs, will be pulled as a submodule of [calabash-transpect](https://github.com/transpect/calabash-transpect) or as an external. Please see calabash-transpect’s README for instructions on how to include the Calabash externals/submodule into your project.
