#!/bin/env ruby
require 'securerandom'
require 'openssl'
require 'base64'

def byte_string_xor(s1, s2)
  s1.unpack('C*').zip(s2.unpack('C*')).map { |a, b| a ^ b }.pack('C*')
end


# -----------------------------------------------------------------------------

# 1. Bob generates a new 128-bit RSA key pair, and sends the public key to Alice

bob_private_key = OpenSSL::PKey::RSA.generate(128)
puts Base64.encode64(bob_private_key.to_der)
# MGMCAQACEQDUjFkPhhGLkMyO/G72b2dHAgMBAAECEQC7UCR8xc5Yi1tZPjhh
# YoNhAgkA+fzRtebDZwUCCQDZqQN60FQO2wIIcJF2wWlbXh0CCQDHT4ksMRCH
# +QIIG8o+xynJ4dM=

bob_public_key = bob_private_key.public_key
puts Base64.encode64(bob_public_key.to_der)
# MCwwDQYJKoZIhvcNAQEBBQADGwAwGAIRANSMWQ+GEYuQzI78bvZvZ0cCAwEA
# AQ==


# 2. Alice shuffles the deck of cards
alice_cards = (0...52).to_a.shuffle
# => [38, 10, 34, 12, 23, 1, 24, 51, 37, 35, 43, 42, 17, 41, 15, 25, 27, 0, 22, 46, 18, 47, 5, 45, 21, 33, 8, 13, 11, 30, 7, 4, 49, 40, 3, 29, 28, 50, 19, 26, 16, 20, 14, 48, 32, 39, 6, 9, 36, 44, 2, 31]

# 3. Alice encrypts each card using Bob's public key
encrypted_cards = alice_cards.map do |c|
  bob_public_key.public_encrypt [c].pack('C')
end

# 4. Alice XORs each encrypted card with random data, and sends the shuffled cards to Bob.
alice_random_bytes = 52.times.map { SecureRandom.random_bytes(16) }
alice_xor_cards = encrypted_cards.zip(alice_random_bytes).map do |card, bytes|
  byte_string_xor card, bytes
end

# 5. Bob now shuffles the cards, and remembers the original positions of the cards that Alice sent him.

bob_shuffle = (0...52).to_a.shuffle
# => [46, 21, 7, 49, 39, 17, 10, 37, 25, 32, 9, 40, 38, 50, 15, 36, 14, 22, 48, 4, 16, 23, 33, 41, 35, 12, 47, 34, 43, 1, 24, 20, 6, 44, 27, 2, 45, 31, 8, 42, 51, 19, 3, 13, 5, 26, 11, 18, 0, 30, 29, 28]

bob_cards = bob_shuffle.map { |i| alice_xor_cards[i] }

# 6. Bob XORs each card with his own random data
bob_random_bytes = 52.times.map { SecureRandom.random_bytes(16) }
final_shuffled_cards = bob_cards.zip(bob_random_bytes).map do |card, bytes|
  byte_string_xor card, bytes
end


# 7. Bob sends the shuffled cards back to Alice.

# 8. The game can now begin using the final_shuffled_cards.
#    Both parties agree to reveal the first card.

# 9. Bob tells Alice that the first card is at index 46 in her array.

# GAME OVER!
# -------------------------------------------------------------

# Alice now has enough information to control the card that Bob sees.
# She knows he'll be running XOR commands with data that she controls,
# then he'll decrypt the result.

# She wants Bob to think that he has a card with the value 38.

encrypted_38 = bob_public_key.public_encrypt [38].pack('C')
crafted_data = byte_string_xor alice_xor_cards[46], encrypted_38

# Alice sends her crafted data to Bob. Bob then runs:

bob_private_key.private_decrypt(byte_string_xor alice_xor_cards[46], crafted_data).unpack('C')[0]
# He sees the result: 38
# The correct result should have been: 6


# Alice keeps her secret ability hidden from Bob, so as not to raise suspicion.
# She slightly shifts the odds in her favour, and wins every single game by a small margin.




# Don't roll your own crypto.

# --------------------------------------------------------------------------------


# 10. Alice fetches the random data she used for this index, and sends it to Bob.

# Bob can now decrypt the card, since he knows Alice's random data and his own private key.

first_encrypted_card = byte_string_xor alice_xor_cards[46], alice_random_bytes[46]
# => "n[\x94B\xACY\xC5\x86\xF3Y2p\x15\xC8\x88\x0E"

bob_private_key.private_decrypt(first_encrypted_card).unpack('C')[0]
# => 6       # (You can see the value "6" at index 46 in the alice_cards array)


# 11. Bob sends his random data to Alice.




# Bob now knows that this card has the value of "6".
# (If you encoded the cards from Ace to King, and in the order of hearts, diamonds, spades, and clubs,
# then "6" would represent the 7 of hearts.)

# Alice can also verify that this is true by using Bob's random data to partially
# decrypt the dealt card, and checking that this matches the card at her index i.

# (The asymmetric encryption step with RSA prevents a known-plaintext attack
# that would be possible if only XOR operations are used.)


# 10. The second card is dealt to Alice. She will be able to view the card, but it will stay hidden from Bob.

# Bob tells Alice that the second card is at index 21 in her array.
# He sends the random data that she can use to verify this.
# Alice looks at her shuffled cards and knows that the value should be 47.
# She runs the XOR operation with Bob's random data:

xor_with_bobs_random_data = byte_string_xor final_shuffled_cards[1], bob_random_bytes[1]
# => ",\xFD\n\x03\xAE\x80\tJ\x0ER\x9F\xC8\xFA\x12^\xC7"

# ... and verifies that this is the encrypted card she sent to Bob:
puts alice_xor_cards[21] == xor_with_bobs_random_data
# => true


# Now they can continue playing the game and revealing the appropriate cards to each other.
