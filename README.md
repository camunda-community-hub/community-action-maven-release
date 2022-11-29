![Lifecycle](https://img.shields.io/badge/Lifecycle-Proof%20of%20Concept-blueviolet)

# GitHub Action Supporting The Camunda Community Extensions Release Process

## Introduction

GitHub Actions currently (03/2021) have poor options for code sharing. This means that workflows have to be duplicated across repositories. This has the advantage of highly customizable workflows, on the other hand it makes maintaining workflows painful.

Composite Run Steps have been added to alleviate this shortcoming, as they allow for wrapping multiple shell-only steps into one “pseudo action”. This can either be hosted in the same or a shared repository.
However, those Composite Run Steps [don’t yet allow for using arbitrary actions](https://github.com/actions/runner/issues/646).

This means that things like actions/checkout or actions/setup-java still need to be done individually. However, it is usually those steps that require the most customization anyway.

In order to effectively maintain a large number of repositories, an implementation around centrally maintained Composite Run Steps is favorable, and this repository aims to provide it.

## Usage

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
      - uses: actions/checkout@v3
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
          release-profile: release
          nexus-usr: ${{ secrets.NEXUS_USR }}
          nexus-psw: ${{ secrets.NEXUS_PSW }}
          maven-usr: ${{ secrets.MAVEN_CENTRAL_DEPLOYMENT_USR }}
          maven-psw: ${{ secrets.MAVEN_CENTRAL_DEPLOYMENT_PSW }}
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
