require 'openssl'

module Inspec::Resources
  class X509Certificate < Inspec.resource(1)
    name 'x509_certificate'
    desc 'request wmi information'
    example "
      describe x509_certificate('cert.pem') do
        it { should be_certificate }
        it { should be_valid }
        its('signature_algorithm') { should eq 'sha1WithRSAEncryption' }
        its('validity_in_days') { should_not be < 100 }
        its('validity_in_days') { should be >= 100 }
        its('subject') { should eq '/C=DE/ST=Berlin/L=Berlin/O=InSpec/OU=Chef Software, Inc/CN=inspec.io/emailAddress=support@chef.io' }
        its('issuer') { should eq '/C=DE/ST=Berlin/L=Berlin/O=InSpec/OU=Chef Software, Inc/CN=inspec.io/emailAddress=support@chef.io' }
        its('email') { should_not be_empty }
        its('email') { should eq 'support@chef.io' }
        its('keylength') { should be >= 2048 }
      end
    "

    def initialize(filename)
      # TODO: allow the resource to take content similar to json resource
      file = inspec.file(filename)
      return if file.nil? || file.content.nil?
      begin
        @cert = OpenSSL::X509::Certificate.new file.content
      rescue OpenSSL::X509::CertificateError
        @cert = nil
      end
    end

    def version
      return if @cert.nil?
      @cert.version
    end

    def serial
      return if @cert.nil?
      @cert.serial
    end

    def signature_algorithm
      return if @cert.nil?
      @cert.signature_algorithm
    end

    def certificate?
      !@cert.nil?
    end

    # @see https://tools.ietf.org/html/rfc5280#page-23
    # CN: CommonName
    # OU: OrganizationalUnit
    # O: Organization
    # L: Locality
    # S: StateOrProvinceName
    # C: CountryName
    def subject
      return if @cert.nil?
      @cert.subject.to_s
    end

    def issuer
      # parse the values
      return if @cert.nil?
      @cert.issuer.to_s
    end

    def fingerprint
      return if @cert.nil?
      OpenSSL::Digest::SHA1.new(@cert.to_der).to_s
    end

    def keylength
      return if @cert.nil?
      @cert.public_key.n.num_bytes * 8
    end

    def extensions
      @cert.extensions.map(&:to_h)
    end

    # emailAddress is legacy
    # TODO: should we deprecated it
    def email
      return if @cert.nil?
      extract(@cert.subject, 'emailAddress')
    end

    def valid?
      now = Time.now
      (now >= @cert.not_before && now <= @cert.not_after)
    end

    def validity_in_days
      diff = @cert.not_after - Time.now
      (diff / (60 * 60 * 24))
    end

    private

    def extract(subject, key)
      subject.to_a.each { |entry|
        return entry[1] if entry[0] == key
      }
    end
  end
end
