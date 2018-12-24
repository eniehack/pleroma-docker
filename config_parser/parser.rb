#!/usr/bin/env ruby

require 'yaml'
require 'json'

config = YAML.load_file(ARGV[0])

if config["version"] != 1
    raise "Incompatible config version (#{config["version"]} != 1)"
end

buf = "use Mix.Config\n\n"

config["app"].each do |atom, content|
    content.each do |sub, settings|
        buf += "config :#{atom}, #{sub.is_a?(Symbol) ? ":#{sub}" : sub}"

        if !settings.is_a? Hash
            buf += ": #{settings.to_json}\n"
            next
        end

        settings.each do |name, value|
            if value.is_a?(Hash) && value["<T>"] == "Array"
                value.delete("<T>")

                buf += ", #{name}: ["

                value.each do |k, v|
                    buf += "#{k}: #{v.to_json},"
                end
                buf.chop!

                buf += "]"
            else
                buf += ", #{name}: #{value.to_json}"
            end
        end

        buf += "\n"
    end
end

puts buf
