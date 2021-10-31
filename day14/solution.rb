require "digest"

def find_keys(salt, hash_func = Digest::MD5.method(:hexdigest))
  n = 0
  keys = []
  possible_keys = Hash.new { |h, k| h[k] = [] }

  while keys.length < 64 || (n - keys.last) < 1000
    hash = hash_func.call "#{salt}#{n}"

    hash.scan(/(.)\1{4}/).each { |m|
      possible_keys[m[0]].filter { |idx| (n - idx) <= 1000 }.each { |idx|
        if !keys.include?(idx)
          keys.push(idx)
          keys.sort!
        end
        possible_keys[m].delete(idx)
      }
    }

    hash.match(/(.)\1{2}/) { |m|
      possible_keys[m[1]].push(n)
    }

    n += 1
  end

  keys
end

def solve_a(salt)
  puts find_keys(salt).sort[63]
end

def custom_hash(s)
  2017.times {
    s = Digest::MD5.hexdigest(s)
  }
  s
end

def solve_b(salt)
  puts find_keys(salt, method(:custom_hash)).sort[63]
end

salt = STDIN.gets.strip
solve_a(salt)
solve_b(salt)
