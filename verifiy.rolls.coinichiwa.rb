#!/bin/ruby -w

require 'digest/sha1'

$verbose = false
$client_seed         = "neOmYJS4d9jCvC"
$server_seed         = "8f8ee56e3f332df7763e01167ca4afbc"
$sha1_of_server_seed = "ab3095d267820a12c6c8a6b1c7d1be8a65ef5773"
$start_nounce        = 1
$end_nounce          = 14

def simulate_roll(server_seed, client_seed, nounce)
    # must be defined here to use it later
    converted_reduced_hashed_string = 0
    # concat seeds and nounce to a single string
    seed = "#{server_seed}-#{client_seed}-#{nounce}"
    puts "seed: #{seed}" if $verbose
    
    loop do
        # hash string 
        seed = Digest::SHA1.hexdigest(seed)
        puts "sha1(seed): #{seed}" if $verbose
    
        # keep only the first 8 digits
        reduced_hashed_string = seed[0..7]
        puts "sha1(seed)[0..7]: #{reduced_hashed_string}" if $verbose
    
        # convert 8 hex digits to Integer
        converted_reduced_hashed_string = reduced_hashed_string.to_i(16)
        puts "sha1(seed)[0..7] to int: #{converted_reduced_hashed_string}" if $verbose
        
        # remove bais towards rolls <= 72.96
        # this must be done because the max value of 8 hexdigits
        # is 16**8 = 4294967296 and thus a mod 10k would prefer
        # said rolls
        break if (converted_reduced_hashed_string <= 4294960000)
    end
    
    # modulo 10000 the final integer
    modulo_10000_of_converted_reduced_hashed_string = converted_reduced_hashed_string % 10000
    puts "sha1(...)[0..7] to int % 10000: #{modulo_10000_of_converted_reduced_hashed_string}" if $verbose    
    return modulo_10000_of_converted_reduced_hashed_string
end

calculated_sha1_of_server_seed = Digest::SHA1.hexdigest($server_seed)

if (calculated_sha1_of_server_seed == $sha1_of_server_seed)
    puts "#{"="*34} SEED  DATA #{"="*34}"
    puts "Hash of Server is correct.\n-> #{$sha1_of_server_seed}"
    puts "Client seed was given as\n-> #{$client_seed}"
    puts "#{"="*36} ROLLS #{"="*37}"
    for i in $start_nounce..$end_nounce
        puts "Roll \##{i}: #{simulate_roll($server_seed, $client_seed, i).to_s.rjust(4,'0')}"
    end
else
    puts "#{"="*34} SEED  DATA #{"="*34}"
    puts "Warning! Hash of Server seed is not correct!.\nHash was given as:\n-> #{$sha1_of_server_seed}\nbut should be\n-> #{calculated_sha1_of_server_seed}\nfor given seed\n-> #{$server_seed}"
    puts "="*80
end

=begin

puts "Server seed      : #{$server_seed}"
puts "Server seed hash : #{Digest::SHA1.hexdigest($server_seed)}"
puts "Client seed      : #{$client_seed}"

for i in $start_nounce..$end_nounce
    puts "Roll \##{i}: #{simulate_roll($server_seed, $client_seed, i).to_s.rjust(4,'0')}"
end

=end
