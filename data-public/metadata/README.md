`data-public/metadata/` Directory
=========

This directory should contain only data files that describe structure of the project or other datasets.  

The documents of type "manifest" list the data assets  as they enter the ETL pattern (the "INPUT-manifest.md") and as they exit the ETL pattern (the "CACHE-manifest.md").  These files should be updated whenever the data files change.

No protected information
---------

Files with PHI should **not** be stored in a GitHub repository, even a private GitHub repository.  We recommend using an enterprise database (such as MySQL or SQL Server) to store the data, and read & write the information to/from the software right before and after it's used.  If a database isn't feasible, consider storing the files in [`data-private/`](../../data-private/), whose contents are not committed to the repository; a line in [`.gitignore`](../../.gitignore) keeps the files uncommitted/unstaged.  However, there could be some information that is sensitive enough that it shouldn't even be stored locally without encryption (such as PHI).
