# from https://github.com/rails/activerecord-session_store/blob/master/lib/active_record/session_store/extension/logger_silencer.rb
require "thread"
require "active_support/core_ext/class/attribute_accessors"
require "active_support/core_ext/module/aliasing"
require "active_support/core_ext/module/attribute_accessors"
require "active_support/concern"

module Ahoy
  module LoggerSilencer
    def self.prepended(base)
      base.cattr_accessor :silencer
      base.silencer = true
    end

    def thread_level
      Thread.current[thread_hash_level_key]
    end

    def thread_level=(level)
      Thread.current[thread_hash_level_key] = level
    end

    def level
      thread_level || super
    end

    def add(severity, message = nil, progname = nil, &block)
      if !defined?(@logdev) || @logdev.nil? || (severity || UNKNOWN) < level
        true
      else
        super
      end
    end

    # Silences the logger for the duration of the block.
    def silence_logger(temporary_level = Logger::ERROR)
      if silencer
        begin
          self.thread_level = temporary_level
          yield self
        ensure
          self.thread_level = nil
        end
      else
        yield self
      end
    end

    for severity in Logger::Severity.constants
      class_eval <<-EOT, __FILE__, __LINE__ + 1
        def #{severity.downcase}?                # def debug?
          Logger::#{severity} >= level           #   DEBUG >= level
        end                                      # end
      EOT
    end

    private

    def thread_hash_level_key
      @thread_hash_level_key ||= :"ThreadSafeLogger##{object_id}@level"
    end
  end
end

class NilLogger
  def self.silence_logger
    yield
  end
end
