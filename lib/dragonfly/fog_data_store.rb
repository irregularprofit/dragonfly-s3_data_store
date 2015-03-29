require 'fog'
require 'dragonfly'

Dragonfly::App.register_datastore(:fog){ Dragonfly::FogDataStore }

module Dragonfly
  class FogDataStore

    # Exceptions
    class NotConfigured < RuntimeError; end

    REGIONS = [:dfw, :ord, :iad, :lon, :syd, :hkg]

    def initialize(opts={})
      @container = opts[:container]
      @username = opts[:username]
      @api_key = opts[:api_key]
      @region = opts[:region]
      @storage_headers = opts[:storage_headers] || {}

      @url_scheme = opts[:url_scheme] || 'http'
      @url_host = opts[:url_host]
    end

    attr_accessor :container, :username, :api_key, :region,
      :url_scheme, :url_host, :storage_headers

    def write(content, opts={})
      ensure_configured
      ensure_container_initialized

      headers = {'Content-Type' => content.mime_type}
      headers.merge!(opts[:headers]) if opts[:headers]
      uid = opts[:path] || generate_uid(content.name || 'file')

      rescuing_socket_errors do
        content.file do |f|
          storage.put_object(container, full_path(uid), f, full_storage_headers(headers, content.meta))
        end
      end

      uid
    end

    def read(uid)
      ensure_configured

      response = rescuing_socket_errors{ storage.get_object(container, full_path(uid)) }
      [response.body, headers_to_meta(response.headers)]
    rescue Fog::Storage::Rackspace::NotFound
      nil
    rescue Excon::Errors::NotFound => e
      nil
    end

    def destroy(uid)
      rescuing_socket_errors{ storage.delete_object(container, full_path(uid)) }
    rescue Fog::Storage::Rackspace::NotFound
      nil
    rescue Excon::Errors::NotFound, Excon::Errors::Conflict => e
      Dragonfly.warn("#{self.class.name} destroy error: #{e}")
    end

    def storage
      @storage ||= begin
        storage = Fog::Storage.new({
          provider: 'Rackspace',
          rackspace_username: username,
          rackspace_api_key: api_key,
          rackspace_region: region
        })
        storage
      end
    end

    def container_exists?
      rescuing_socket_errors{ storage.get_container(container) }
      true
    rescue Fog::Storage::Rackspace::NotFound
      nil
    rescue Excon::Errors::NotFound => e
      false
    end

    private

    def ensure_configured
      unless @configured
        [:container, :username, :api_key, :container].each do |attr|
          raise NotConfigured, "You need to configure #{self.class.name} with #{attr}" if send(attr).nil?
        end
        @configured = true
      end
    end

    def ensure_container_initialized
      unless @container_initialized
        rescuing_socket_errors{ storage.put_container(container) } unless container_exists?
        @container_initialized = true
      end
    end

    def get_region
      reg = region || :ord
      raise "Invalid region #{reg} - should be one of #{REGIONS.join(', ')}" unless REGIONS.include?(reg)
      reg
    end

    def generate_uid(name)
      "#{Time.now.strftime '%Y/%m/%d/%H/%M/%S'}/#{rand(1000)}/#{name.gsub(/[^\w.]+/, '_')}"
    end

    def full_path(uid)
      File.join *[uid].compact
    end

    def full_storage_headers(headers, meta)
      storage_headers.merge(meta_to_headers(meta)).merge(headers)
    end

    def headers_to_meta(headers)
      json = headers['X-Object-Meta']
      if json && !json.empty?
        Serializer.json_decode(json)
      end
    end

    def meta_to_headers(meta)
      {'X-Object-Meta' => Serializer.json_encode(meta)}
    end

    def rescuing_socket_errors(&block)
      yield
    rescue Excon::Errors::SocketError => e
      storage.reload
      yield
    end

  end
end
