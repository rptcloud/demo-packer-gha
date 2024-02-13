[![Packer Validate](https://github.com/rptcloud/demo-packer-gha/actions/workflows/packer-validate.yml/badge.svg)](https://github.com/rptcloud/demo-packer-gha/actions/workflows/packer-validate.yml)

# Intro
Hello and welcome to this repository. 


# Features  
## GitHub Workflows  
### Packer Validate  

This runs a packer validate in the ./packer/builds directory. Status checks on Pull Requests can be enabled and prevent merges if this fails. 

```yaml
on:
  pull_request:
    branches:
      - main
  schedule:
    - cron: "*/30 * * * *"
  push:
    branches:
      - main
```

- Runs on a schedule, yeah 30 minutes is a bit overkill. 
- Runs when a push to the main branch occurs
- Runs on a pull requests


## OS Workflows  

Most of these workflows will run if a change is made based on pathing. For example, this would be for any files under the packer directory containing the name windows. 

```yaml
paths:
      - "packer/**/*windows*"
```

## SQL Workflows

These are a bit special and will essentially be an added layer to the windows 2016 servers. 

When the Windows 2016 workflow is complete, these will pick up the latest created image and build upon them. 

```yaml
on:
    workflow_run:
      workflows: ["windows-2016-base"]
      types:
        - completed 
``` 