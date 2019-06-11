# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.4] - 2019-06-11

### Added

- PesterTest for Get-ArmdeploymentErrorMessage #8

### Fixed

- Bugfix for Get-ARMDeploymentErrorMessage ending in a timeout #14


## [0.3.3] - 2019-05-08

### added

- Support for the AZ module as well as the AzureRM module. #4

### Fixed

- Bugfix to get rid of empty values in Test-ArmDeploymentResource
- Bugfix for empty errormessages in Get-ARMDeploymentResource
- Bugfix Test-ARMDeploymentResource: Network security group output is wrong #3

## [0.2.1] - 2019-04-18

### added

- Pipelinesupport for Test-ARMExistingResource
- Changed Get-ArmdeploymentErrormessage switch for pipeline to general throw

### Fixed

- Test-ARMExistingResource showed overwrite-output when mode was nog complete

## [0.1.1] - 2019-04-11

### Fixed

- #9 Test-ARMExistingResource should output all resource group changes with complete switch

## [0.1.0] - 2019-04-11

### Added

- Test-ARMDEploymentResource now shows "tags"  in front of a tag for readability

## [0.0.1] - 2019-03-30

### Added

- initial commit

---

<small>
Cheatcheet:

**Added** for new features.
**Changed** for changes in existing functionality.
**Deprecated** for soon-to-be removed features.
**Removed** for now removed features.
**Fixed** for any bug fixes.
**Security** in case of vulnerabilities.
</small>