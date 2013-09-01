# middleman-file-history

A middleman plugin that uses ruby-git to find out about the history of the page being compiled, especially authorship.

Comes with github integration for finding the github identities of authors and content properties on GH, if possible.

## Installation

Currently, git only. Add the following to your Gemfile:

```ruby
gem "git", :git => "https://github.com/skade/ruby-git.git", :branch => "feature/log-follow"
gem "middleman-file-history", :git => "https://github.com/skade/middleman-file-history.git"
```

## Configuration

Activate the extension as usual:

```ruby
activate :file_history
```

The following options can be configured:

`follow`: Whether the file log should follow merges. Equivalent to `--follow` for `git log`. Default: `true`

`github`: Activate github API integration. This might increase your build time, but gives you additional info per page. Default: `false`

`git`: Use a custom git object, for example for logging:

```
activate :file_history do |h|
  h.git = Git.open(Dir.pwd, :logger = Logger.new($stdout))
end
```

## API

The API is changing currently, have a look at `fixtures/app-with/history/source/index.html.erb` for examples.