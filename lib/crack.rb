require_relative 'cipher_builder'
require_relative 'offset_gen'
require_relative 'decrypt'
require 'pry'

class Crack
  attr_reader :offset, :char_map

  def initialize
    @char_map = CipherBuilder.new.gen_map
    @offset = OffsetGen.new.generate_offset
  end

  def crack(message, offset=@offset)
    final = []
    message.chars.map!.with_index do |char, index|
      case index % 4
      when 0
        rotation = @char_map.index(char) - rotation(message, -4)
        decrypted_char = @char_map.rotate(rotation).shift
        final << decrypted_char
      when 1
        rotation = @char_map.index(char) - rotation(message, -3)
        decrypted_char = @char_map.rotate(rotation).shift
        final << decrypted_char
      when 2
        rotation = @char_map.index(char) - rotation(message, -2)
        decrypted_char = @char_map.rotate(rotation).shift
        final << decrypted_char
      when 3
        rotation = @char_map.index(char) - rotation(message, -1)
        decrypted_char = @char_map.rotate(rotation).shift
        final << decrypted_char
      end
    end
    final.join
  end

  def rotation(message, rotation_id)
    switch = message.length % 4
    encrypted_char = message[rotation_id-switch]
    given = '..end..'
    decrypted_char = given[rotation_id-switch]
    message_rotation = (@char_map.index(encrypted_char)) - (@char_map.index(decrypted_char))
    message_rotation % @char_map.count
  end

  def crack_file(input, output)
    file = File.open(input, "r").read
    file = file.chomp
    cracked = self.crack(file)
    output_file = File.open(output, 'w')
    output_file.write(cracked)
    output_file.close
    puts "Created file #{output.to_s}"
  end
end

if __FILE__ == $0
  Crack.new.crack_file(ARGV.first, ARGV.last)
end
