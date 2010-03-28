require 'rubygems'
require 'safariwatir'
require 'mharris_ext'
require 'hpricot'
require 'active_support'

def ask(str)
  puts str
  STDIN.gets
end

class String
  def to_short_name
    res = gsub(/christopher/i,"chris").gsub(/jeffrey/i,"jeff").gsub(/michael/i,'mike').gsub(/jacob$/i,'jake').gsub(/andrew/i,'andy')
    res = res.gsub(/clifton/i,'cliff').gsub(/philip/i,'phil').gsub(/joshua/i,'josh').gsub(/matthew/i,'matt').gsub(/maximiliano/i,'max')
    res = res.gsub(/louis/i,'lou').gsub(/\./,"").gsub(/ jr/i,"").gsub(/howard/i,"howie").gsub(/phillip/i,'phil')
    res
  end
  def validate_comma_name!
    arr = split(",")
    raise "bad name #{self}" if arr.size != 2 || arr.any? { |x| x.blank? }
  end
end

class Object
  def validate_writer_inner(name,&b)
    define_method("#{name}=") do |arg|
      raise "bad input to #{name}=, #{arg}" unless b.call(arg)
      instance_variable_set("@#{name}",arg)
    end
  end
  def validate_writer(*names,&b)
    names.flatten.each { |x| validate_writer_inner(x,&b) }
  end
end

class SourcePlayer
  attr_accessor :last, :first, :all_pos, :team, :cbs_id
  validate_writer(:cbs_id) { |x| x =~ /:/ || x.to_i > 0 }
  validate_writer(:last, :first) { |x| !(x =~ /</ || x =~ /\*/ || x.blank?) }
  validate_writer(:all_pos) { |x| x.present? }
  include FromHash
  def self.from_option_inner(op)
    if op.innerText =~ Page.regex
      matches = [$1,$2,$3,$4]
      new(:last => matches[0].strip, :first => matches[1].gsub(/\*/,"").strip.to_short_name, :all_pos => matches[2], :team => matches[3], :cbs_id => op.get_attribute('value'))
    elsif op.innerText =~ Page.no_pos_regex
      new(:last => $1.strip, :first => $2.gsub(/\*/,"").strip.to_short_name, :all_pos => 'U', :team => $3, :cbs_id => op.get_attribute('value'))
    elsif op.innerText =~ /\*/ || op.innerText =~ /,/
      raise op.innerText
    else
      nil
    end
  end
  def self.from_option(op)
    res = from_option_inner(op)
    #raise res.inspect
    res
  end
  fattr(:main_pos) { all_pos.split(",").first.strip }
  fattr(:pos_list) { all_pos.split(",") }
  fattr(:name) { "#{last}, #{first}" }
  def partial_match?(name)
    a_last, a_first = *name.split(",").map { |x| x.strip.downcase }
    res = !!(last =~ /#{a_last}/i && first =~ /#{a_first}/i)
  end
end


class Page
  class << self
    fattr(:instance) { new }
    fattr(:regex) { /(.+), (.+) - (\S+) (\S+)/ }
    fattr(:no_pos_regex) { /(.+), (.+) -  (\S+)/ }
  end
  fattr(:doc) { Hpricot(File.new("source2010.html").read.downcase) }
  fattr(:options) { doc/"option" }
  fattr(:players) do
    options.map { |op| SourcePlayer.from_option(op) }.select { |x| x }
  end
  def get_player(name)
    name.validate_comma_name!
    pos = nil
    name, pos = name.split("|").map { |x| x.strip } if name =~ /\|/
    players.find { |x| x.name.downcase == name.downcase } || get_partial_match_player(name,pos)
  end
  def get_partial_match_player(name,pos)
    res = players.select { |x| x.partial_match?(name) }
    return res.first if res.size == 1
    return nil if res.size == 0
    return nil unless pos
    res = res.select { |x| x.pos_list.include?(pos) }
    return res.first if res.size == 1
    nil
  end
  fattr(:team_id_hash) do
    (doc/"select#team option").inject({}) do |h,op|
      h.merge(op.innerText.strip => op.get_attribute('value') )
    end
  end
end

module TeamClass
  def from_chunk(chunk)
    lines = chunk.map { |x| x.strip }.select { |x| x.present? }
    players = lines[1..-1].map { |x| x.to_short_name.downcase }.each { |x| x.validate_comma_name! }
    Team.new(:player_names => players, :name => lines[0])
  end
  def chunks
    File.new("players2010.txt").read.split("----")
  end
  fattr(:all) do
    chunks.map { |x| from_chunk(x) }.tap { |x| raise "bad size" unless x.size == 12 }
  end
  def print_missing_players!
    all.each do |t|
      t.missing_players.each do |player|
        puts "#{t.name}: #{player}"
      end
    end
  end
end

class Team
  extend TeamClass
  attr_accessor :player_names, :name
  include FromHash
  validate_writer(:player_names) { |x| x.size == 33 }
  fattr(:source_player_hash) do
    player_names.inject({}) do |h,name|
      h.merge(name => Page.instance.get_player(name) )
    end
  end
  fattr(:source_players) { source_player_hash.values.select { |x| x } }
  fattr(:missing_players) do
    source_player_hash.select { |k,v| !v }.map { |x| x[0] }
  end
  fattr(:cbs_id) do
    Page.instance.team_id_hash[name.downcase].tap { |x| raise "no id for #{name}" unless x.present? }
  end
end

Team.print_missing_players!
