# Trustless Card Shuffle

I was reading the Wikipedia page for [Mental Poker](https://en.wikipedia.org/wiki/Mental_poker).
The shuffling algorithm mentioned on that page requires a commutative encryption algorithm,
which can be quite slow.

My proposed algorithm is very simple. The players commit to random numbers,
and publish SHA-256 digests so that they cannot change these numbers.
When a player knows both random numbers, they can perform a deterministic calculation
to find the next card in the sequence.
If both players share their random numbers with each other,
they both discover the value of the next card. Cards can be revealed in any order,
to any party.

As long as one party provides a completely random number, the other party cannot
affect the outcome of the deterministic calculation without bruteforcing SHA-256.
Even if they successfully calculate all the possible SHA-256 hashes for all possible
256-bit numbers, they are likely to only find a single collision. And then they have
to find a corresponding collision for the card that they would like to swap.
The chance of a single SHA-256 collision is vanishingly small.
The chance of two matching SHA-256 collisions in a shuffled deck of 52 cards is incomprehensibly small,
even if someone was using a quantum computer.


### Notes

This shuffling algorithm only solves a very specific problem, and does not implement anything
else that would be required for Mental Poker.
