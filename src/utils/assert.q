//   Copyright (c) 2022 Manifold Finance, Inc.
//   This Source Code Form is subject to the terms of the Mozilla Public
//   License, v. 2.0. If a copy of the MPL was not distributed with this
//   file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
// assert.q
// Assertions checks that verifies invariant variables (taken from qunit)

// Assert that the relation between expected and actual value holds
// @param actual An object representing the actual result value
// @param relation Function to check actual with expected
// @param expected An object representing the expected value
// @param msg Description of this test or related message
// @return actual object
assert: {[actual; relation; expected; msg]
  relationPassed: .[relation; (actual; expected); 0b];
  if[not relationPassed; 'msg];
  actual
  };

// assert that actual is true
// @param msg Description of this test or related message
// @return actual object
assertTrue: {[actual; msg]
  assert[actual; =; 1b; msg]
  };

// assert that actual is false
// @param msg Description of this test or related message
// @return actual object
assertFalse: {[actual; msg]
  assert[actual; =; 0b; msg]
  };

// assert that actual is empty i.e. count is zero.
// @param msg Description of this test or related message
// @return actual object
assertEmpty:{[actual; msg]
  assert[count actual; =; 0; msg]
  };

// assert that actual is NOT empty i.e. count is greater than zero.
// @param msg Description of this test or related message
// @return actual object
assertNotEmpty: {[actual; msg]
  assert[count actual; >; 0; msg]
  };
