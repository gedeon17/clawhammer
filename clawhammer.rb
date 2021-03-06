#!/usr/bin/env ruby
# Copyright (c) 2009-10 Joel Strait
# 
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.

require 'rubygems'  # For Ruby pre-1.9
require 'wavefile'

SOUNDS_PER_HUB = 6

# HammerHead assumes that all sounds are:
#   1 channel (mono)
#   44100 samples per second (sample rate)
#   16-bit
NUM_CHANNELS = :mono
SAMPLE_RATE = 44100
BITS_PER_SAMPLE = 16

if ARGV[0] == nil
  puts ""
  puts "Usage:"
  puts "  ruby clawhammer.rb [path of *.hub file]"
  puts ""
  exit()
end

hub_file = File.open(ARGV[0], "rb")
  
SOUNDS_PER_HUB.times do |i|
  # HUB Header Format:
  #   0: Length of HUB title
  #   1-30: HUB title. If HUB title is less than 30 bytes, remaining bytes are garbage.
  #   31-34: Size of sample data in bytes, unsigned little endian format.
  #   35: Flag for whether sound should be stretched to fill a measure when played in HammerHead.
  #       Ignored by Clawhammer.

  # Read HUB title
  hub_title_length = hub_file.sysread(1).unpack("c1")[0]
  hub_title = hub_file.sysread(30).slice(0...hub_title_length)
  hub_title = hub_title.downcase.gsub(" ", "_")
  
  # Read sample data size
  sample_data_length = hub_file.sysread(4).unpack("V1")[0]
  
  # Ignore the stretch flag
  hub_file.sysread(1)
  
  # Read sample data and write wave file
  w = WaveFile.new(NUM_CHANNELS, SAMPLE_RATE, BITS_PER_SAMPLE)
  w.sample_data = hub_file.sysread(sample_data_length).unpack("s*")
  output_file_name = "#{hub_title}-#{i + 1}.wav"
  w.save(output_file_name)
  puts "Sound #{i + 1} extracted, #{sample_data_length} bytes written to #{output_file_name}."
end
  
hub_file.close()
