#! /usr/bin/ruby
# coding: utf-8
# author: Ulric Qin
# mail: qinxiaohui@xiaomi.com

require 'fetcher'
require 'fileutils'

class JavaPack

  attr_reader :global

  def initialize(global)
    @global = global
  end

  def compile
    # Fetcher.install_jdk(global)
    setup_profiled
  end

  def setup_profiled
    FileUtils.mkdir_p "#{global.build_path}/.profile.d"
    File.open("#{global.build_path}/.profile.d/jdk.sh", 'a') { |file| file.puts(bash_script) }
  end

  private

  #'-Xms' => '$MEMORY_LIMIT',
  def java_opts
    {
        '-Djava.security.egd=' => 'file:/dev/./urandom',
        '-Djava.io.tmpdir=' => '\"$TMPDIR\"',
        '-Xss' => '256k'
    }
  end

  def bash_script
    <<-BASH
#!/usr/bin/env bash
export JAVA_HOME="$HOME/.jdk"
export PATH="$HOME/.jdk/bin:$PATH"
export JAVA_OPTS=${JAVA_OPTS:-"#{java_opts.map{ |k, v| "#{k}#{v}" }.join(' ')}"}
export LANG="${LANG:-en_US.UTF-8}"

if [ -n "$VCAP_DEBUG_MODE" ]; then
  if [ "$VCAP_DEBUG_MODE" = "run" ]; then
    export JAVA_OPTS="$JAVA_OPTS -Xdebug -Xrunjdwp:transport=dt_socket,address=$VCAP_DEBUG_PORT,server=y,suspend=n"
  elif [ "$VCAP_DEBUG_MODE" = "suspend" ]; then
    export JAVA_OPTS="$JAVA_OPTS -Xdebug -Xrunjdwp:transport=dt_socket,address=$VCAP_DEBUG_PORT,server=y,suspend=y"
  fi
fi
    BASH
  end

end


