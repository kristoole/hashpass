#
# File watcher to look for new passwords cracked by hascat
#
listener = Listen.to('cracked') do |modified, added, removed|
  unless added.empty?
    puts "added absolute path: #{added} - #{removed} - #{modified}"
    notifications = Notifications.new
    active = DB[:active].first
    out = []
    sleep 5
    File.readlines(added[0]).each do |line|
      out << line
    end
    puts "out: #{out}"
    puts "watching shiiiit-------------------------------"
    returned = DB[:cracked].insert(hash: added[0].split('/').last, password: out[0].split(':').last)
    # notifications.mail(out[0])
  end
end
# listener.start
