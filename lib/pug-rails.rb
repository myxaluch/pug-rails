# frozen_string_literal: true
require 'open3'
require 'tilt'
require 'json'

module Pug
  class << self
    def compile(source, options = {})
      source = source.read if source.respond_to?(:read)

      # Command line arguments take precedence over json options in Jade binary
      # @link https://github.com/jadejs/jade/blob/master/bin/jade.js
      # @link https://github.com/pugjs/pug-cli/blob/master/index.js
      cmd = [ options.fetch(:executable) ]
      cmd.push('--client')
      cmd.push('--path', options[:filename]) if options[:filename]
      cmd.push('--pretty')                   if options[:pretty]
      cmd.push('--no-debug')                 unless options[:debug]
      cmd.push('--obj', JSON.generate(options))

      stdout, stderr, exit_status = Open3.capture3(*cmd, stdin_data: source)
      raise CompileError.new(stderr) unless exit_status.success?
      stdout
    end

    def find_executable
      %w( pug jade ).find do |name|
        `which #{name}`
        $?.success?
      end
    end
  end

  class CompileError < ::StandardError
  end
end

require 'pug/template'
require 'pug/railtie' if defined?(Rails)

