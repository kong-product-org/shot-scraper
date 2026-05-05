# shot-scraper

Forked from [simonw/shot-scraper](https://github.com/simonw/shot-scraper). Adds support for reusable macros, persistent Chrome authentication, and Konnect screenshot configs for [developer.konghq.com](https://github.com/Kong/developer.konghq.com).

## Usage

```bash
make install                                        # first time setup
make set-env                                        # print Chrome profile export — add to shell profile
make auth                                           # log in to Konnect
make screenshot konnect/platform/overview.yaml      # take screenshots for one file
make screenshots-all                                # take all screenshots
```

The default assumes the fork is cloned as a sibling of `developer.konghq.com`. Override `DOCS_DIR` if yours is elsewhere:

```bash
# Cloned inside developer.konghq.com:
make screenshot konnect/platform/overview.yaml DOCS_DIR=..
make screenshots-all DOCS_DIR=..

# Cloned at a custom path:
make screenshot konnect/platform/overview.yaml DOCS_DIR=/path/to/developer.konghq.com
make screenshots-all DOCS_DIR=/path/to/developer.konghq.com
```
