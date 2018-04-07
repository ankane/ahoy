# Contributing

First, thanks for wanting to contribute. You’re awesome! :heart:

## Questions

Use [Stack Overflow](https://stackoverflow.com/) with the tag `ahoy`.

## Feature Requests

Create an issue. Start the title with `[Idea]`.

## Issues

Think you’ve discovered an issue?

1. Search existing issues to see if it’s been reported.
2. Try the `master` branch to make sure it hasn’t been fixed.

```rb
gem "ahoy_matey", github: "ankane/ahoy"
```

If the above steps don’t help, create an issue. Include:

- Detailed steps to reproduce
- Complete backtraces for exceptions

## Setup
This project is containerized with docker to avoid conflicts with other projects or the necessity of excessive configurations in your machine. This steps are optional but will speedup your setup.

1. Install [Docker](https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-docker-ce)
2. Install [Docker Compose](https://docs.docker.com/compose/install/#install-compose)
3. Install the necessary gems running `docker-compose run ahoy bundle`

## Running Tests
We use Rspec to run tests, actually we only test the suite in a MySQL environment.

- Just run `docker-compose run ahoy rspec`

or

- Start a bash inside a container with `docker-compose run ahoy bash` and run `rspec` when necessary

or if you isn't using docker

- `rspec` You'll need a local MySQL server

## Pull Requests

Fork the project and create a pull request. A few tips:

- Keep changes to a minimum. If you have multiple features or fixes, submit multiple pull requests.
- Follow the existing style. The code should read like it’s written by a single person.

Feel free to open an issue to get feedback on your idea before spending too much time on it.

---

This contributing guide is released under [CCO](https://creativecommons.org/publicdomain/zero/1.0/) (public domain). Use it for your own project without attribution.
