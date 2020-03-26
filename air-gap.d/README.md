# Air-gapped/Mirrored/Private Registry Setup for vagrant-caasp -- BETA
A guide for adding registry (mirrors) to allow "no internet" deployment of CaaSP
and supporting images with vagrant-caasp.

This (as with vagrant-caasp) is a work in progress and will be refined up after
some testing and feedback.

Feel free to open issues and/or submit PRs.

# What you get
* Ability to install CaaSP using an alternate registry (NOT registry.suse.com)
* Supports secure registries

# ASSUMPTIONS
* You're already using vagrant-caasp
* You have a registry mirror with at least the required CaaSP deployment images.
  (skuba cluster images)
* You enjoy troubleshooting :P

This directory is referenced by the vagrant-caasp/deploy_caasp.sh script via the
-a (or --air-gap) command line options.

# See ./examples Directory for more information


