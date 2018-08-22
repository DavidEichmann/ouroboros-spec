# Overview

Most of my efforts have been reading/learning. On that I can only comment on some sticking points. I've also gone through "Oroboros Praos in the ψ-Calculus" and added notes to it.

# Sticking Points While Reading the Paper

Much of the paper uses the framework set out by Ran Canetti in "Universally Composable Security: A New Paradigm for Cryptographic Protocols"

The main difference with Praos is a small change to the chain slection rule. See "Condition B" in Fig. 9.

$NONCE$ and $TEST$ are known arbitrarily selected constants for the block chain.

## Open questions

How is k derived? Or is it arbitrary?

In practice, how do we get public keys (for KES and VRF) for a party U_i? in the genesis paper Appendix B "IsValidChain" seems to have access to $v_{p'}^vrf$ but how? Is this just derived from the block chain (from the stakeholders/transactions)? In our model (Ouroboros Praos in the ψ-calculus), we get this from the block signature, but this doesn't seem to reflect how signature schemes work in reality.

Often public key $v_i$ is used for party $U_i$, but how does one get the $v_i$ e.g. when trying to verify a block chain is signed correctly?

# Regarding "Ouroboros Praos in the ψ-calculus"

I've gone through the document and made few rough changes and notes avalabe at [github](https://github.com/DavidEichmann/ouroboros-spec/tree/Genesis%CF%88/Exploration/Ouroboros%20Genesis%20in%20the%20%CF%88-calculus). That directory is adapted from "Ouroboros Genesis in the ψ-calculus". You may want to run a diff between "Ouroboros Genesis in the ψ-calculus/Genesis.lhs" and "Ouroboros Praos in the ψ-calculus/Praos.lhs" to see the changes.

## KES

The paper describes a KES where the (private) keys "evolve" over time, but our model doesn't seem to include this.

I've tried to model KES in Genesis.lhs.

## Inputs to VRF do not seem to clearly reflect the paper

In particular, the $ep"th epoch nonce $\eta_{ep}$ appears to incorporate all previous VRF outputs (see our model's verifyCwcHead function vs genesis paper Fig. 13.) while the paper incorporates only a subset (see genesis paper Fig. 8. line 4 "... from the first 2R/3 slots of epoch ep-1")
