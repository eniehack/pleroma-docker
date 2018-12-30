#!/usr/bin/env ruby

#
# TODO: Write a better translator.
# This is just rough text replacement right now
# but it's already way better than the exs stuff
# we had durin the .env files.
#

require 'yaml'
require 'json'

def getval(val)
    if val.is_a?(String)
        val.start_with?('<D>') ? val.delete('<D>') : val.to_json()
    else
        val.to_json()
    end
end

config = YAML.load_file(ARGV[0])

if config["version"] != 1
    raise "Incompatible config version (#{config["version"]} != 1)"
end

buf = "use Mix.Config\n\n"

config["app"].each do |atom, content|
    content.each do |sub, settings|
        buf += "config :#{atom}, #{sub.is_a?(Symbol) ? ":#{sub}" : sub}"

        if !settings.is_a?(Hash)
            buf += ": #{getval(settings)}\n"
            next
        end

        settings.each do |name, value|
            if value.is_a?(Hash) && value["<T>"] == "Array"
                value.delete("<T>")

                buf += ", #{name}: ["

                value.each do |k, v|
                    buf += "#{k}: #{getval(v)},"
                end
                buf.chop!()

                buf += "]"
            else
                buf += ", #{name}: #{getval(value)}"
            end
        end

        buf += "\n"
    end
end

puts buf
