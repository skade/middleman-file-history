# Require core library
require "middleman-core"

# Extension namespace
class FileHistory < ::Middleman::Extension
  option :follow, true, "Follow merges"
  option :github, false, "Annotate users and resources with github data for further consumption"
  option :git, nil, "Override the git repository to be used with a ruby-git object"

  #option :my_option, "default", "An example option"

  def initialize(app, options_hash={}, &block)
    # Call super to build options from the options_hash
    super

    require 'git'
    require 'faraday' if options.github
    require 'addressable/uri' if options.github
    require 'json' if options.github
    require 'ostruct' if options.github
  end

  def git
    @git ||= options.git || Git.open(Dir.pwd)
  end

  def after_configuration
    # Do something
  end

  # A Sitemap Manipulator
  def manipulate_resource_list(resources)
    resources.each do |resource|
      resource.extend GitResource
      resource.extend LoggedResource
      resource.git = git
      log = git.log.path(resource.source_file).follow(options.follow)
      resource.log = log
      if options.github
        resource.extend GithubResource
        log.each do |l|
          l.author.extend(GithubProfile)
        end
      end
    end
  end

  module Network
    def self.cache
      @cache ||= {}
    end

    def self.get(path, params, &parser)
      cache[[path, params]] ||= begin
        parser.call(Faraday.get(path, params, {"Accept" => "application/vnd.github.preview"}))
      end
    end

    def self.profile(author)
      get("https://api.github.com/search/users", {q: "#{author.email} in:email"}) do |result|
        user = JSON.parse(result.body)["items"].first
        OpenStruct.new(user) if user
      end
    end

    def self.page_info(page)
      get("https://api.github.com/repos/#{page.github_repos}/contents/#{page.relative_path}", {ref: page.branch}) do |result|
        OpenStruct.new(JSON.parse(result.body)).tap { |o| o.extend GithubPageInfo }
      end
    end
  end

  module GitResource
    attr_accessor :git
  end

  module GithubProfile
    def profile
      Network.profile(self)
    end
  end

  module GithubPageInfo
    def edit_url
      html_url.sub("blob", "edit")
    end
  end

  module GithubResource
    def page_info
      Network.page_info(self)
    end

    def github_repos
      git.remote.url.match(%r{.*?([\w\-./]+)\.git})[1]
    end

    def branch
      git.branch.name
    end

    def relative_path
      Pathname.new(source_file).relative_path_from(Pathname.new(git.dir.path)).to_s
    end
  end

  module LoggedResource
    # Returns all commits on that resource.
    #
    # @return Array<Git::Commit>
    attr_accessor :log

    # Returns the first author to ever commit to that file,
    # including merges, if `follow` is configured as `true`.
    #
    # @return Array<Git::Author>
    def original_author
      log.last.author
    end

    # Returns all authors to ever commit on this file.
    #
    # @return Array<Git::Author>
    def authors
      log.map(&:author).uniq { |a| [a.name, a.email] }
    end

    # Returns all authors excluding the original author.
    #
    # @return Array<Git::Author>
    def contributors
      o = original_author
      authors.reject { |a| a.name == o.name && a.email == o.email }
    end

    # Returns all commits that are not merges.
    #
    # @return Array<Git::Commit>
    def changes
      log.reject { |l| l.parents.size > 1 }
    end
  end

  # module do
  #   def a_helper
  #   end
  # end
end

# Register extensions which can be activated
# Make sure we have the version of Middleman we expect
# Name param may be omited, it will default to underscored
# version of class name

FileHistory.register(:file_history)