#Skeleton Server
class Server
  require 'thread'
  require 'socket'

  def Server.process(x, req)
    x.puts "Unknown Message"
  end

  host = ARGV[0]  #Takes in parameter from the bash script/shell
  server = TCPServer.open(host)
  work_q = Queue.new
  student_no = 10352941
  puts "test"

  #Listening thread - accepts connections and pushes to stack/queue to be processed later
  thr = Thread.new do
    loop{
      s = server.accept
      work_q.push s
    }
  end

  #Array of 4 worker threads - process requests from the stack/queue
  workers = (0...4).map do
    Thread.new do
      loop{
        x = work_q.pop  #Pop next connection to be handled
        req = x.readline
        puts "Thread: " + Thread.current.object_id.to_s + " || Message: " + req

        #Change for switch & case statement?
        if req.include? "HELO"
          _, remote_port, _, remote_ip = x.peeraddr #sock_domain, remote_port, remote_hostname, remote_ip = socket.peeraddr
          x.puts req + "IP: #{remote_ip}\nPort: #{remote_port}\nStudentID: #{student_no}"
        elsif req == "KILL_SERVICE\n"
          x.puts("ABORT")
          abort("Goodbye")
        else
          process(x, req) #Or process other message
        end
        x.close
      }
    end
  end

  #Join threads - executes threads
  workers.each {|worker| worker.join}
  thr.join
end