# Utilities to extract information from MacOS .fseventsd files
This is a [Crystal-lang](https://crystal-lang.org) implementation of [G-C Partners FSEventsParser](https://github.com/dlcowen/FSEventsParser).
The FSEvents files contain a record of every create / rename / update / delete / metadata change of every file on the system.
Details on the FSEvents file format is here:
[http://nicoleibrahim.com/apple-fsevents-forensics/](http://nicoleibrahim.com/apple-fsevents-forensics/)

## Why?
While I had experience with the FSEvents C++ API, this project allowed me to learn the file format, and another chance to show the beauty of crystal.
Compiled for release mode, fseventsp is really fast.  For 271 files with about 18MB of gzipped FSEvents, produces a 546MB TSV file in about 6 seconds on a MacBook Pro i7.  Creating the SQLite3 database by importing the TSV data, indexing, and generating reports takes another 30 seconds or so.

## Prerequisite : crystal-lang
Since this is a source-code distribution, you will need to compile the executable.  You will need crystal, and the easiest way to get it is via [homebrew](https://brew.sh).

```
brew install crystal
```

## Build
It's easiest to just run 'make', which will do 'crystal build'
```
make
```

## Run - Extracts data to TSV file
You don't want to run the utility on the /.fseventsd directory.  Make a copy of the directory and chown permissions to regular user.
```
./bin/fseventsp  -s path/to/your/.fseventsd -o desired/output/path -q report_queries.json

Total FSEvents Files: 271
Parsing...
10%
20%
30%
40%
50%
60%
70%
80%
90%
100%
creating database and importing TSV
creating fullname index...
creating report 'UserProfileActivity'
creating report 'TrashActivity'
creating report 'BrowserActivity'
creating report 'DownloadsActivity'
creating report 'MountActivity'
creating report 'EmailAttachments'
creating report 'UsersPictureTypeFiles'
creating report 'UsersDocumentTypeFiles'
creating report 'DropBoxActivity'
creating report 'Box_comActivity'
creating report 'FolderAccess'
```
