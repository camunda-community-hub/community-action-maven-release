![Lifecycle](https://img.shields.io/badge/Lifecycle-Proof%20of%20Concept-blueviolet) 

*Learn more about the 'Proof of Concept' lifecycle status label [here](https://github.com/Camunda-Community-Hub/community/blob/main/extension-lifecycle.md#proof-of-concept-)*

# GitHub Action Supporting The Camunda Community Extensions Release Process

## Introduction

*Note: Before continuing, we suggest [reading the release process documentation](https://github.com/camunda-community-hub/community/blob/main/RELEASE.MD).*

GitHub Actions currently (03/2021) have poor options for code sharing. This means that workflows have to be duplicated across repositories. This has the advantage of highly customizable workflows, on the other hand it makes maintaining workflows painful.

Composite Run Steps have been added to alleviate this shortcoming, as they allow for wrapping multiple shell-only steps into one “pseudo action”. This can either be hosted in the same or a shared repository.

However, those Composite Run Steps [don’t yet allow for using arbitrary actions](https://github.com/actions/runner/issues/646).

This means that things like actions/checkout or actions/setup-java still need to be done individually. However, it is usually those steps that require the most customization anyway.

In order to effectively maintain a large number of repositories, an implementation around centrally maintained Composite Run Steps is favorable, and this repository aims to provide it. 

> ![A BPMN diagram of the release workflow](https://github.com/camunda-community-hub/community/blob/main/assets/release-new-version.png)


### Usage

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
      - name: Cache
        uses: actions/cache@v2
        with:
          path: ~/.m2/repository
          key: ${{ runner.os }}-maven-${{ hashFiles('**/pom.xml') }}
          restore-keys: |
            ${{ runner.os }}-maven-
      - name: Set up Java environment
        uses: actions/setup-java@v1
        with:
          java-version: 11
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
          maven-gpg-passphrase: ${{ secrets.MAVEN_CENTRAL_GPG_SIGNING_KEY_PASSPHRASE }}
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
### Prerequisites
At the time of writing, projects need to use the `camunda-release-parent` in their POM:
```xml
  <parent>
    <groupId>org.camunda</groupId>
    <artifactId>camunda-release-parent</artifactId>
    <version>3.7</version>
    <relativePath />
  </parent>
```

Furthermore, the following profile needs to be added:
```xml
  <profiles>
    <profile>
      <id>community-action-maven-release</id>
      <build>
        <plugins>
          <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-gpg-plugin</artifactId>
            <version>1.6</version>
            <executions>
                <execution>
                    <id>sign-artifacts</id>
                    <phase>verify</phase>
                    <goals>
                        <goal>sign</goal>
                    </goals>
                </execution>
            </executions>
            <configuration>
                <!-- Prevent gpg from using pinentry programs -->
                <gpgArguments>
                    <arg>--pinentry-mode</arg>
                    <arg>loopback</arg>
                </gpgArguments>
            </configuration>
          </plugin>
        </plugins>
      </build>
    </profile>
  </profiles>
  ```
### Troubleshooting

1. If you are facing any issues regarding your extension's release process, please [open an issue](https://github.com/camunda-community-hub/community-action-maven-release/issues) and assign it to [@celanthe](https://github.com/celanthe) with applicable issue labels applied.
2. If you see an update or improvement that can be made to the release process in the Camunda Community Hub, we encourage you to submit an issue with your request, and thank you for your suggestion!
3. Please make use of the [Camunda Community Hub Pull Request Template](https://github.com/camunda-community-hub/community/issues/new?assignees=&labels=&template=camunda-community-hub-pull-request-template.md&title=Pull+Request) when opening a troubleshooting pull request and include as much information as possible in order to help reviewers better understand the issue you are facing.



