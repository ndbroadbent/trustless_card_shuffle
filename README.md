# Trustless Card Shuffle

I was reading the Wikipedia page for [Mental Poker](https://en.wikipedia.org/wiki/Mental_poker).
The shuffling algorithm mentioned on that page requires commutative encryption,
so I wanted to see if I could figure out a different algorithm that was secure and potentially faster.

My algorithm uses public-key cryptography and XOR operations with random data.
The asymmetric encryption step with RSA prevents the known-plaintext attack
that would be possible if you only use XOR operations.

I'm not a cryptography expert, so it is very likely that this protocol has some security flaws.

You can view the code in [poc.rb](./poc.rb).


### Notes

This algorithm doesn't provide any guarantees that the shuffled deck will be valid. The parties
just have to assume that the original set of cards were valid, and didn't contain any duplicates.
The party who performs the final shuffle could also replace any card in the deck with random data,
and the other party would have no idea until the game reaches that point.

The [Toolbox for Mental Card Games and its Implementation](http://www.nongnu.org/libtmcg/libTMCG.pdf) paper
uses zero-knowledge proofs to solve these problems.

My next challenge is to figure out how to implement my own zero-knowledge proofs.
I might be able to use [this technique](https://crypto.stackexchange.com/a/16039/53925)
to provide a zero-knowledge proof that the first party used the RSA public key to
sign each card in the deck once (or something like that).
But I don't know how the proof would work with the one-time pad.
