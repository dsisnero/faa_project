# FAA Project Directory Generator

A Crystal tool for generating standardized FAA project directory structures with recommended file templates.

## Installation

1. Add the dependency to your `shard.yml`:

```yaml
dependencies:
  faa_project:
    github: dsisnero/faa_project
```

2. Run `shards install`

## Usage

```crystal
require "faa_project"

# Create a new project directory
project = Faa::ProjectDir.new(Path["./my_faa_project"])
project.make_subdirectories
```

This will create a standardized FAA project structure with the following directories:

- 01 - Planning
- 02 - Engineering
- 04 - ORM
- 05 - Construction
- 06 - Installation
- 07 - Closeout

Each directory includes recommended file templates and PDF guides.

## Development

1. Clone the repository
2. Run `shards install`
3. Run specs with `crystal spec`

## Contributing

1. Fork it (<https://github.com/dsisnero/faa_project/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Dominic Sisneros](https://github.com/dsisnero) - creator and maintainer
