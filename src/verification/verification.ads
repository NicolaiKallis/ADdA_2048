-------------------------------------------------------------------------------
--  Verification Package
--
--  This package hierarchy contains GHOST code used exclusively for SPARK
--  formal verification. Ghost code is automatically stripped from production
--  builds and has ZERO runtime overhead.
--
--  IMPORTANT: Code in this package is NEVER executed at runtime.
--  It exists solely to:
--    1. Express mathematical properties in contracts (Pre/Post conditions)
--    2. Define loop invariants for proof obligations
--    3. Provide helper predicates for SPARK provers
--
--  Do NOT call these functions from non-ghost code except in:
--    - Preconditions (Pre =>)
--    - Postconditions (Post =>)
--    - Assert/Loop_Invariant pragmas
--    - Other ghost code
--
--  See SPARK User's Guide for more information on Ghost code.
-------------------------------------------------------------------------------

pragma SPARK_Mode (On);

package Verification
  with Pure, Ghost
is
   --  Root package for verification-only (ghost) code.
   --  Child packages contain domain-specific ghost functions.
end Verification;
