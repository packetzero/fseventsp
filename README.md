# Utilities to extract information from MacOS .fseventsd files
This is a [Crystal-lang](https://crystal-lang.org) implementation of [G-C Partners FSEventsParser](https://github.com/dlcowen/FSEventsParser).
The FSEvents files contain a record of every create / rename / update / delete / metadata change of every file on the system.
Details on the FSEvents file format is here:
[http://nicoleibrahim.com/apple-fsevents-forensics/](http://nicoleibrahim.com/apple-fsevents-forensics/)

## Why?
While I had experience with the FSEvents C++ API, this project gave me a chance to learn the file format, and another chance to show the beauty of crystal.
Compiled for release mode, fseventsp is really fast.  For 272 files with about 18MB of FSEvents, produces a 546MB TSV file in about 6 seconds on a MacBook Pro i7.  Creating a SQLite3 database by importing the TSV data takes about 26 seconds, and another few seconds for the 'fullpath' index creation.

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
./bin/fseventsp  -s path/to/your/.fseventsd
```

## Build database
Currently a separate script generates a SQLite3 database from the TSV file.
```
$ scripts/create_db_from_tsv.sh ./out/events.tsv
creating database and importing TSV
creating fullname index...
```
