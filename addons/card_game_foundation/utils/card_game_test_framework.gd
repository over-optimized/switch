# scripts/card_game_test_framework.gd
# Simple test framework for the Switch card game
class_name CardGameTestFramework
extends RefCounted

var tests_run: int = 0
var tests_passed: int = 0
var tests_failed: int = 0
var current_test_name: String = ""

## Start a new test
func start_test(test_name: String) -> void:
	current_test_name = test_name
	tests_run += 1
	print("\n=== TEST: %s ===" % test_name)

## Assert that a condition is true
func assert_true(condition: bool, message: String = "") -> bool:
	if condition:
		tests_passed += 1
		print("✓ PASS: %s" % (message if message != "" else "Condition is true"))
		return true
	else:
		tests_failed += 1
		print("✗ FAIL: %s" % (message if message != "" else "Condition is false"))
		return false

## Assert that two values are equal
func assert_equal(expected, actual, message: String = "") -> bool:
	if expected == actual:
		tests_passed += 1
		print("✓ PASS: %s (Expected: %s, Got: %s)" % [message if message != "" else "Values equal", str(expected), str(actual)])
		return true
	else:
		tests_failed += 1
		print("✗ FAIL: %s (Expected: %s, Got: %s)" % [message if message != "" else "Values not equal", str(expected), str(actual)])
		return false

## Assert that a value is not null
func assert_not_null(value, message: String = "") -> bool:
	if value != null:
		tests_passed += 1
		print("✓ PASS: %s" % (message if message != "" else "Value is not null"))
		return true
	else:
		tests_failed += 1
		print("✗ FAIL: %s" % (message if message != "" else "Value is null"))
		return false

## Assert that a value is null
func assert_null(value, message: String = "") -> bool:
	if value == null:
		tests_passed += 1
		print("✓ PASS: %s" % (message if message != "" else "Value is null"))
		return true
	else:
		tests_failed += 1
		print("✗ FAIL: %s (Expected null, got: %s)" % [message if message != "" else "Value is not null", str(value)])
		return false

## Assert that an array has a specific size
func assert_array_size(array: Array, expected_size: int, message: String = "") -> bool:
	var actual_size = array.size()
	if actual_size == expected_size:
		tests_passed += 1
		print("✓ PASS: %s (Size: %d)" % [message if message != "" else "Array size correct", actual_size])
		return true
	else:
		tests_failed += 1
		print("✗ FAIL: %s (Expected: %d, Got: %d)" % [message if message != "" else "Array size incorrect", expected_size, actual_size])
		return false

## Print test results summary
func print_summary() -> void:
	print("\n" + "=".repeat(50))
	print("TEST SUMMARY")
	print("=".repeat(50))
	print("Tests Run: %d" % tests_run)
	print("Passed: %d" % tests_passed)
	print("Failed: %d" % tests_failed)
	print("Success Rate: %.1f%%" % (float(tests_passed) / float(tests_run) * 100.0 if tests_run > 0 else 0.0))
	
	if tests_failed == 0:
		print("🎉 ALL TESTS PASSED!")
	else:
		print("❌ %d TESTS FAILED" % tests_failed)
	print("=".repeat(50))
