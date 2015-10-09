# encoding: utf-8
# author: Christoph Hartmann
# author: Dominik Richter

# Usage:
# describe bridge('br0') do
#   it { should exist }
#   it { should have_interface 'eth0' }
# end

class Bridge < Vulcano.resource(1)
  name 'bridge'

  def initialize(bridge_name)
    @bridge_name = bridge_name

    @bridge_provider = nil
    if vulcano.os.linux?
      @bridge_provider = LinuxBridge.new(vulcano)
    elsif vulcano.os.windows?
      @bridge_provider = WindowsBridge.new(vulcano)
    else
      return skip_resource 'The `bridge` resource is not supported on your OS yet.'
    end
  end

  def exists?
    !bridge_info.nil? && !bridge_info[:name].nil?
  end

  def has_interface?(interface)
    return skip_resource 'The `bridge` resource does not provide interface detection for Windows yet' if vulcano.os.windows?
    bridge_info.nil? ? false : bridge_info[:interfaces].include?(interface)
  end

  def interfaces
    bridge_info.nil? ? nil : bridge_info[:interfaces]
  end

  private

  def bridge_info
    return @cache if defined?(@cache)
    @cache = @bridge_provider.bridge_info(@bridge_name) if !@bridge_provider.nil?
  end
end

class BridgeDetection
  def initialize(vulcano)
    @vulcano = vulcano
  end
end

# Linux Bridge
# If /sys/class/net/{interface}/bridge exists then it must be a bridge
# /sys/class/net/{interface}/brif contains the network interfaces
# @see http://www.tldp.org/HOWTO/BRIDGE-STP-HOWTO/set-up-the-bridge.html
# @see http://unix.stackexchange.com/questions/40560/how-to-know-if-a-network-interface-is-tap-tun-bridge-or-physical
class LinuxBridge < BridgeDetection
  def bridge_info(bridge_name)
    # read bridge information
    bridge = @vulcano.file("/sys/class/net/#{bridge_name}/bridge").directory?
    return nil unless bridge

    # load interface names
    interfaces = @vulcano.command("ls -1 /sys/class/net/#{bridge_name}/brif/")
    interfaces = interfaces.stdout.chomp.split("\n")
    {
      name: bridge_name,
      interfaces: interfaces,
    }
  end
end

# Windows Bridge
# select netadapter by adapter binding for windows
# Get-NetAdapterBinding -ComponentID ms_bridge | Get-NetAdapter
# @see https://technet.microsoft.com/en-us/library/jj130921(v=wps.630).aspx
# RegKeys: HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002BE10318}
class WindowsBridge < BridgeDetection
  def bridge_info(bridge_name)
    # find all bridge adapters
    cmd = @vulcano.command('Get-NetAdapterBinding -ComponentID ms_bridge | Get-NetAdapter | Select-Object -Property Name, InterfaceDescription | ConvertTo-Json')

    # filter network interface
    begin
      bridges = JSON.parse(cmd.stdout)
    rescue JSON::ParserError => _e
      return nil
    end

    # ensure we have an array of groups
    bridges = [bridges] if !bridges.is_a?(Array)

    # select the requested interface
    bridges = bridges.each_with_object([]) do |adapter, adapter_collection|
      # map object
      info = {
        name: adapter['Name'],
        interfaces: nil,
      }
      adapter_collection.push(info) if info[:name].casecmp(bridge_name) == 0
    end

    return nil if bridges.size == 0
    warn "[Possible Error] detected multiple bridges interfaces with the name #{bridge_name}" if bridges.size > 1
    bridges[0]
  end
end
