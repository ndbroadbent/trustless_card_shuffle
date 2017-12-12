#!/bin/env ruby
require 'securerandom'
require 'digest'

def bytes_to_int(bytes)
  bytes.unpack("C*").reduce(0) {|s, (b, _)| s * 256 + b }
end


# 1. Alice and Bob both commit to 52 random 256-bit integers (32 random bytes)
alice_bytes = 52.times.map { SecureRandom.random_bytes(32) }
bob_bytes = 52.times.map { SecureRandom.random_bytes(32) }

# 2. Alice and Bob both generate SHA-256 digests for their integers
alice_digests = alice_bytes.map { |i| Digest::SHA256.digest i }
bob_digests = bob_bytes.map { |i| Digest::SHA256.digest i }

# 3. Alice and Bob both generate RSA digests for their integers
alice_digests = alice_bytes.map { |i| Digest::SHA256.digest i }
bob_digests = bob_bytes.map { |i| Digest::SHA256.digest i }

# 2. Alice and Bob share their SHA-256 digests.

# 3. The game begins, and both parties agree to deal a community card (public to both parties.)

# 4. Bob sends Alice his first integer.
bob_public_bytes = [ bob_bytes[0] ]

# 5. Alice verifies that this is the committed integer by comparing the SHA-256 hashes.
puts Digest::SHA256.digest(bob_public_bytes[0]) == bob_digests[0]

# 6. Alice sends Bob her first integer.
alice_public_bytes = [ alice_bytes[0] ]

# 7. Bob verifies that this is the committed integer by comparing the SHA-256 hashes.
puts Digest::SHA256.digest(alice_public_bytes[0]) == alice_digests[0]

# 8. Alice and Bob calculate mod 52 of the sum of their integers to agree on a "card pointer".
sum = bytes_to_int(bob_public_bytes[0]) + bytes_to_int(alice_public_bytes[0])
card_pointer = sum % 52

# 9. Alice and Bob both maintain a record of previously dealt cards.
dealt_cards = [false] * 52

# 10. Alice and Bob use the last bit of the sum to set a random "step size".
#     If the XOR result is 0, the step size is 25. If the XOR result is 1, the step size is 27.
step_size = sum % 1 == 0 ? 25 : 27

# They add the step size to the card pointer and calculate mod 52 until they find a
# card that is still in the deck.

while dealt_cards[card_pointer]
  card_pointer += step_size
  card_pointer %= 52
end

puts card_pointer
dealt_cards[card_pointer] = true

# 11. If all the cards have been dealt, they go back to step 1 to start a new deck.
#     In a game of poker, players would start a new deck at the beginning of every round.
puts dealt_cards.all?


# Note: This algorithm works with any number of players.
