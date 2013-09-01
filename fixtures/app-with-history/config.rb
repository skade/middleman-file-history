require 'middleman-file-history'
require 'logger'
activate :file_history do |history|
  history.github = true
  history.git = Git.open(Dir.pwd, :repository => 'dot_git', :logger => Logger.new($stdout))
end