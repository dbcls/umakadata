# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )

# Rails.application.config.assets.precompile += %w( active_admin/* )
Rails.application.config.assets.precompile += %w( umakadata/* )
Rails.application.config.assets.precompile += %w( Chart.min.js )
Rails.application.config.assets.precompile += %w( bootstrap-datepicker.min.js )
Rails.application.config.assets.precompile += %w( jquery.treetable.css )
Rails.application.config.assets.precompile += %w( jquery.treetable.theme.default.css )

Rails.application.config.assets.precompile += %w( jquery.treetable.js )
Rails.application.config.assets.precompile += %w( jquery.validate.js )

Rails.application.config.assets.precompile += %w( cytoscape.min.js )
