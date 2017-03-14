#!/usr/bin/env ruby
require 'json'

def generate(name, schema)
  File.write(name, JSON.dump(schema))
  puts "Schema created in #{name}"
end

statistics = {
  'type' => 'object',
  'additionalProperties' => false,
  'properties' => {
    'duration' => { 'type' => 'number' },
  },
}

# Tags are open right, with simple key-value associations and not restrictions
tags = { 'type' => 'object' }

result = {
  'type' => 'object',
  'additionalProperties' => false,
  'properties' => {
    'status' => { 'type' => 'string' },
    'code_desc' => { 'type' => 'string' },
    'run_time' => { 'type' => 'number' },
    'start_time' => { 'type' => 'string' },
    'skip_message' => { 'type' => 'string', 'optional' => true },
    'resource' => { 'type' => 'string', 'optional' => true },
  },
}

ref = {
  'type' => 'object',
  'additionalProperties' => false,
  'properties' => {
    'ref' => { 'type' => 'string' },
    # TODO: One of these needs to be deprecated
    'uri' => { 'type' => 'string', 'optional' => true },
    'url' => { 'type' => 'string', 'optional' => true },
  },
}
refs = { 'type' => 'array', 'items' => ref }

control = {
  'type' => 'object',
  'additionalProperties' => false,
  'properties' => {
    'id' => { 'type' => 'string' },
    'title' => { 'type' => %w{string null} },
    'desc' => { 'type' => %w{string null} },
    'impact' => { 'type' => 'number' },
    'refs' => refs,
    'tags' => tags,
    'code' => { 'type' => 'string' },
    'source_location' => {
      'type' => 'object',
      'properties' => {
        'ref' => { 'type' => 'string' },
        'line' => { 'type' => 'number' },
      },
    },
    'results' => { 'type' => 'array', 'items' => result },
  },
}

supports = {
  'type' => 'object',
  'additionalProperties' => false,
  'properties' => {
    'os-family' => { 'type' => 'string', 'optional' => true },
  },
}

control_group = {
  'type' => 'object',
  'additionalProperties' => false,
  'properties' => {
    'id' => { 'type' => 'string' },
    'title' => { 'type' => 'string', 'optional' => true },
    'controls' => { 'type' => 'array', 'items' => { 'type' => 'string' }},
  },
}

profile = {
  'type' => 'object',
  'additionalProperties' => false,
  'properties' => {
    'name' => { 'type' => 'string' },
    'version' => { 'type' => 'string', 'optional' => true },

    'title' => { 'type' => 'string', 'optional' => true },
    'maintainer' => { 'type' => 'string', 'optional' => true },
    'copyright' => { 'type' => 'string', 'optional' => true },
    'copyright_email' => { 'type' => 'string', 'optional' => true },
    'license' => { 'type' => 'string', 'optional' => true },
    'summary' => { 'type' => 'string', 'optional' => true },

    'supports' => {
      'type' => 'array',
      'items' => supports,
      'optional' => true,
    },
    'controls' => {
      'type' => 'array',
      'items' => control,
    },
    'groups' => {
      'type' => 'array',
      'items' => control_group,
    },
    'attributes' => {
      'type' => 'array',
      # TODO: more detailed specification needed
    },
  },
}

exec_full = {
  'type' => 'object',
  'additionalProperties' => false,
  'properties' => {
    'profiles' => {
      'type' => 'array',
      'items' => profile,
    },
    'statistics' => statistics,
    'version' => { 'type' => 'string' },

    # DEPRECATED PROPERTIES!! These will be removed with the next major version bump
    'controls' => 'array',
    'other_checks' => 'array',
  },
}

generate('inspec.exec.full.json', exec_full)

min_control = {
  'type' => 'object',
  'additionalProperties' => false,
  'properties' => {
    'id' => { 'type' => 'string' },
    'profile_id' => { 'type' => %w{string null} },
    'status' => { 'type' => 'string' },
    'code_desc' => { 'type' => 'string' },
    'skip_message' => { 'type' => 'string', 'optional' => true },
    'resource' => { 'type' => 'string', 'optional' => true },
  },
}

exec_min = {
  'type' => 'object',
  'additionalProperties' => false,
  'properties' => {
    'statistics' => statistics,
    'version' => { 'type' => 'string' },
    'controls' => {
      'type' => 'array',
      'items' => min_control,
    },
  },
}

generate('inspec.exec.min.json', exec_min)
