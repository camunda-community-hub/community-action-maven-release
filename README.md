![Lifecycle](https://img.shields.io/badge/Lifecycle-Proof%20of%20Concept-blueviolet)

# GitHub Action Supporting The Camunda Community Extensions Release Process

## Introduction

GitHub Actions currently (03/2021) have poor options for code sharing. This means that workflows have to be duplicated across repositories. This has the advantage of highly customizable workflows, on the other hand it makes maintaining workflows painful.

Composite Run Steps have been added to alleviate this shortcoming, as they allow for wrapping multiple shell-only steps into one “pseudo action”. This can either be hosted in the same or a shared repository.
However, those Composite Run Steps [don’t yet allow for using arbitrary actions](https://github.com/actions/runner/issues/646).

This means that things like actions/checkout or actions/setup-java still need to be done individually. However, it is usually those steps that require the most customization anyway.

In order to effectively maintain a large number of repositories, an implementation around centrally maintained Composite Run Steps is favorable, and this repository aims to provide it.

## Usage

---

## `This is a Work in Progress`

---

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
      - uses: actions/checkout@v2
      # ... - Other steps, like pulling secret, setting up Java, GPG etc.
      - name: Perform release / deploy SNAPSHOT
        uses: camunda-community-hub/community-action-maven-release@v1.0.1
        with:
          releaseVersion: ${{ github.event.release.tag_name }}
        id: release
```
