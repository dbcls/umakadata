#!/bin/bash
bundle exec rake db:setup
bundle exec rake umakadata:active_median
bundle exec rake umakadata:import_prefix_for_all_endpoints[./data/prefixes]
bundle exec rake umakadata:import_prefix_filters_for_all_endpoints[./data/prefix_filters]
bundle exec rake umakadata:seeAlso_sameAs_for_all_endpoints[./data/relations]
