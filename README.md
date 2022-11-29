[![Lifecycle: Incubating](https://img.shields.io/badge/Lifecycle-Incubating-blue)](https://github.com/Camunda-Community-Hub/community/blob/main/extension-lifecycle.md#incubating-)

# GitHub Action Supporting The Camunda Community Extensions Release Process

The community-action-maven-release makes sure a community extension in Java can be released to Maven Central.
Please [check out the release process documentation](https://github.com/camunda-community-hub/community/blob/main/RELEASE.MD) first.

# How-to use

## Add release parent to POM

Any project needs to use the [community-hub-release-parent](https://github.com/camunda-community-hub/community-hub-release-parent) in their POM:

```xml
<parent>
    <groupId>org.camunda.community</groupId>
    <artifactId>community-hub-release-parent</artifactId>
    <version>1.3.1</version>
</parent>
```

This parent POM contains all necessary settings for the GitHub action to function properly.

## Add Github workflow

Add a Github workflow (e.g. by adding a file `.github/workflows/deploy.yaml` to your) to your project.

Important configuration options (see https://github.com/camunda-community-hub/community-action-maven-release/blob/main/action.yml#L3 for all options):

* **Sonatype Server:** If you want to deploy artifacts with the group id `io.camunda` you need to adjust the maven url below, as Sonatype uses different servers for newer groups: `maven-url: s01.oss.sonatype.org`
* **Branch:** If you want to support multiple versions and have different branches for managing those, you can configure them in the action.

```yaml
name: Deploy artifacts with Maven
on:
  push:
    branches: [master]
  release:
    types: [published]
jobs:
  publish:
    runs-on: ubuntu-20.04
    steps:
      - name: Checks out code
        uses: actions/checkout@v3
      - name: Set up Java environment
        uses: actions/setup-java@v3
        with:
          java-version: 11
          distribution: zulu
          cache: maven
          gpg-private-key: ${{ secrets.MAVEN_CENTRAL_GPG_SIGNING_KEY_SEC }}
          gpg-passphrase: MAVEN_CENTRAL_GPG_PASSPHRASE
      - name: Deploy SNAPSHOT / Release
        uses: camunda-community-hub/community-action-maven-release@v1
        with:
          release-version: ${{ github.event.release.tag_name }}
          release-profile: community-action-maven-release
          nexus-usr: ${{ secrets.NEXUS_USR }}
          nexus-psw: ${{ secrets.NEXUS_PSW }}
          maven-usr: ${{ secrets.MAVEN_CENTRAL_DEPLOYMENT_USR }}
          maven-psw: ${{ secrets.MAVEN_CENTRAL_DEPLOYMENT_PSW }}
          maven-url: oss.sonatype.org
          maven-gpg-passphrase: ${{ secrets.MAVEN_CENTRAL_GPG_SIGNING_KEY_PASSPHRASE }}
          maven-auto-release-after-close: true
          github-token: ${{ secrets.GITHUB_TOKEN }}
        id: release
      - if: github.event.release
        name: Attach artifacts to GitHub Release (Release only)
        uses: actions/upload-release-asset@v1
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          upload_url: ${{ github.event.release.upload_url }}
          asset_path: ${{ steps.release.outputs.artifacts_archive_path }}
          asset_name: ${{ steps.release.outputs.artifacts_archive_path }}
          asset_content_type: application/zip
```




# More info

## Security scanning

Introdued in the [v1.0.6 release](https://github.com/camunda-community-hub/community-action-maven-release/releases/tag/v1.0.6) introduces optional [Trivy Security Scanning](https://github.com/aquasecurity/trivy), which can be run during the release process contained in this action via a Bash script. When enabled, Trivy scans for security vulnerabilities in container images, file systems, and Git repositories, as well as for configuration issues. To enable the scanner, set the `vulnerability-scan` input default to `true`.

If there are no vulnerabilities found, or `UNKNOWN,` `LOW,` or `MEDIUM` vulnerabilities, the action will complete with `exit 0`. If there is a `HIGH` or `CRITICAL` vulnerability found, the release deployment will fail with `exit 1`. The results of the scan will then be displayed in a `sarif.tpl` named `trivy-results.sarif`.

The [v1.0.7 release](https://github.com/camunda-community-hub/community-action-maven-release/releases/tag/v1.0.7) introduces uploading the results of a Trivy vulnerability scan that has completed with `exit 1` contained in a Sarif file to the [GitHub Security](https://docs.github.com/en/get-started/learning-about-github/about-github-advanced-security) tab.

> ![A BPMN diagram of the release workflow](<https://github.com/camunda-community-hub/community/blob/main/assets/release-new-version%20(1).png>)


## Why this design?


GitHub Actions currently has poor options for code sharing. This means that workflows have to be duplicated across repositories. This has the advantage of highly customizable workflows, on the other hand it makes maintaining workflows painful.

Composite Run Steps have been added to alleviate this shortcoming, as they allow for wrapping multiple shell-only steps into one “pseudo action”. This can either be hosted in the same or a shared repository.

However, those Composite Run Steps [don’t yet allow for using arbitrary actions](https://github.com/actions/runner/issues/646).

This means that things like actions/checkout or actions/setup-java still need to be done individually. However, it is usually those steps that require the most customization anyway.

In order to effectively maintain a large number of repositories, an implementation around centrally maintained Composite Run Steps is favorable, and this repository aims to provide it.

## Releasing a new version of this action

In order to release a new version:

* Create a new release and create a tag on-the-fly (e.g. `v1.0.13`)
* Delete the existing `latest` and `v1` tags and re-create them, pointing to the the new tag (e.g. `v1.0.13`). This way, the new version will also be used in already existing actions of community extensions.


# Troubleshooting

1. If you are facing any issues regarding your extension's release process, please [open an issue](https://github.com/camunda-community-hub/community-action-maven-release/issues) and assign it to [@camunda-community-hub/devrel](https://github.com/orgs/camunda-community-hub/teams/devrel) with applicable issue labels applied.
2. If you see an update or improvement that can be made to the release process in the Camunda Community Hub, we encourage you to submit an issue with your request, and thank you for your suggestion!
3. Please make use of the [Camunda Community Hub Pull Request Template](https://github.com/camunda-community-hub/community/issues/new?assignees=&labels=&template=camunda-community-hub-pull-request-template.md&title=Pull+Request) when opening a troubleshooting pull request and include as much information as possible in order to help reviewers better understand the issue you are facing.
