#!/usr/bin/env ruby

require 'pry'
require 'logger'
require 'open3'

class RunCmd
  attr_accessor :status

  def initialize(logger, opts = nil)
    @log = logger
    # :stdout, :stderr, :both, :none
    @opts = opts || { output: :none,
      test_run: false, blocks: true }
    @continue = true
  end

  def run(cmd)

    if(@opts[:test_run])
      @log.info("TEST RUN: #{cmd}")
      return nil
    end

    if(@continue)
      @log.info("RUNNING: #{cmd}")
    else
      @log.error("FAILED: #{cmd}")
      return nil
    end

    if(@opts[:blocks])
      Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
        case @opts[:output]
        when :none
        when :stdout
          puts(stdout.read)
        when :stderr
          puts(stderr.read)
        when :both
          puts(stdout.read)
          puts(stderr.read)
        else
          @log.warn('Invalid output option')
        end
        @status = wait_thr.value
      end
    end

    @continue = false if (!@status.success?)
    @status.success?
  end

  def success?
    @continue
  end
end

# Comparison of process executers
# exec() = replaces running process
# system() = runs in subshell, returns true/false/nil, eats exceptions, blocks
# backticks = runs in subshell, returns stdout, blocks
# popen3() = block or non-block
# 
# Implement non-blocking version
#  stdin, stdout, stderr, wait_thr = Open3.popen3(cmd)

if __FILE__ == $PROGRAM_NAME
  logger = Logger.new(STDOUT)
  logger.level = Logger::INFO
  logger.progname = $PROGRAM_NAME
  logger.info('hi')

  options = { output: :stdout,
      test_run: false, blocks: true }
  x = RunCmd.new(logger, options)
  retVal = x.run('false')
  retVal = x.run('ls')
  retVal = x.run('ls')
  retVal = x.run('ls')
#  binding.pry
end
