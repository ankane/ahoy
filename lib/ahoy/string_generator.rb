module Ahoy
  module StringGenerator
    CHARACTERS = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghiklmnopqrstuvwxyz'

    def generate_token(length=32)
      length.times.inject('') { |token| token << CHARACTERS[Random.rand(CHARACTERS.length)] }
    end
  end
end