# MMT
Meta-data Management Tool (PERL)
Based on the original BNL MMT application and updated/modified for support by ORNL.
- Added usage of jQuery's DataTables for managing large lists, like sites, facilities, DODs, data streams, etc.
- Added animated "loading" image/CSS and JS logic to gray out page while loading data and setting up DataTable.
- Added some client side logging for confirming processing.
- Updated Perl library file (PM) to reuse prepared statements with named parameters for improved performance.