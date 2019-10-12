# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

##[0.6.2] - 2019-10-12

### Fixed

- A change in the Az Module broke most module output. Workarounds have been implemented.

##[0.6.2]

### Added

- Support for overriding parameters #26

### Fixed

- A warning is added to Test-ARMExistingResource as this module can't support Microsoft.Resources/deployments at this time (30)
- Get-ARMDeploymentErrorMessage had issues lately because the output from the Azure Log is not always consistent. It now searches for the right properties in a different way (#32)

## [0.5.7] - 2019-08-15

### Fixed

- The check for AzureRm/Az broke for the Azure DevOps pipeline. This is fixed
  This also fixes #23 as Az is now the preferred module

## [0.5.6] - 2019-07-20

### Added

- Pester testing has been implemented and added to the pipeline #8
- Support for TemplateParameterObject and no parameters at all #5

### Fixed

- The pipeline was broken. It was fixed and improved #18
- SecureString was handled as plain text. The output now shows securestring #19
- minor fixes, like the commenthelp for Test-ARMExistingResource being wrong

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