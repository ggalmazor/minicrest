# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../../../lib/minicrest'

describe Minicrest::Equals do
  include Minicrest::Assertions

  describe '#matches?' do
    describe 'with primitives' do
      it 'matches equal integers' do
        assert equals(42).matches?(42)
      end

      it 'matches equal strings' do
        assert equals('hello').matches?('hello')
      end

      it 'matches equal floats' do
        assert equals(3.14).matches?(3.14)
      end

      it 'does not match different values' do
        refute equals(42).matches?(43)
      end

      it 'does not match different types' do
        refute equals(42).matches?('42')
      end

      it 'matches nil' do
        assert equals(nil).matches?(nil)
      end

      it 'does not match nil with non-nil' do
        refute equals(nil).matches?(0)
        refute equals(0).matches?(nil)
      end

      it 'matches boolean true' do
        assert equals(true).matches?(true)
      end

      it 'matches boolean false' do
        assert equals(false).matches?(false)
      end

      it 'does not confuse false and nil' do
        refute equals(false).matches?(nil)
        refute equals(nil).matches?(false)
      end
    end

    describe 'with arrays (deep equality)' do
      it 'matches equal arrays' do
        assert equals([1, 2, 3]).matches?([1, 2, 3])
      end

      it 'matches nested arrays' do
        assert equals([1, [2, 3], [4, [5]]]).matches?([1, [2, 3], [4, [5]]])
      end

      it 'matches deeply nested arrays' do
        expected = [
          [1, [2, [3, [4, [5]]]]],
          ['a', ['b', ['c', ['d']]]],
          [{ nested: [1, 2, 3] }]
        ]
        actual = [
          [1, [2, [3, [4, [5]]]]],
          ['a', ['b', ['c', ['d']]]],
          [{ nested: [1, 2, 3] }]
        ]

        assert equals(expected).matches?(actual)
      end

      it 'does not match arrays with different elements' do
        refute equals([1, 2, 3]).matches?([1, 2, 4])
      end

      it 'does not match arrays with different lengths' do
        refute equals([1, 2, 3]).matches?([1, 2])
      end

      it 'considers element order' do
        refute equals([1, 2, 3]).matches?([3, 2, 1])
      end

      it 'matches empty arrays' do
        assert equals([]).matches?([])
      end
    end

    describe 'with hashes (deep equality)' do
      it 'matches equal hashes' do
        assert equals({ a: 1, b: 2 }).matches?({ a: 1, b: 2 })
      end

      it 'matches nested hashes' do
        expected = { a: { b: { c: 1 } } }
        actual = { a: { b: { c: 1 } } }

        assert equals(expected).matches?(actual)
      end

      it 'matches deeply nested hashes' do
        expected = {
          level1: {
            level2: {
              level3: {
                level4: {
                  value: 'deep'
                }
              }
            }
          }
        }
        actual = {
          level1: {
            level2: {
              level3: {
                level4: {
                  value: 'deep'
                }
              }
            }
          }
        }

        assert equals(expected).matches?(actual)
      end

      it 'does not match hashes with different values' do
        refute equals({ a: 1 }).matches?({ a: 2 })
      end

      it 'does not match hashes with different keys' do
        refute equals({ a: 1 }).matches?({ b: 1 })
      end

      it 'ignores key order' do
        assert equals({ a: 1, b: 2 }).matches?({ b: 2, a: 1 })
      end

      it 'matches empty hashes' do
        assert equals({}).matches?({})
      end
    end

    describe 'with mixed nested structures' do
      it 'matches complex nested structures' do
        expected = { users: [{ name: 'Alice', age: 30 }, { name: 'Bob', age: 25 }] }
        actual = { users: [{ name: 'Alice', age: 30 }, { name: 'Bob', age: 25 }] }

        assert equals(expected).matches?(actual)
      end

      it 'matches complex API response-like structures' do
        expected = {
          data: {
            user: {
              id: 123,
              attributes: {
                name: 'John Doe',
                email: 'john@example.com',
                roles: %w[admin user],
                settings: {
                  notifications: {
                    email: true,
                    push: false,
                    preferences: {
                      frequency: 'daily',
                      types: %w[alerts updates]
                    }
                  }
                }
              },
              relationships: {
                organization: { id: 456, type: 'organization' },
                teams: [
                  { id: 1, name: 'Engineering' },
                  { id: 2, name: 'Product' }
                ]
              }
            }
          },
          meta: {
            timestamp: '2024-01-15T10:30:00Z',
            version: 'v2'
          }
        }

        actual = {
          data: {
            user: {
              id: 123,
              attributes: {
                name: 'John Doe',
                email: 'john@example.com',
                roles: %w[admin user],
                settings: {
                  notifications: {
                    email: true,
                    push: false,
                    preferences: {
                      frequency: 'daily',
                      types: %w[alerts updates]
                    }
                  }
                }
              },
              relationships: {
                organization: { id: 456, type: 'organization' },
                teams: [
                  { id: 1, name: 'Engineering' },
                  { id: 2, name: 'Product' }
                ]
              }
            }
          },
          meta: {
            timestamp: '2024-01-15T10:30:00Z',
            version: 'v2'
          }
        }

        assert equals(expected).matches?(actual)
      end
    end
  end

  describe '#description' do
    it 'describes what value is expected' do
      matcher = equals(42)

      assert_equal 'equal to 42', matcher.description
    end

    it 'describes string expected values' do
      matcher = equals('hello')

      assert_equal 'equal to "hello"', matcher.description
    end

    it 'describes complex expected values' do
      matcher = equals({ a: 1, b: [2, 3] })

      assert_equal 'equal to {a: 1, b: [2, 3]}', matcher.description
    end
  end

  describe '#failure_message' do
    it 'explains the mismatch with both values' do
      assert_equal equals(42).failure_message(43), <<~MSG.chomp
        expected 43
              to equal 42
      MSG
    end

    describe 'with hash diff' do
      it 'shows detailed diff for value differences' do
        assert_equal equals({ a: 1, b: 2, c: 3 }).failure_message({ a: 1, b: 999, c: 3 }), <<~MSG.chomp
          expected {a: 1, b: 999, c: 3}
                to equal {a: 1, b: 2, c: 3}

          Diff:
            key :b:
              expected: 2
              actual:   999
        MSG
      end

      it 'shows missing keys clearly' do
        assert_equal equals({ a: 1, b: 2, c: 3 }).failure_message({ a: 1 }), <<~MSG.chomp
          expected {a: 1}
                to equal {a: 1, b: 2, c: 3}

          Diff:
            missing key: :b => 2
            missing key: :c => 3
        MSG
      end

      it 'shows extra keys clearly' do
        assert_equal equals({ a: 1 }).failure_message({ a: 1, b: 2, c: 3 }), <<~MSG.chomp
          expected {a: 1, b: 2, c: 3}
                to equal {a: 1}

          Diff:
            extra key: :b => 2
            extra key: :c => 3
        MSG
      end

      it 'shows deeply nested differences' do
        expected = { user: { profile: { settings: { theme: 'dark' } } } }
        actual = { user: { profile: { settings: { theme: 'light' } } } }

        assert_equal equals(expected).failure_message(actual), <<~MSG.chomp
          expected {user: {profile: {settings: {theme: "light"}}}}
                to equal {user: {profile: {settings: {theme: "dark"}}}}

          Diff:
            key :user:
              expected: {profile: {settings: {theme: "dark"}}}
              actual:   {profile: {settings: {theme: "light"}}}
        MSG
      end
    end

    describe 'with array diff' do
      it 'shows element differences with index' do
        assert_equal equals([1, 2, 3, 4, 5]).failure_message([1, 2, 999, 4, 5]), <<~MSG.chomp
          expected [1, 2, 999, 4, 5]
                to equal [1, 2, 3, 4, 5]

          Diff:
            [2]:
              expected: 3
              actual:   999
        MSG
      end

      it 'shows size mismatch with expected and actual sizes' do
        assert_equal equals([1, 2, 3, 4, 5]).failure_message([1, 2]), <<~MSG.chomp
          expected [1, 2]
                to equal [1, 2, 3, 4, 5]

          Diff:
            size mismatch: expected 5 elements, got 2
            missing [2]: 3
            missing [3]: 4
            missing [4]: 5
        MSG
      end

      it 'shows nested array differences' do
        assert_equal equals([[1, 2], [3, 4], [5, 6]]).failure_message([[1, 2], [3, 999], [5, 6]]), <<~MSG.chomp
          expected [[1, 2], [3, 999], [5, 6]]
                to equal [[1, 2], [3, 4], [5, 6]]

          Diff:
            [1]:
              expected: [3, 4]
              actual:   [3, 999]
        MSG
      end
    end

    describe 'with mixed nested structure diff' do
      it 'shows differences in arrays inside hashes' do
        expected = { items: [{ id: 1, tags: %w[a b c] }, { id: 2, tags: %w[x y z] }] }
        actual = { items: [{ id: 1, tags: %w[a WRONG c] }, { id: 2, tags: %w[x y z] }] }

        assert_equal equals(expected).failure_message(actual), <<~MSG.chomp
          expected {items: [{id: 1, tags: ["a", "WRONG", "c"]}, {id: 2, tags: ["x", "y", "z"]}]}
                to equal {items: [{id: 1, tags: ["a", "b", "c"]}, {id: 2, tags: ["x", "y", "z"]}]}

          Diff:
            key :items:
              expected: [{id: 1, tags: ["a", "b", "c"]}, {id: 2, tags: ["x", "y", "z"]}]
              actual:   [{id: 1, tags: ["a", "WRONG", "c"]}, {id: 2, tags: ["x", "y", "z"]}]
        MSG
      end
    end
  end

  describe '#negated_failure_message' do
    it 'explains unexpected equality for primitives' do
      assert_equal equals(42).negated_failure_message(42), <<~MSG.chomp
        expected 42
          not to equal 42, but they are equal
      MSG
    end

    it 'explains unexpected equality for complex structures' do
      assert_equal equals({ a: [1, 2, 3] }).negated_failure_message({ a: [1, 2, 3] }), <<~MSG.chomp
        expected {a: [1, 2, 3]}
          not to equal {a: [1, 2, 3]}, but they are equal
      MSG
    end
  end
end
