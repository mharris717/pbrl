require 'rubygems'
require 'safariwatir'
require 'mharris_ext'

class Object
  def tap
    yield(self)
    self
  end
end

def ie
  $ie ||= (x = Watir::Safari.new; x.goto("http://pbrl.baseball.cbssports.com/transactions/add-drop"); x)
end

class SourcePlayer
  attr_accessor :last, :first, :all_pos, :team
  def initialize(l,f,pos,team)
    @last,@first,@all_pos,@team = l.strip,f.strip,pos,team.strip
    self.class.hash[self.name] = self
  end
  def main_pos
    @main_pos ||= all_pos.split(",").first.strip
  end
  def pos_list
    @pos_list ||= all_pos.split(",")
  end
  def name
    @name ||= "#{last}, #{first}"
  end
  def option_text
    @option_text ||= "#{last}, #{first} - #{all_pos} #{team} *"
  end
  def select_pos!(pos)
    ie.select_list(:id,pos).select(option_text)
    puts "Found #{name} in #{pos}"
    true
  rescue
    return false
  end
  def select!
    pos_list.each { |pos| return if select_pos!(pos) }
    if already_selected?
     # puts "Already selected #{name}"
    else
      puts "can't find #{name}"
    end
  end
  def already_selected?
    !!ie.select_list(:id,'team_7').option(:text,option_text[0..-3])
  end
  def self.hash
    @hash ||= {}
  end
  def self.get(name)
    hash[name]
  end
  def self.select!(name)
    name = name.gsub(/Christopher/,"Chris").gsub(/Jeffrey/,"Jeff")
    pl = get(name)
    if pl
      pl.select!
    else
      puts "can't find #{name}"
    end
  end
end

#<option value=1B:8111>Sweeney, Mike - 1B SEA *
#<option value=1B:392256>Swisher, Nick - 1B,OF NYY *
def source_player_regex
  $source_player_regex ||= />(\S+), (\S+) - (\S+) (\S+) */
end

def get_source_players!
  File.new("source2009.html").read.scan(source_player_regex).each { |x| SourcePlayer.new(*x) }
  raise "source players not loaded correctly, size is #{SourcePlayer.hash.size}" unless SourcePlayer.hash.size > 100
end

def setup!
  get_source_players!
  set_team!
end

class Team
  attr_accessor :players, :team
  include FromHash
  def set_team!
    puts "setting team #{team}"
    ie.select_list(:name,'team').select(team)
  end
  def run!
    ie.goto("http://pbrl.baseball.cbssports.com/transactions/add-drop")
    sleep(3)
    set_team!
    players.each { |pl| SourcePlayer.select!(pl) }
    ie.checkbox(:id,'retro').set
    #ie.button(:value,"   OK   ").click
    sleep(6)
  end
end

def teams
  chunks = File.new("players.txt").read.split("----").map do |chunk|
    chunk.map { |x| x.strip }.select { |x| x != '' }
  end
  chunks.map do |ls|
    Team.new(:players => ls[1..-1], :team => ls[0])
  end
end

get_source_players!
teams.each do |t|
  t.run!
  STDIN.gets
end
  