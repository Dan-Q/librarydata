# LibraryData

An experimental enhancement to an existing Bodleian Libraries behind-the-scenes database. Full of
hacky old code for backwards-compatibility with external systems, but improving.

## Installing

You will need a copy of the old, live librarydata.db file. Put this into the db/ folder. You will
also need to configure a MySQL server in db/config.yml.

## Running

`rake run` to run the server using Thin. `rake console` for console access.
