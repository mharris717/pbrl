fattr(:headers) do
  {'Cookie' => 'arena_stats=%7b%22data%22:%7b%22collegebasketball%22:%7b%22l%22:2300,%22v%22:3803,%22s%22:1258602400%7d,%22nfl%22:%7b%22l%22:%222100%22,%22v%22:%222104%22,%22s%22:%221254090031%22%7d,%22mlb%22:%7b%22l%22:%222000%22,%22v%22:%223630%22,%22s%22:%221250194614%22%7d,%22nba%22:%7b%22l%22:%221500%22,%22v%22:%221501%22,%22s%22:%221236784809%22%7d,%22fantasy%22:%7b%22l%22:2700,%22v%22:7104,%22s%22:1269796483%7d%7d,%22seq%22:42%7d; XCLGFbrowser=Cg+IKkmypiSLAAAAAgI; SCBInterstitial=0; fantasy_cookie=ws1990:20000:1269796353:pbrl.baseball.cbssports.com; last_access=1269796503; surround=e|3; MADTEST=1; mediaTrack=baseball-mgmt-gold|6|media-fantasy-home_fantasy|1|media-other-login|1; MADUCAT=1&0328&QCD&QCT&QC1138&QC1137&QC1125&QC1121&QC1120&QC1118&QC1114&QC1110&QC1108&QC1105; chatStatus=%7B%22chatStatus%22%3A%7B%22enableChat%22%3Atrue%7D%7D; mad_rsi_segs=ASK05540_10130&ASK05540_10283; fsr.s={"v":1,"rid":"1269792684280_13704","cp":{"fantasynews":"no","pop":"now"},"pv":6,"to":3,"c":"http://pbrl.baseball.cbssports.com/transactions/add-drop","lc":{"d0":{"v":6,"s":true}},"cd":0,"sd":0}; pid=L:25:ab4f34f0a4bab2bb; password_cache=ab4f34f0a4bab2bbec1380442fe12f1f57ee27ddb9e550fb; SessionID=-3967475870593849016; SportsLine=lname&Harris&userid&gfunk913&fname&Mike'}
end

str = "drop_action	drop
dummy::form	1
form::effective_point	1
form::faab_bid_amount	
form::form	form
form::original_effective_point	20100404
form::to_add	SS:392862
form::to_drop	
team	7"

class Object
  def mypost(*args)
    res = $res = post(*args)
    puts args.first
    puts res.myinspect
    puts "\n\n---------------\n\n"
    res
  end
  def myinspect
    File.create("output.html",body)
    "#{self.class} #{inspect} #{message} #{response} #{local_methods.inspect}"
  end
  def local_methods
    (methods - 7.methods).sort
  end
end

class PlayerSubmit
  attr_accessor :player
  include FromHash
  fattr(:session) { Net::HTTP.new("www.cbssports.com",80) }
  fattr(:full_add_url) { 'http://pbrl.baseball.cbssports.com/transactions/add-drop' }
  def login!
    session.mypost('/login','id' => 'gfunk913', 'password' => 'eojhcs73', 'master_product' => '150', 'xurl' => full_add_url, 'Submit' => 'Log In')
  end
  fattr(:params) do
    {'drop_action' => 'drop', 'dummy::form' => '1', 'form::effective_point' => '1', 'form::form' => 'form', 
     'form::original_effective_point' => '20100404', 'form::to_add' => player.cbs_id, 'team' => '7'}
  end
  def submit!
    session.mypost(full_add_url,params)
  end
end

t = teams[1]
puts t.players.inspect
t.source_players.each { |x| puts x.inspect }

# p = Page.new
# player = p.players.find { |x| x.last == 'laird' && x.first == 'gerald' }
# puts player.inspect
# sub = PlayerSubmit.new(:player => player)
#sub.login!
#sub.login!
#sub.submit!


# get_source_players!
# puts SourcePlayer.get('Young, Michael').inspect
# teams.each do |t|
#   10.times do
#     t.run!
#     STDIN.gets
#   end
# end
