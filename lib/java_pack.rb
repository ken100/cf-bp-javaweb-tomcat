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
export JAVA_HOME="#{global.jdk_dir}/.jdk"
export PATH="#{global.jdk_dir}/.jdk/bin:$PATH"

echo JAVA_HOME 
echo PATH

MEMORY_DIGIT=`echo $MEMORY_LIMIT |sed 's/[m|M]//g'`
xmx=`expr $MEMORY_DIGIT / 2`
max_mem=800
if [ $xmx -gt $max_mem ];then
  xmx=$max_mem
fi
# -Xmx${xmx}M
# export JAVA_OPTS=${JAVA_OPTS:-"-Xms1024m -Xmx1024m -Xmn512m -XX:PermSize=32m -XX:MaxPermSize=64m -XX:SurvivorRatio=4 -verbose:gc -Xloggc:/home/vcap/logs/gc.log -XX:+PrintGCTimeStamps -XX:+PrintGCDetails -Djava.awt.headless=true #{java_opts.map{ |k, v| "#{k}#{v}" }.join(' ')}"}
export JAVA_OPTS=${JAVA_OPTS:-"-Xmx${xmx}M #{java_opts.map{ |k, v| "#{k}#{v}" }.join(' ')}"}
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


