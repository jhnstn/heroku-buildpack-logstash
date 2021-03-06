require "language_pack"
require "language_pack/ruby"

# Rack Language Pack. This is for any non-Rails Rack apps like Sinatra.
class LanguagePack::Logstash < LanguagePack::Ruby

  # detects if this is a valid Rack app by seeing if "config.ru" exists
  # @return [Boolean] true if it's a Rack app
  def self.use?
    File.exist?("logstash.conf")
  end

  def ruby_version
    "ruby-1.9.3"
  end

  def name
    "Ruby/Logstash"
  end

  def default_process_types
    {
      "worker"  => "bundle exec bin/logstash agent -c logstash.conf --pluginpath lib",
      "console" => "bundle exec irb"
    }
  end

  def compile
    log("Changing to dir #{build_path}")
    Dir.chdir(build_path)
    remove_vendor_bundle
    install_ruby
    install_jvm
    setup_language_pack_environment
    fetch_logstash
    allow_git do
      install_language_pack_gems
      build_bundler
      create_database_yml
      install_binaries
      run_assets_precompile_rake_task
    end
  end

  # Add a redis2go instance
  def default_addons
    add_shared_database_addon + [ "redistogo:nano" ]
  end

  protected
  
  def fetch_logstash
    log("fetch logstash") do
      pipe("curl https://github.com/logstash/logstash/tarball/master -L -o - | tar xzf -")
      fetch_dir = Dir['logstash-logstash-*'][0]
      run("mv #{fetch_dir}/* .")
      run("rmdir #{fetch_dir}")
    end
  end
  
end

