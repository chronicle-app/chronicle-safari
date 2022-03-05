# Chronicle::Safari

Safri plugin for [chronicle-etl](https://github.com/chronicle-app/chronicle-etl)

## Available Connectors
### Extractors
- `safari` - Extractor for history

### Transformers
- `safari` - Transforms history into Chronicle Schema

## Usage

```sh
gem install chronicle-etl
chronicle-etl connectors:install safari

chronicle-etl --extractor safari --since 2022-02-07
```
