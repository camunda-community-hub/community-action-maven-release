# Release a new version of this Action

- checkout `master`
- run `.github/workflows/release.sh`:
  - it will ask you to enter the new version

## Shortcomings

- This only supports referencing the action with a fully qualified semantic version, like `camunda/community-action-maven-release@v1.0.1`
- To use minor/major references, tags like `v1` and `v1.0` need to be created and/or forcefully overwritten by hand. Ideally, this would be implemented in `release.sh` as well.
