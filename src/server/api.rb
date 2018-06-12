require 'json'
require 'sinatra/json'

# Server API
class API
  def initialize
    @DB = Sequel.connect('sqlite://hashpass.db')
    @DB[:active].delete
    @notifications = Notifications.new
  end

  def login_page
    File.read(File.join('public', 'index.html'))
  end

  def main_page
    File.read(File.join('public', 'app.html'))
  end

  def start(active)
    return if @DB[:active].first.nil? || @DB[:active].first.empty?

    if active[:hashmode] == '2500'
      cap2hccapx =
        if RUBY_PLATFORM =~ /linux/
          './tools/cap2hccapx.bin'
        elsif RUBY_PLATFORM =~ /darwin/
          './tools/cap2hccapx-mac.bin'
        elsif RUBY_PLATFORM =~ /windows/
          'Critial Exception: User error :('
        else
          "Fuuuk"
        end
      cap_location = "hashes/#{active[:hash]}"
      hcap = "hashes/#{active[:hash]}"
      convert_cmd = "#{cap2hccapx} #{cap_location} #{hcap}"
      system(convert_cmd)
      sleep 3
    end

    rules = active[:rules].delete(' ').split(',').map do |rule|
      " -r /usr/share/hashcat/rules/#{rule}.rule"
    end

    options = {
      flags: active[:dictionary2].empty? ? '-a 0 -w 3 --status' : '-a 1 -w 3 --status',
      flags2: '--potfile-disable --status-timer=1',
      rules: !active[:rules].nil? ? "#{rules.join(',').delete(',')}" : '',
      hash:  !active[:hashstring].empty? ? "#{active[:hashstring]}" : "hashes/#{active[:hash]}",
      dics: active[:dictionary2].empty? ? "dics/#{active[:dictionary]}" : "dics/#{active[:dictionary]} dics/#{active[:dictionary2]}",
      cracked: "cracked/#{active[:hash]}#{active[:hashstring]}.crack",
      logs: !active[:hashstring].empty? ? "logs/#{active[:hashstring]}" : "logs/#{active[:hash]}"
    }

    p @cmd = "hashcat -m #{active[:hashmode]} "\
      "#{options[:flags]} #{options[:flags2]} "\
      "#{options[:hash]} #{options[:dics]} "\
      "#{active[:mask]} #{options[:rules]} -o #{options[:cracked]} "\
      "> #{options[:logs]}"

    @pid = Process.spawn(@cmd)
  end

  def clean
    `rm logs/*.*`
    `rm cracked/*.*`
  end

  def kill(pid)
    Process.kill(9, pid)
  end

  def upload(files)
    puts "files... #{files}"
    return if files.nil? || files.empty?
    files.each do |f|
      @filename = f[1][:filename]
      file = f[1][:tempfile]
      File.open("./hashes/#{@filename}", 'wb') do |ff|
        ff.write(file.read)
      end
    end
  end

  def pid_active?(pid)
    Process.getpgid(pid)
    true
  rescue Errno::ESRCH
    false
  end

  def status
    active = @DB[:active].first
    return '' if active.nil? || active.empty?
    active[:hash] = active[:hashstring] unless active[:hashstring].nil? || active[:hashstring].empty?
    type = read_log('Hash.Type', 1, active[:hash]) || ''
    recovered = read_log('Recovered', 1, active[:hash])#.delete(' ') || ''
    target = read_log('Hash.Target', 1, active[:hash]) || ''
    speed_dev_1 = read_log('Speed.Dev.#1', 1, active[:hash]).to_s.delete(' ') || ''
    speed_dev_2 = read_log('Speed.Dev.#2', 1, active[:hash]).to_s.delete(' ') || ''
    time_started = read_log('Time.Started', 4, active[:hash]) || ''
    time_estimated = read_log('Time.Estimated', 4, active[:hash]) || ''
    rejected = read_log('Rejected.', 1, active[:hash]).to_s.delete(' ') || ''
    restore_point = read_log('Restore.Point', 1, active[:hash]) || ''
    candidates_1 = read_log('Candidates.#1', 1, active[:hash]) || ''
    candidates_2 = read_log('Candidates.#2', 1, active[:hash]) || ''
    hw_monitor_1 = read_log('HWMon.Dev.#1', 2, active[:hash]).to_s.delete(' ') || ''
    hw_monitor_2 = read_log('HWMon.Dev.#2', 2, active[:hash]).to_s.delete(' ') || ''
    progress_cur = read_log('Progress.', 1, active[:hash]).to_s.split('/')[0] || ''
    progress_end = read_log('Progress.', 1, active[:hash]).to_s.split('/')[1].to_s.split(' ')[0]
    status = read_log('Status', 1, active[:hash]) || 'STOPPED'

    if status == 'Cracked' && @DB[:pending].count == 0
      new_cracked
    elsif status == 'Cracked'
      new_cracked
      promote
      active = DB[:active].first
      sleep 3
      start(active)
    elsif status == 'Exhausted' && @DB[:pending].count >= 1
      @DB[:active].delete
      promote
      active = DB[:active].first
      sleep 3
      start(active)
    elsif status == 'Exhausted' && @DB[:pending].count == 0
      @DB[:active].delete
    end

    found = read_log('Stopped:', 1, active[:hash]) || ''
    {
      type: type,
      recovered: recovered,
      target: target,
      speed_dev_1: speed_dev_1,
      speed_dev_2: speed_dev_2,
      time_started: time_started,
      time_estimated: time_estimated,
      rejected: rejected,
      restore_point: restore_point,
      candidates_1: candidates_1,
      candidates_2: candidates_2,
      hw_monitor_1: hw_monitor_1,
      hw_monitor_2: hw_monitor_2,
      progress_cur: progress_cur,
      progress_end: progress_end,
      status: status,
      found: found,
      stdout: `tail -n 22 logs/#{active[:hash]}`
    }
  end

  def promote
    pending = @DB[:pending].first
    hashed = pending;
    return if hashed.nil?
    @DB[:active].delete
    @DB[:pending].filter(id: hashed[:id]).delete if @DB[:pending].count > 0
    @DB[:active].insert(
      name: hashed[:name], dictionary: hashed[:dictionary],
      dictionary2: hashed[:dictionary2], rules: hashed[:rules],
      mask: hashed[:mask], hash: hashed[:hash],
      hashstring: hashed[:hashstring], hashmode: hashed[:hashmode]
    )
  end

  def new(param)
    name =        param['name'] || ''
    dictionary =  param['dictionary'] || ''
    dictionary2 = param['dictionary2'] || ''
    rules =       param['rules'] || ''
    mask =        param['mask'] || ''
    hashfile =    param['hash'] || ''
    hashmode =    param['hashmode'] || '2500'
    hashstring =  param['hashstring'] || ''
    notify =      param['notify'] || false

    params = {
      name: name, dictionary: dictionary, dictionary2: dictionary2,
      rules: rules, mask: mask, hash: hashfile, hashmode: hashmode,
      hashstring: hashstring
    }

    if notify
      @notifications.mail("New Hash #{ param['hash'] } #{ param['hashmode'] }", params)
    end

    @DB[:pending].insert(
      name: name, dictionary: dictionary, dictionary2: dictionary2,
      rules: rules, mask: mask, hash: hashfile, hashmode: hashmode,
      hashstring: hashstring
    )
  end

  def cracked
    out = []
    Dir.glob('cracked/*.crack') do |file|
      File.readlines(file).each do |line|
        out << line
      end
    end
    out
  end

  def new_cracked
    active = @DB[:active].first
    return if active.nil? || active.empty?
    out = []
    hash = !active[:hashstring].empty? ? "#{active[:hashstring]}" : "#{active[:hash]}"
    File.readlines('cracked/' + "#{hash}" + '.crack').each do |line|
      out << line
    end
    @notifications.mail("0wn3d!", out[0])
    @DB[:active].delete if @DB[:pending].count == 0
    DB[:cracked].insert(hash: hash, password: out[0].split(':').last)
  end
end
