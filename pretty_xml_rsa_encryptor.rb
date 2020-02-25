require 'openssl'
require 'base64'
require 'nori'
require 'yaml'
require 'dry/cli'

module Texts
  TEXTS_FILE = 'locales.ru.yml'.freeze

  class << self
    def get(category, key)
      load_texts[category.to_s][key.to_s]
    end

    private

    def load_texts
      @texts ||= YAML.load_file(TEXTS_FILE)
    end
  end
end

module CLI
  VERSION = '1.0.0'.freeze

  module Commands
    extend Dry::CLI::Registry

    class Version < Dry::CLI::Command
      desc Texts.get(:desc, :version)

      def call(*)
        puts VERSION
      end
    end

    class Generate < Dry::CLI::Command
      desc Texts.get(:desc, :generate)

      option :key_len, default: 2048, desc: Texts.get(:desc, :key_len)
      option :key_name, default: '', desc: Texts.get(:desc, :key_name)

      def call(key_len:, key_name:, **)
        if key_len.to_i < 512
          puts Texts.get(:errors, :small_key)
          return
        end

        key_name = nil if key_name.empty?
        Encryptor.new(key_len: key_len.to_i).save(name: key_name)
      end
    end

    class Encrypt < Dry::CLI::Command
      desc Texts.get(:desc, :encrypt)

      argument :file, type: :string, required: true, desc: Texts.get(:desc, :file)
      argument :pub_key, type: :string, required: true, desc: Texts.get(:desc, :pub_key)

      def call(file:, pub_key:, **)
        pre_call_hook(file, pub_key)
        XMLEncryptor.new(file, encrypt_mode: true, key: pub_key).write
        puts Texts.get(:info, :success)
      rescue StandardError => e
        puts Texts.get(:errors, :general) % { error: e }
      end

      private

      def pre_call_hook(file, pub_key)
        raise StandardError, Texts.get(:errors, :no_key) unless File.exist?(pub_key)
        raise StandardError, Texts.get(:errors, :no_file) unless File.exist?(file)
      end
    end

    class Decrypt < Dry::CLI::Command
      desc Texts.get(:desc, :decrypt)

      argument :file, type: :string, required: true, desc: Texts.get(:desc, :file)
      argument :key, type: :string, required: true, desc: Texts.get(:desc, :key)

      def call(file:, key:, **)
        pre_call_hook(file, key)
        XMLEncryptor.new(file, encrypt_mode: false, key: key).write
        puts Texts.get(:info, :success)
      rescue StandardError => e
        puts Texts.get(:errors, :general) % { error: e }
      end

      private

      def pre_call_hook(file, key)
        raise StandardError, Texts.get(:errors, :no_key) unless File.exist?(key)
        raise StandardError, Texts.get(:errors, :no_file) unless File.exist?(file)
      end
    end

    register 'version', Version, aliases: %w[v -v --version]
    register 'generate', Generate, aliases: %w[g -g --generate]
    register 'encrypt', Encrypt, aliases: %w[enc -enc --encrypt]
    register 'decrypt', Decrypt, aliases: %w[dec -dec --decrypt]
  end
end

class Encryptor
  def initialize(key: nil, key_len: nil)
    @key = if key.nil?
             OpenSSL::PKey::RSA.generate(key_len)
           else
             read_key(key)
           end
  end

  def save(name: nil)
    name ||= 'rsa'

    File.write(name, @key.to_pem) if @key.private?
    File.write("#{name}.pub", @key.public_key.to_pem) if @key.public?

    puts Texts.get(:info, :write_key) % { public: "#{name}.pub", private: name }
  end

  def encrypt(data)
    pack(@key.public_encrypt(data))
  end

  def decrypt(data)
    data = unpack(data)

    @key.private_decrypt(data)
  end

  private

  def read_key(path)
    key_path = File.absolute_path(path)
    key = File.read(key_path)

    OpenSSL::PKey::RSA.new(key)
  end

  def pack(value)
    Base64.urlsafe_encode64(value)
  end

  def unpack(value)
    Base64.urlsafe_decode64(value)
  end
end

class XMLEncryptor < Encryptor
  def initialize(xml_path, encrypt_mode: true, key: nil)
    super(key: key)
    @xml_path = File.absolute_path(xml_path)
    @data = Nori.new.parse(File.read(@xml_path))
    @encrypt_mode = encrypt_mode
  end

  def write
    builder = Nokogiri::XML::Builder.new do |xml_builder|
      xml_node(@data, xml_builder)
    end

    prefix = @encrypt_mode ? 'enc' : 'dec'
    path = File.dirname(@xml_path)
    name = File.basename(@xml_path)
    new_file = File.join(path, "#{prefix}_#{name}")
    File.write(new_file, builder.to_xml)
  end

  private

  def xml_node(data, xml)
    data.each do |key, value|
      if value.is_a? String
        value = @encrypt_mode ? encrypt(value) : decrypt(value)
        xml.send(key, value)
      else
        xml.send(key.to_s) { xml_node(value, xml) }
      end
    end
  end
end

Dry::CLI.new(CLI::Commands).call if $PROGRAM_NAME == __FILE__
