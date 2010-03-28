#!/usr/bin/ruby

def totals
  $totals ||= File.new("totals.txt").to_a.map { |x| x.split.map { |i| i.to_f } }
end

def random_totals
  totals.map { |a| a.map { |x| x.rand_total } }
end

class Numeric
  def rand_total
    r = rand()/2.5 + 0.8
    self.to_f * r
  end
  def of
    (0...self).map { yield }
  end
end

def sorted_cat(ts,i)
  h = []
  cat = ts.map { |x| x[i] }
  cat.each_with_index { |x,i| h << [x,i] }
  h.sort_by { |x| x[0] }
end

def ranks(ts)
  pts = Hash.new { |h,k| h[k] = 0 }
  (0..7).each do |i|
    cat = sorted_cat(ts,i)
    cat.each_with_index { |x,i| pts[x[1]] += i }
  end
  pts
end

class Array
  def sum
    inject(0) { |h,k| h + k }
  end
  def average
    sum.to_f / size.to_f
  end
end

puts ranks(random_totals).inspect
rands = 1000.of { ranks(random_totals) }
(0..10).each { |i| puts "#{i}: " + rands.map { |x| x[i] }.average.to_s }    
    
  