require 'openssl'

module Inspec::Resources
  class RSA_Key < Inspec.resource(1)
    name 'key_rsa'
    desc 'public/private RSA key pair test'
    example "
      describe rsa_key('key.pem', 'passphrase') do
        it { should be_valid }
        it { should be_private }
        it { should be_public }
      end
    "

    def initialize(filename, passphrase = '')
      file = inspec.file(filename)
      @passphrase = passphrase
      return if file.nil? || file.content.nil?

      begin
        @key = OpenSSL::PKey.read(file.content, @passphrase)
      rescue OpenSSL::PKey::RSAError
        # TODO: we should throw an exception here
        return skip_resource 'Unable to load private key'
      end
    end

    def valid?
      public?
    end

    def public?
      return if @key.nil?
      @key.public?
    end

    def private?
      return if @key.nil?
      @key.private?
    end
  end
end
