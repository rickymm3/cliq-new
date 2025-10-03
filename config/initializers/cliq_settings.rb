# Loads config/cliq_settings.yml and exposes it at Rails.configuration.x.cliq (hash with indifferent access)

require "yaml"

settings_path = Rails.root.join("config", "cliq_settings.yml")
raw = YAML.safe_load(File.read(settings_path), aliases: true) || {}

env = Rails.env
defaults = (raw["default"] || {})
env_overrides = (raw[env] || {})

merged = defaults.deep_merge(env_overrides)

Rails.configuration.x.cliq = merged.with_indifferent_access
