# encoding: utf-8
# usage: ruby schema.rb
require 'json'

module InSpecSchema # rubocop:disable Metrics/ModuleLength
  def self.generate(name, schema)
    File.write(name, JSON.dump(schema))
    puts "Schema created in #{name}"
  end

  Statistics = {
    'type' => 'object',
    'additionalProperties' => false,
    'properties' => {
      'duration' => { 'type' => 'number' },
    },
  }.freeze

  # Tags are open right, with simple key-value associations and not restrictions
  Tags = { 'type' => 'object' }.freeze

  Result = {
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
  }.freeze

  Ref = {
    'type' => 'object',
    'additionalProperties' => false,
    'properties' => {
      'ref' => { 'type' => 'string' },
      # TODO: One of these needs to be deprecated
      'uri' => { 'type' => 'string', 'optional' => true },
      'url' => { 'type' => 'string', 'optional' => true },
    },
  }.freeze
  Refs = { 'type' => 'array', 'items' => Ref }.freeze

  Control = {
    'type' => 'object',
    'additionalProperties' => false,
    'properties' => {
      'id' => { 'type' => 'string' },
      'title' => { 'type' => %w{string null} },
      'desc' => { 'type' => %w{string null} },
      'impact' => { 'type' => 'number' },
      'refs' => Refs,
      'tags' => Tags,
      'code' => { 'type' => 'string' },
      'source_location' => {
        'type' => 'object',
        'properties' => {
          'ref' => { 'type' => 'string' },
          'line' => { 'type' => 'number' },
        },
      },
      'results' => { 'type' => 'array', 'items' => Result },
    },
  }.freeze

  Supports = {
    'type' => 'object',
    'additionalProperties' => false,
    'properties' => {
      'os-family' => { 'type' => 'string', 'optional' => true },
    },
  }.freeze

  Control_group = {
    'type' => 'object',
    'additionalProperties' => false,
    'properties' => {
      'id' => { 'type' => 'string' },
      'title' => { 'type' => 'string', 'optional' => true },
      'controls' => { 'type' => 'array', 'items' => { 'type' => 'string' } },
    },
  }.freeze

  Profile = {
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
        'items' => Supports,
        'optional' => true,
      },
      'controls' => {
        'type' => 'array',
        'items' => Control,
      },
      'groups' => {
        'type' => 'array',
        'items' => Control_group,
      },
      'attributes' => {
        'type' => 'array',
        # TODO: more detailed specification needed
      },
    },
  }.freeze

  Exec_full = {
    'type' => 'object',
    'additionalProperties' => false,
    'properties' => {
      'profiles' => {
        'type' => 'array',
        'items' => Profile,
      },
      'statistics' => Statistics,
      'version' => { 'type' => 'string' },

      # DEPRECATED PROPERTIES!! These will be removed with the next major version bump
      'controls' => 'array',
      'other_checks' => 'array',
    },
  }.freeze

  Min_control = {
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
  }.freeze

  Exec_min = {
    'type' => 'object',
    'additionalProperties' => false,
    'properties' => {
      'statistics' => Statistics,
      'version' => { 'type' => 'string' },
      'controls' => {
        'type' => 'array',
        'items' => Min_control,
      },
    },
  }.freeze
end

InSpecSchema.generate('inspec.exec.full.json', InSpecSchema::Exec_full)
InSpecSchema.generate('inspec.exec.min.json', InSpecSchema::Exec_min)
