#!/bin/false

require 'logger'
require 'colorize'
require 'recursive_open_struct'

class MqttServiceLogger
  def initialize(config)
    @loggers = {}
    @logger_formatter = proc do |severity, datetime, _progname, msg|
      "%s %-6s %s\n" % [datetime, severity, msg]
    end

    config.each do |logger_config|
      logger_config = RecursiveOpenStruct.new(logger_config)

      if logger_config.path == 'STDOUT'
        STDOUT.sync = true
        logger = Logger.new(STDOUT)
      else
        logger = Logger.new(
          logger_config.path,
          logger_config.count,
          logger_config.size
        )
      end

      logger.level = logger_config.level if logger_config.level
      logger.formatter = @logger_formatter
      @loggers[logger_config.path] = logger
    end

  end

  def debug(msg)
    each_logger { |logger| logger.debug(msg.light_blue) }
  end

  def info(msg)
    each_logger { |logger| logger.info(msg.green) }
  end

  def data(msg)
    each_logger { |logger| logger.info(msg.magenta) }
  end

  def warn(msg)
    each_logger { |logger| logger.warn(msg.yellow) }
  end

  def error(msg)
    each_logger { |logger| logger.error(msg.red) }
  end

  def error_bold(msg)
    each_logger { |logger| logger.error(msg.red.bold) }
  end

  alias_method :fatal, :error_bold

  private

  def each_logger
    @loggers.each do |_key, logger|
      yield logger
    end
  end
end
