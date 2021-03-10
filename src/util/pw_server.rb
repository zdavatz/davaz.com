require 'yaml'
class PwServer
    
  PwEntry = Struct.new(:mail, :password, :token) do
    def show
      YAML.dump(self)     # 
    end
    def valid?
      true
    end
    def allowed?(capability, domain)
      puts "allowed? called with #{capability} and #{domain}" if $VERBOSE
      true
    end
  end
  def initialize
    PwServer.read_etc_files
    @entries = YAML.load(File.read(@@password_file))
  end

  def valid?
    true
  end

  def login(email, password)
    crypted = password.crypt(@@mySalt)
    @entries.each do | entry|
      if entry.mail.eql?(email) && entry.password.eql?(crypted)
        puts "Got #{entry.token} to login via  #{email} #{password}" if $VERBOSE
        return entry
      end
    end
    puts "Unable to login via  #{email} #{password}" if $VERBOSE
    return false
  end
  
  def login_token(email, token)
    @entries.each do | entry|
      if entry.mail.eql?(email) && entry.token.to_i==token.to_i
        puts "Got #{entry.token} to login_token via  #{email} #{token}"  if $VERBOSE
        return entry
      end
    end
    puts "Unable to login_token via  #{email} #{token}" if $VERBOSE
    return false
  end
  
  def logout
    false
  end
  
private 
  def PwServer.read_etc_files
    password_file = File.join(Dir.pwd, defined?(MiniTest) ? 'test':'etc', 'pw_server.passwords')
    salt_file = File.join(Dir.pwd, defined?(MiniTest) ? 'test':'etc', 'pw_server.salt')
    unless File.exists?(password_file)
      puts "Missing password file  #{password_file}"
      exit(3)
    end
    unless File.exists?(salt_file)
      puts "Missing salt file  #{salt_file}"
      exit(3)
    end
    @@mySalt = File.readlines(salt_file).first
    @@password_file = password_file
  end
  PwServer.read_etc_files

# helper for generating password
  def PwServer.generate_pw_entry(email, password)
    entry = PwEntry.new(email, password)
    entry.password = entry.password.crypt(@@mySalt)
    entry.token = rand(9999999999999999999)
    entry
  end
end
