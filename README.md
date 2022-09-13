# Chronicle::Safari
[![Gem Version](https://badge.fury.io/rb/chronicle-safari.svg)](https://badge.fury.io/rb/chronicle-safari)

Extract your Safari browser history with this plugin for [chronicle-etl](https://github.com/chronicle-app/chronicle-etl)

## Available Connectors
### Extractors
- `safari` - Extractor for browser history

### Transformers
- `safari` - Transforms history into Chronicle Schema

## Usage

```sh
# Install chronicle-etl and then this plugin
$ gem install chronicle-etl
$ chronicle-etl connectors:install safari

# Extract all history
$ chronicle-etl --extractor safari

# Get last week of history and transform it into Chronicle Schema
$ chronicle-etl --extractor safari --since 1w --transformer safari
```
