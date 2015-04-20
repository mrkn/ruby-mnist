require "mnist/version"

require 'zlib'

module Mnist
  class Error < StandardError; end

  class LoadError < Error; end

  class InvalidMagic < LoadError; end

  class Loader
    IMAGE_FILE_MAGIC = 2051
    LABEL_FILE_MAGIC = 2049

    def initialize(filename)
      @filename = filename
    end

    attr_reader :filename

    def load_images
      check_magic(IMAGE_FILE_MAGIC)
      total_count = read_total_count
      nrows, ncols = read_image_size
      images = total_count.times.map do
        read_image(nrows, ncols)
      end
      [nrows, ncols, images]
    end

    def load_labels
      check_magic(LABEL_FILE_MAGIC)
      total_count = read_total_count
      read_labels(total_count)
    end

    private

    def check_magic(expected_magic)
      actual_magic = read_magic
      unless actual_magic == expected_magic
        raise InvalidMagic, "Expected #{expected_magic}, but #{actual_magic} is given"
      end
    end

    def read_uint8(n=1)
      input.read(n).unpack('C*')
    end

    def read_uint32(n=1)
      input.read(4 * n).unpack('N*')
    end

    def read_magic
      read_uint32.first
    end

    def read_total_count
      read_uint32.first
    end

    def read_image_size
      read_uint32(2)
    end

    alias read_labels read_uint8

    def read_image(nrows, ncols)
      input.read(nrows * ncols)
    end

    def input
      @input ||= Zlib::GzipReader.open(filename)
    end
  end

  def self.load_images(filename)
    Loader.new(filename).load_images
  end

  def self.load_labels(filename)
    Loader.new(filename).load_labels
  end
end
