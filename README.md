Pigs-Control is a POSIX Implementation of Git in Shell. 

# Commands

## pigs-init
The pigs-init command creates an empty Pigs repository.
### Usage
`./pigs-init`

## pigs-add
The `pigs-add` command adds the contents of one or more files to the index.
### Usage
`./pigs-add <filename>`

## pigs-commit 
The `pigs-commit -m` command saves a copy of all files in the index to the repository.
The `pigs-commit -a -m` command causes all files already in the index to have their contents from the current directory added to the index before the commit.
### Usage
`./pigs-commit -m '<commit description>'`
`./pigs-commit -a -m '<commit description>'`

## pigs-log 
The `pigs-log` command prints a line for every commit made to the repository.
### Usage
`./pigs-log`

## pigs-show
The `pigs-show` should print the contents of the specified filename as of the specified commit.
If commit is omitted, the contents of the file in the index should be printed.
### Usage
`./pigs-show <commit number>:<filename>`
`./pigs-show :<filename>`

## pigs-rm
`pigs-rm` removes a file from the index, or, from the current directory and the index.
If the `--cached` option is specified, the file is removed only from the index, and not from the current directory.
The `--force` option will carry out the removal even if the user will lose work.
### Usage
`./pigs-rm [--force] [--cached] <filenames>`

## pigs-status
`pigs-status` shows the status of files in the current directory, the index, and the repository.
### Usage
`./pigs-status`

## pigs-branch
`pigs-branch` either creates a branch, deletes a branch, or lists current branch names.
If branch-name is omitted, the names of all branches are listed.
If branch-name is specified, then a branch with that name is created or deleted,
depending on whether the -d option is specified.
### Usage
`./pigs-branch [-d] [branch name]`

